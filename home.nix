{ config, pkgs, ... }:
{
  # imports = [ ./base.nix ];
  programs.home-manager.enable = true;
  home.stateVersion = "22.05";
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.packages = with pkgs; [
    tig
    tmux
    bat
    btop
    fd
    exa
    ripgrep
    ripgrep-all
    nnn
    viddy
    smug
    delta
    broot
    watchexec
  ];
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.zsh.enable = true;
}

