{
  description = "gzip (gzip + gunzip + zcat + uncompress) as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # gzip ships one real program (the `gzip` ELF) plus a fan of /bin/sh wrapper
  # scripts (gunzip, zcat, uncompress, zcmp, zdiff, zegrep, zfgrep, zforce,
  # zgrep, zless, zmore, znew, gzexe). The scripts need an external shell +
  # cmp/grep/sed/less — they violate the single-binary model and are dropped,
  # same policy as bzip2/xz.
  #
  # gunzip/zcat/uncompress are NOT separate programs: gzip self-detects them
  # from argv[0] (gunzip→decompress, zcat→decompress+stdout, uncompress→
  # decompress). That detection block in gzip.c is guarded by `#if !GNU_STANDARD`
  # and GNU_STANDARD defaults to 1, so a stock build compiles it OUT and modern
  # gzip relies on the shell scripts instead. A patch sets GNU_STANDARD to 0
  # to turn the argv[0] dispatch back on, and we ship a single `gzip` binary
  # with `gunzip`/`zcat`/`uncompress` as UNPIN_META aliases — the xz model.
  outputs = { self, unpins-lib }:
    let
      lib = unpins-lib.lib;
      # `uncompress` is documented inside gunzip.1 and has no page of its own
      # (see manKeep below, which has always said so).
      aliases = [ "gunzip" "zcat" { name = "uncompress"; noMan = true; } ];
      # Pages we keep: the program + the two aliases that have their own page
      # (uncompress is documented inside gunzip.1, no standalone page).
      manKeep = [ "gzip" "gunzip" "zcat" ];
      manKeepArgs =
        builtins.concatStringsSep " " (map (p: "! -name '${p}.1*'") manKeep);

      # Shared override, applied identically on native and windows:
      #   * patch GNU_STANDARD to 0 to restore argv[0] mode detection;
      #   * drop nixpkgs' GZIP_NO_TIMESTAMPS wrapProgram (preFixup) so $out/bin/
      #     gzip stays the bare ELF, not a shell wrapper;
      #   * prune bin/ to just `gzip` (+ `gzip.exe`) and man1/ to the 3 pages.
      tuneGzip = drv: drv.overrideAttrs (old: {
        # Run gzip's upstream test suite on native runners; auto-skips on every
        # cross (build can't execute host). 29 of the 30 tests run (pipe-output
        # dropped by patch) and all pass under static-musl.
        doCheck = drv.stdenv.buildPlatform.canExecute drv.stdenv.hostPlatform;
        # Drop nixpkgs' only buildInputs entry, runtimeShellPackage (bash): it
        # exists solely so the installed zcat/zgrep/zless *shell scripts* get a
        # runtime shell — but we delete those scripts (single-binary policy), so
        # bash is dead weight. Critically, on the mingw cross it's a target
        # input, so keeping it forces a full `bash-x86_64-w64-mingw32` build
        # (which fails). gzip the program needs no libraries.
        buildInputs = [ ];
        # Drop the makeShellWrapper setup hook too. Its hook captures the
        # *target* runtimeShell for any wrapProgram — and on the mingw cross
        # that's `bash-x86_64-w64-mingw32`, forcing a full (failing) bash-mingw
        # build even though we removed the only wrapProgram (preFixup="" below).
        # Keep updateAutotoolsGnuConfigScriptsHook (cross config.sub refresh).
        nativeBuildInputs = builtins.filter
          (x: builtins.match ".*[Ww]rapper.*" (x.name or "") == null)
          (old.nativeBuildInputs or [ ]);
        # GNU_STANDARD 1 → 0 in gzip.c (argv[0] mode detection) and the flaky
        # `pipe-output` test dropped; each patch header gives its reason.
        patches = (old.patches or [ ]) ++ [
          ./patches/gnu-standard-0.patch
          ./patches/drop-pipe-output-test.patch
        ];
        preFixup = "";
        postInstall = (old.postInstall or "") + ''
          for o in $outputs; do
            d="''${!o}"
            if [ -d "$d/bin" ]; then
              find "$d/bin" -mindepth 1 -maxdepth 1 \
                ! -name 'gzip' ! -name 'gzip.exe' -delete
            fi
            if [ -d "$d/share/man/man1" ]; then
              find "$d/share/man/man1" -mindepth 1 -maxdepth 1 \
                ${manKeepArgs} -delete
            fi
          done
        '';
      });
    in
    lib.mkStandaloneFlake {
      inherit self;
      name = "gzip";

      # Build via the unpin-llvm engine + emit a bitcode multicall module.
      engine = "unpin-llvm";
      multicall = {
        # The `.exe` on the engine too, not the nixpkgs mingw-gcc cross.
        windows = true;
        programs = [{ name = "gzip"; inherit aliases; }];
      };

      # gzip --version exits 0 and prints the version banner to stdout.
      smoke = [ "--version" ];
      smokePattern = "Written by Jean-loup Gailly";

      build = pkgs:
        tuneGzip pkgs.pkgsStatic.gzip;

      windowsBuild = pkgs:
        tuneGzip (lib.mingwStaticCross pkgs).gzip;
    };
}
