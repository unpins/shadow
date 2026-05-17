# shadow

Standalone build of [shadow](https://github.com/shadow-maint/shadow), shipped as a single multicall binary that dispatches to 34 applets via argv[0] — `login`, `passwd`, `su`, `useradd`, `userdel`, `usermod`, `groupadd`, `groupdel`, `groupmod`, `chage`, `chfn`, `chsh`, `expiry`, `faillog`, `gpasswd`, `newgrp`, `chpasswd`, `chgpasswd`, `groupmems`, `grpck`, `grpconv`, `grpunconv`, `logoutd`, `newusers`, `nologin`, `pwck`, `pwconv`, `pwunconv`, `newuidmap`, `newgidmap`, `getsubids`, `vipw`, `sg`, `vigr`.

[![CI](https://github.com/unpins/shadow/actions/workflows/shadow.yml/badge.svg)](https://github.com/unpins/shadow/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

Linux-only: shadow uses Linux-specific `/etc/{passwd,shadow,group,gshadow}` semantics and subuid/subgid namespace mappings (`newuidmap`/`newgidmap`).

## Usage

The package ships one executable, `shadow`. `unpin install` materializes per-applet shims (`passwd`, `useradd`, `su`, …) next to the multicall using argv[0] dispatch. To run a command directly without installing, invoke as `shadow <applet>`:

```bash
shadow passwd alice
shadow useradd -m bob
shadow su -
shadow groupadd dev
```

Or create symlinks named after the commands you want to use as bare names:

```bash
ln -s "$(command -v shadow)" ~/bin/passwd
passwd alice
```

Built-in applets (34): `chage`, `chfn`, `chgpasswd`, `chpasswd`, `chsh`, `expiry`, `faillog`, `getsubids`, `gpasswd`, `groupadd`, `groupdel`, `groupmems`, `groupmod`, `grpck`, `grpconv`, `grpunconv`, `login`, `logoutd`, `newgidmap`, `newgrp`, `newuidmap`, `newusers`, `nologin`, `passwd`, `pwck`, `pwconv`, `pwunconv`, `sg`, `su`, `useradd`, `userdel`, `usermod`, `vigr`, `vipw`.

`lastlog` is absent because configure disables it when wtmpx headers are missing (musl). PAM-only tools (none in the default shadow build) are configure-disabled automatically because pkgsStatic does not link libpam.

## Installation

Install with [unpin](https://github.com/unpins/unpin):

```bash
unpin shadow
```

Or run without installing:

```bash
unpin run shadow
```

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
