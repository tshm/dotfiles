{ nixpkgs, ... } @ args:
let
  base = import ./base.nix;
  gui = import ./gui.nix;
  system = "x86_64-linux";
in
{
  "minf" = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = args // { inherit system; };
    modules = [
      ./minf
      (base { host = "minf"; })
      (gui { })
    ];
  };

  "x360" = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = args // { inherit system; };
    modules = [
      ./x360
      (base { host = "x360"; })
      (gui { })
    ];
  };
}
