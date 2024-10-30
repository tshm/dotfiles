{ nixpkgs, home-manager, ... } @ args:
let
  base = import ./base.nix;
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  "tshm@PD0056" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = args;
    modules = [
      base
      ./wsl.nix
      ./PD0056.nix
    ];
  };
  "tshm@minf" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = args;
    modules = [
      base
      ./gui.nix
      ./minf.nix
    ];
  };
}
