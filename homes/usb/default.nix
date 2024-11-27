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
        wayland.windowManager.hyprland = {
          settings = {
            monitor = "eDP-1,1920x1080,0x0,1";
            "exec-once" = [
              "[workspace 1 silent] beeper"
              "[workspace 2] zen"
              "[workspace 2 silent] kitty"
            ];
          };
        };
      }
    ];
  };
}
