{ home-manager, pkgs, extraSpecialArgs, ... }:

{
  "tshm@minf" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ../modules/base.nix
      ../modules/gui.nix
      ../modules/dev.nix
      {
        home.packages = [
          pkgs.qsv
          pkgs.deno
        ];
        wayland.windowManager.hyprland = {
          settings = {
            device = [{
              name = "lenovo-thinkpad-compact-usb-keyboard-with-trackpoint-1";
              sensitivity = 1.0;
            }
              {
                name = "lenovo-thinkpad-compact-usb-keyboard-with-trackpoint-3";
                sensitivity = 1.0;
              }
              {
                name = "elecom-trackball-mouse-huge-trackball-1";
                sensitivity = 1.0;
              }];
            workspace = [
              "1, layoutopt:orientation:right"
              "2, layoutopt:orientation:left"
            ];
            exec-once = [
              "[workspace 1] zen"
              # temporary fix...
              "[workspace 1 silent] beeper --ozone-platform-hint=x11"
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
