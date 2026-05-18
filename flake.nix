{
  description = "Standalone build of shadow";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Linux-only multicall (login/passwd/su/useradd + 30 other applets) built
  # via the post-link recipe in ./multicall.nix — same ld -r + objcopy
  # --redefine-sym pattern as e2fsprogs / procps / util-linux / findutils.
  # nixpkgs `meta.platforms` for shadow is *-linux only (Linux-specific
  # /etc/{passwd,shadow,group,gshadow} semantics + subuid/subgid namespace
  # mappings via newuidmap/newgidmap).
  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "shadow";
      linuxOnly = true;
      build = pkgs:
        import ./multicall.nix {
          lib = pkgs.lib // unpins-lib.lib;
        } pkgs;
    };
}
