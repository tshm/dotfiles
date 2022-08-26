{ config, pkgs, ... }:
{
  # imports = [ ./base.nix ];
  programs.home-manager.enable = true;
  home.stateVersion = "22.05";
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.packages = with pkgs; [
    git-imerge
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
    watchexec
  ];
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.zsh.enable = true;
}

