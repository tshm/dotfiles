{ config, lib, pkgs, ... }:

{
  # imports = [ ./base.nix ];
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.packages = [
    pkgs.devbox
    pkgs.direnv
    pkgs.neovim
    pkgs.topgrade
    pkgs.atool
    pkgs.git-imerge
    pkgs.tig
    pkgs.tmux
    pkgs.fzf
    pkgs.bat
    pkgs.btop
    pkgs.fd
    pkgs.jc
    pkgs.jless
    pkgs.eza
    pkgs.ripgrep
    pkgs.ugrep
    pkgs.nnn
    pkgs.lf
    pkgs.ctpv
    pkgs.viddy
    pkgs.delta
    pkgs.watchexec
    pkgs.zoxide
  ];
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.zsh.enable = true;
}

