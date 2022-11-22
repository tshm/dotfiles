{ config, pkgs, ... }:
{
  # imports = [ ./base.nix ];
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.packages = with pkgs; [
    git-imerge
    neovim
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
    delta
    watchexec
  ];
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.zsh.enable = true;
}

