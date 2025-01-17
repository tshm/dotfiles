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
        wayland.windowManager.hyprland.extraConfig = ''
          workspace=1, layoutopt:orientation:right
          workspace=2, layoutopt:orientation:left
        '';
        programs.java = { enable = false; };
        programs.go = { enable = false; };
      }
    ];
  };
}
