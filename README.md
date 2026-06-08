# shadow

[shadow](https://github.com/shadow-maint/shadow) — a single self-contained binary providing 34 programs (`login`, `passwd`, `su`, `useradd`, `groupadd`, `chage`, …; full list: `unpin info shadow`), built natively for Linux.

[![CI](https://github.com/unpins/shadow/actions/workflows/shadow.yml/badge.svg)](https://github.com/unpins/shadow/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install shadow`.

Linux-only: shadow uses Linux-specific `/etc/{passwd,shadow,group,gshadow}` semantics and subuid/subgid namespace mappings (`newuidmap`/`newgidmap`).

## Usage

Run a program with [unpin](https://github.com/unpins/unpin):

```bash
unpin shadow passwd alice
unpin shadow useradd -m bob
unpin shadow groupadd dev
```

To install the programs onto your PATH:

```bash
unpin install shadow
```

`unpin install shadow` creates the `login`, `passwd`, `su`, `useradd`, and 30 other commands (full list: `unpin info shadow`).

`lastlog` is absent because configure disables it when wtmpx headers are missing (musl). PAM-only tools (none in the default shadow build) are configure-disabled automatically because pkgsStatic does not link libpam.

## Man pages

All 47 shadow man pages are embedded — read with `unpin man shadow <page>`:

```bash
unpin man shadow passwd       # a program
unpin man shadow login.defs   # a config-file page (man5)
```

Beyond the per-program pages this covers the config-file references (`login.defs.5`, `shadow.5`, `passwd.5`, `gshadow.5`, `suauth.5`, `subuid.5`, `subgid.5`, `limits.5`, `login.access.5`, `porttime.5`, `faillog.5`) and the `shadow.3` C API.

## Build locally

```bash
nix build github:unpins/shadow
./result/bin/shadow passwd --help
```

Or run directly:

```bash
nix run github:unpins/shadow -- useradd --help
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/shadow/releases) page has standalone binaries for manual download.
