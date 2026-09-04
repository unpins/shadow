# Changelog

## [Unreleased]

### Fixed

- `unpin install shadow` now creates the commands. In the v4.19.4-1 release it
  created only `shadow` itself: the list of program names never made it into
  the published binary, so `passwd`, `su`, `useradd`, `login` and the other 30
  were installed nowhere. All 34 names are there now.

### Changed

- The two section-3 pages, which document the C library rather than any program
  in here, are no longer embedded. The 45 that remain are the programs' own
  pages and the config-file pages (`login.defs`, `shadow`, `suauth`, …).
- Built by the same compiler as the rest of the catalog. The binary grew from
  719 KB to 1.38 MB. Checked on Linux x86_64 and arm64 against a scratch
  `/etc`: `useradd` and `groupadd` create the accounts and groups, `usermod`
  adds a member, `userdel` removes them, and `useradd -D` reads the defaults.
