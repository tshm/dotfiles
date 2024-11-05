{ nixpkgs, nixos-hardware, ... } @ args:
let
  base = import ./base.nix;
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  "minf" = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = args // { inherit system; };
    modules = [
      ./minf
      (base { host = "minf"; })
    ];
  };

  "x360" = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = args // { inherit system; };
    modules = [
      ./x360
      (base { host = "x360"; })
    ];
  };
}
