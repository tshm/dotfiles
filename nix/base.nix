{ config, lib, pkgs, ... }:

let
  isWSL = builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop";
in
{
  # imports = [ ./base.nix ];
  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;
  home = {
    stateVersion = "22.11";
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    packages = [
      # NIX
      pkgs.comma
      pkgs.nix-index
      # platform
      pkgs.fastfetch
      pkgs.topgrade
      pkgs.openssh
      pkgs.ncdu
      # shelltools
      pkgs.neovim
      pkgs.viddy
      pkgs.p7zip
      pkgs.entr
      # devtools
      pkgs.devbox
      pkgs.git-cliff
      pkgs.git-imerge
      pkgs.git-absorb
      pkgs.tig
      pkgs.delta
      pkgs.tokei
      pkgs.jc
      pkgs.jq
      pkgs.jless
    ] ++ (if isWSL then [
      pkgs.wsl-open
      pkgs.wslu
    ] else []);
    file = {
      "${config.xdg.configHome}/mpv/mpv.conf".source = ~/.dotfiles/mpv.conf;
      "${config.xdg.configHome}/k9s/hotkeys.conf".source = ~/.dotfiles/k8s/k9s/hotkeys.yaml;
      "${config.xdg.configHome}/k9s/plugins.conf".source = ~/.dotfiles/k8s/k9s/plugins.yaml;
      ".ssh/config".source = ~/.dotfiles/sshconfig;
      "${config.xdg.configHome}/wezterm/wezterm.lua".source = ~/.dotfiles/wezterm/wezterm.lua;
    };
  };
  programs = {
    home-manager.enable = true;
    topgrade = {
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
    bat = {
      enable = true;
      # extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
    };
    btop.enable = true;
    fd.enable = true;
    fzf.enable = true;
    ripgrep.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    /* https://home-manager-options.extranix.com/? */
    git = {
      enable = true;
      includes = [
        { path = "~/.dotfiles/gitconfig"; }
        {
          path = "~/projdir/.gitconfig";
          condition = "gitdir:~/projdir/";
        }
        {
          path = "~/github/.gitconfig";
          condition = "hasconfig:remote.*.url::**/github**";
        }
        {
          path = "~/.gitconfig.local";
        }
      ];
      ignores = [
        ".DS_Store"
        ".*.vim"
        ".vscode"
        "*.favdoc"
        ".*.local"
        ".env"
      ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
    eza = {
      enable = true;
      icons = "auto";
      git = true;
    };
    tmux = {
      enable = true;
      extraConfig = ''
        source-file ~/.dotfiles/tmux.conf
      '';
    };
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        log = { enabled = true; };
        manager = {
            ratio = [0 3 7];
            sort_by = "natural";
            sort_dir_first = true;
        };
        opener = {
          less = [
            { run = ''less "$@"''; block = true; desc = "less"; }
          ];
          jless = [
            { run = ''jless "$@"''; block = true; desc = "jless"; }
          ];
        };
        open.prepend_rules = [
          { name = "*.vtt"; use = "less"; }
          { name = "*.json"; use = "jless"; }
        ];
      };
      # plugins = {
      #   hide-preview = hide-preview;
      #   tab = "./plugins/tab";
      # };
      keymap = {
        manager = {
          prepend_keymap =[
            { on = "<Tab>"; run = "plugin --sync tab"; desc = "create or switch tab"; }
            { on = "T"; run  = "plugin --sync hide-preview"; desc = "Toggle preview"; }
          ];
        };
      };
    };
    zsh = {
      enable = true;
      initExtra = ''
        source ~/.dotfiles/zsh/zshrc
      '';
      loginExtra = ''
        [ -f ~/.zshrc.local ] && source ~/.zshrc.local
      '';
      shellAliases = {
        y = "yazi";
      };
    };
  };
}

