# Changelog

## [Unreleased]

### Changed

- The Windows binary is now built by the same compiler as the Linux and macOS
  ones. Checked on Windows 10: compressing a file gives a byte-identical result,
  files written by the previous binary still decompress to the original, and
  `gunzip`, `zcat` and `uncompress` still work.

  It now uses the Universal C Runtime, which is part of Windows 10 and later.
  On Windows 7 or 8.1 that runtime has to be installed first — it comes through
  Windows Update. The previous binary did not need it.
