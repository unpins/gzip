# Changelog

## [Unreleased]

Initial release — `gzip` 1.14 as a single self-contained binary, built natively
for Linux, macOS, and Windows.

### Added

- Builds for Linux (x86_64, aarch64, armv7l, i686, ppc64le, riscv64), macOS
  (Intel and Apple Silicon), and Windows (x86_64).
- `gunzip`, `zcat` and `uncompress` are created alongside `gzip` when you
  install it.
- The `gzip`, `gunzip` and `zcat` pages are embedded in the binary — read them
  with `unpin man gzip`.
- The Windows binary uses the Universal C Runtime, which is part of Windows 10
  and later. On Windows 7 or 8.1 that runtime has to be installed first — it
  comes through Windows Update.
