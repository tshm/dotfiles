{ nixpkgs, home-manager, ... } @ args:
let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
  extraSpecialArgs = args // { inherit system; user = "tshm"; };
in
{
  "pi@spi" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
    extraSpecialArgs = extraSpecialArgs // { user = "pi"; };
    modules = [
      ./base.nix
      ./dev.nix
      ./spi.nix
    ];
  };
  "tshm@PD0056" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ./base.nix
      ./wsl.nix
      ./dev.nix
      ./PD0056.nix
    ];
  };
  "tshm@usb" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ./base.nix
      ./gui.nix
    ];
  };
  "tshm@minf" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ./base.nix
      ./gui.nix
      ./dev.nix
      ./minf.nix
    ];
  };
  "tshm@x360" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ./base.nix
      ./gui.nix
      ./dev.nix
      ./x360.nix
    ];
  };
}
