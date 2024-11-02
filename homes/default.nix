{ nixpkgs, home-manager, ... } @ args:
let
  base = import ./base.nix;
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  "pi@spi" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
    extraSpecialArgs = args // { user = "pi"; };
    modules = [
      base
      ./spi.nix
    ];
  };
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
    extraSpecialArgs = args // { inherit system; };
    modules = [
      base
      ./gui.nix
      ./minf.nix
    ];
  };
  "tshm@x360" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = args // { inherit system; };
    modules = [
      base
      ./gui.nix
      ./x360.nix
    ];
  };
}
