{ home-manager, pkgs, extraSpecialArgs, ... }:

{
  "tshm@usb" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ../modules/base.nix
      ../modules/gui.nix
      ../modules/dev.nix
    ];
  };

}
