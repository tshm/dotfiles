{ config, pkgs, ... }:
{
  # imports = [ ./base.nix ];
  programs.home-manager.enable = true;
  home.packages = with pkgs; [
    tig
    tmux
    bat
    btop
    fd
    exa
    ripgrep
    nnn
    smug
    delta
    broot
    watchexec
  ];
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.zsh.enable = true;
}

