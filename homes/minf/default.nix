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
          pkgs.deno
        ];
        wayland.windowManager.hyprland = {
          settings = {
            "workspace" = [
              "1, layoutopt:orientation:right"
              "2, layoutopt:orientation:left"
            ];
            "exec-once" = [
              "[workspace 1] zen"
              "[workspace 1 silent] beeper"
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
