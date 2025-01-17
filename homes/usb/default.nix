{ home-manager, pkgs, extraSpecialArgs, ... }:

{
  "tshm@usb" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ../modules/base.nix
      ../modules/gui.nix
      ../modules/dev.nix
      {
        home.packages = [
          pkgs.deno
        ];
        wayland.windowManager.hyprland.extraConfig = ''
          monitor = "eDP-1,1920x1080,0x0,1"
          workspace=1, layoutopt:orientation:right
          workspace=2, layoutopt:orientation:left
        '';
      }
    ];
  };
}
