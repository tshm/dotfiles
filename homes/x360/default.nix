{ home-manager, pkgs, extraSpecialArgs, ... }:

home-manager.lib.homeManagerConfiguration {
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
      programs.java = { enable = false; };
      programs.go = { enable = false; };
    }
  ];
}

