{ nixpkgs, ... } @ args:
let
  base = import ./base.nix;
  gui = import ./gui.nix;
  system = "x86_64-linux";
  specialArgs = args // { inherit system; };
in
{
  "minf" = nixpkgs.lib.nixosSystem {
    inherit system;
    inherit specialArgs;
    modules = [
      ./minf
      (base { host = "minf"; })
      gui
    ];
  };

  "x360" = nixpkgs.lib.nixosSystem {
    inherit system;
    inherit specialArgs;
    modules = [
      ./x360
      (base { host = "x360"; })
      gui
    ];
  };

  "usb" = nixpkgs.lib.nixosSystem {
    inherit system;
    inherit specialArgs;
    modules = [
      ./usb
      (base { host = "usb"; })
      gui
    ];
  };
}
