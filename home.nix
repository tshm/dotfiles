{ config, lib, pkgs, ... }:

{
  # imports = [ ./base.nix ];
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.packages = [
    (import (fetchTarball https://github.com/cachix/devenv/tarball/v0.3)).default
    pkgs.cachix
    pkgs.git-imerge
    pkgs.neovim
    pkgs.tig
    pkgs.tmux
    pkgs.bat
    pkgs.btop
    pkgs.fd
    pkgs.exa
    pkgs.ripgrep
    pkgs.ripgrep-all
    pkgs.nnn
    pkgs.viddy
    pkgs.delta
    pkgs.watchexec
  ];
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.zsh.enable = true;
}

