{ config, lib, pkgs, ... }:

{
  # imports = [ ./base.nix ];
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;
  home.stateVersion = "22.11";
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  nixpkgs.config.allowUnfree = true;
  home.packages = [
    pkgs.nix-index
    pkgs.fastfetch
    pkgs.openssh
    pkgs.ncdu
    pkgs.jq
    pkgs.devbox
    pkgs.neovim
    pkgs.topgrade
    pkgs.ctpv
    pkgs.atool
    pkgs.git-imerge
    pkgs.tig
    pkgs.jc
    pkgs.jless
    pkgs.nnn
    pkgs.viddy
    pkgs.delta
    pkgs.watchexec
  ];
  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        pre_sudo = true;
        no_retry = true;
        no_self_update = true;
        disable = [
          "node"
        ];
        set_title = false;
        cleanup = true;
      };
      commands = {
        "Run garbage collection on Nix store" = "nix-collect-garbage";
        "zinit" = "zsh -i -c 'source ~/.dotfiles/zsh/zshrc && zinit update'";
      };
    };
  };
  programs.bat = {
    enable = true;
    extraPackages = [ pkgs.bat-extras.batdiff ];
  };
  programs.btop.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.ripgrep.enable = true;
  programs.zoxide.enable = true;
  /* https://home-manager-options.extranix.com/? */
  programs.git = {
    enable = true;
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.eza = {
    enable = true;
    icons = true;
    git = true;
  };
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file ~/.dotfiles/tmux.conf
    '';
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
  programs.zsh = {
    enable = true;
    initExtra = ''
      source ~/.dotfiles/zsh/zshrc
      [ -f ~/.zshrc.local ] && source ~/.zshrc.local
    '';
  };
}

