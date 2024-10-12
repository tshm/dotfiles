{ config, lib, pkgs, ... } @ args:

let
  base = (import ./base.nix) args;
  over = {
    home.packages = base.home.packages ++ [
      # pkgs.neovim
    ];
    /*
    programs.java = { enable = true; };
    */
  };
in lib.recursiveUpdate base over

