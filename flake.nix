{
  description = "shadow as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Linux-only multicall: shadow ships ~33 separate static binaries
  # (login/passwd/su/useradd/usermod/chage/gpasswd/newgrp/groupadd/…), each
  # its own ELF in pkgsStatic. nixpkgs `meta.platforms` is *-linux only
  # (Linux-specific /etc/{passwd,shadow,group,gshadow} semantics + subuid/
  # subgid namespace mappings via newuidmap/newgidmap).
  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "shadow";
      linuxOnly = true;

      # Smoke floor: bare `shadow` (no applet) prints usage, so probe a
      # representative applet through the `--unpin-program=` selector. `chage
      # --help` exits 0 and prints the usage banner naming `chage`.
      smoke = [ "--unpin-program=chage" "--help" ];
      smokePattern = "Usage: chage";

      # Build via the unpin-llvm engine + emit a bitcode multicall module. On
      # Linux the engine compiles plain pkgsStatic.shadow (every tool is its own
      # upstream binary) to bitcode and the standalone self-folds them into one
      # `shadow` binary. The old X+Z objcopy/source-rename fold in
      # ./multicall.nix can't run on the engine's -flto bitcode objects, so it's
      # dropped in favour of the bitcode multicall hook. Pure C — no requires.cxx.
      #
      # The program `name` is the LINKED executable basename. argv[0]-dispatch
      # aliases (newgrp → sg; vipw → vigr) are listed under their real program,
      # not as separate programs.
      engine = "unpin-llvm";
      multicall = {
        # shadow's chpasswd/chgpasswd/salt.c call libxcrypt's `crypt_gensalt`,
        # which musl's libc.a does NOT provide. The engine already builds shadow
        # against libxcrypt's (bitcode) libcrypt.a, so it sits in the self-fold's
        # auto-derived input closure — but the auto-derive drops `libcrypt.a` as a
        # presumed libc split (correct for glibc; wrong for musl, which folds crypt
        # into libc.a, so a standalone libcrypt.a is always libxcrypt). Rescue it:
        # the closure's copy is the SAME engine-bitcode archive shadow linked, so it
        # folds on every arch. (A hand-passed `depArchives` would instead resolve to
        # the vanilla GCC-ELF libxcrypt, whose ppc64le inline-PLT relocs the -flto
        # mega-link can't relax — "unknown relocation" against crypt_r/memset/….)
        keepAutoArchives = [ "libcrypt.a" ];
        programs = [
          { name = "chage"; }
          { name = "chfn"; }
          { name = "chgpasswd"; }
          { name = "chpasswd"; }
          { name = "chsh"; }
          { name = "expiry"; }
          { name = "faillog"; }
          { name = "getsubids"; }
          { name = "gpasswd"; }
          { name = "groupadd"; }
          { name = "groupdel"; }
          { name = "groupmems"; }
          { name = "groupmod"; }
          { name = "grpck"; }
          { name = "grpconv"; }
          { name = "grpunconv"; }
          { name = "login"; }
          { name = "logoutd"; }
          { name = "newgidmap"; }
          { name = "newgrp"; aliases = [ "sg" ]; }
          { name = "newuidmap"; }
          { name = "newusers"; }
          { name = "nologin"; }
          { name = "passwd"; }
          { name = "pwck"; }
          { name = "pwconv"; }
          { name = "pwunconv"; }
          { name = "su"; }
          { name = "useradd"; }
          { name = "userdel"; }
          { name = "usermod"; }
          { name = "vipw"; aliases = [ "vigr" ]; }
        ];
      };

      # linuxOnly + no windowsBuild → the engine path is the only build reached.
      # Engine: plain pkgsStatic.shadow compiled to bitcode and self-folded into
      # one binary by the standalone. nixpkgs splits `su` into its own output
      # (postInstall moves $out/bin/su → $su); the engine self-fold absorbs su
      # into the multicall, so drop the split and its postInstall move (which
      # would otherwise `mv` a binary that no longer lives at $out/bin/su).
      build = pkgs:
        pkgs.pkgsStatic.shadow.overrideAttrs (old: {
          outputs = [ "out" ];
          postInstall = "";
          # libxcrypt's <crypt.h> tags its prototypes with `__THROW`, defined
          # in <sys/cdefs.h> only under `defined(__GNUC__) && !__cplusplus`.
          # Under the engine's clang the toolchain's embedded musl cdefs.h
          # leaves `__THROW` empty for shadow's TUs, so the bare `__THROW;`
          # after each `crypt(...)` declarator is parsed as a stray statement
          # ("expected function body after function declarator"). Define it to
          # the nothrow attribute (its GCC value) so the declarations parse.
          # Harmless for the other (util-linux-style) headers that already use
          # the macro. Pushed via NIX_CFLAGS_COMPILE on the env (structuredAttrs
          # is off here, so a plain string attr is fine).
          NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "")
            + " -D__THROW=__attribute__((__nothrow__))";
        });
    };
}
