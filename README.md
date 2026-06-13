# gzip

[gzip](https://www.gnu.org/software/gzip/) — the GNU compression utility. A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/gzip/actions/workflows/gzip.yml/badge.svg)](https://github.com/unpins/gzip/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install gzip`.

One `gzip` binary that also answers to `gunzip`, `zcat` and `uncompress` — the mode is picked from the command name (argv[0]), exactly how GNU gzip's own `gunzip`/`zcat` behave. The `z*` shell-script companions (`zcmp`, `zdiff`, `zgrep`, `zless`, `zmore`, `znew`, `gzexe`) need an external shell plus `cmp`/`grep`/`sed`/`less`, so they are dropped — the same single-binary policy as bzip2/xz.

## Usage

Run the `gzip` program with [unpin](https://github.com/unpins/unpin):

```bash
unpin gzip -k file         # compress -> file.gz (keep original)
unpin gzip -d file.gz      # decompress
unpin gzip -dc file.gz     # decompress to stdout (zcat)
```

To install it onto your PATH:

```bash
unpin install gzip
```

Installing also creates the `gunzip`, `zcat` and `uncompress` commands alongside `gzip`.

## Build locally

```bash
nix build github:unpins/gzip
./result/bin/gzip --version
```

Or run directly:

```bash
nix run github:unpins/gzip -- --version
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/gzip/releases) page has standalone binaries for manual download.

## Build notes

- **Platforms:** Linux, macOS, Windows.
- **Windows:** mingw cross — a self-contained PE32+ `.exe`.
- **argv[0] mode detection** is compiled in with `-DGNU_STANDARD=0`; stock gzip hides that block behind `GNU_STANDARD=1` and relies on the dropped shell scripts instead.
- **Man pages:** embedded in the binary, read with `unpin man gzip` (the `gzip`, `gunzip` and `zcat` pages).
