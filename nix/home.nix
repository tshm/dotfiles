{ config, lib, pkgs, ... } @ args:

let
  base = (import ./base.nix) args;
  over = {
    home.packages = base.home.packages ++ [ /* pkgs.nvim */ ];
  };
in lib.recursiveUpdate base over

