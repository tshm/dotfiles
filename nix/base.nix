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
    pkgs.ctpv
    pkgs.atool
    pkgs.git
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
    pkgs.nnn
    pkgs.viddy
    pkgs.delta
    pkgs.watchexec
    pkgs.zoxide
  ];
  /* https://home-manager-options.extranix.com/? */
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      log = { enabled = true; };
      manager = {
          ratio = [0 3 7];
          sort_by = "natural";
          sort_dir_first = true;
      };
    };
  };
}

