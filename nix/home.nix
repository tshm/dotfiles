{ pkgs, ... }:

{
  imports = [ ~/.dotfiles/nix/base.nix ];
  home.packages = [
    pkgs.psmisc
  ];
  programs.java = { enable = true; };
  programs.go = { enable = true; };
}

