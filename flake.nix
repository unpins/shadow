{
  description = "Standalone build of shadow";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "shadow";
      # nixpkgs `meta.platforms` for shadow is *-linux only — shadow uses
      # Linux-specific /etc/{passwd,shadow,group,gshadow} semantics and
      # subuid/subgid namespace mappings (newuidmap/newgidmap).
      linuxOnly = true;
    };
}
