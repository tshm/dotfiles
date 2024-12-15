{ home-manager, pkgs, extraSpecialArgs, ... }:

{
  "tshm@x360" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ../modules/base.nix
      ../modules/gui.nix
      ../modules/dev.nix
      {
        home.packages = [
          pkgs.deno
          pkgs.iio-hyprland
        ];
        wayland.windowManager.hyprland = {
          settings = {
            device = {
              name = "syna3290:01-06cb:cd4f-touchpad";
              sensitivity = 0.0;
            };
            monitor = "eDP-1,1920x1080,0x0,1";
            "exec-once" = [
              "iio-hyprland"
              "[workspace 1 silent] beeper --ozone-platform-hint=x11"
              "[workspace 2] zen"
              "[workspace 2 silent] kitty"
            ];
          };
        };
        programs.java = { enable = false; };
        programs.go = { enable = false; };
      }
    ];
  };
}
