{ user, config, pkgs, ... } @inputs:

let
  configPath = pathStr: config.lib.file.mkOutOfStoreSymlink "/home/${user}/.dotfiles${pathStr}";
in
{
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    inputs.catppuccin.homeManagerModules.catppuccin
  ];
  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;
  catppuccin = {
    enable = true;
    accent = "green";
    pointerCursor.enable = true;
  };
  home = {
    stateVersion = "22.11";
    username = user;
    homeDirectory = "/home/${user}/";
    packages = [
      pkgs.nh
      # platform
      pkgs.openssh
      pkgs.file
      pkgs.fastfetch
      pkgs.ncdu
      # shelltools
      pkgs.python3
      pkgs.file
      pkgs.psmisc
      pkgs.neovim
      pkgs.autossh
      pkgs.viddy
      pkgs.p7zip
      pkgs.entr
      pkgs.unzip
      pkgs.wget
      # devtools
      pkgs.devbox
      pkgs.onefetch
      pkgs.git-cliff
      pkgs.git-imerge
      pkgs.git-absorb
      pkgs.tig
      pkgs.lnav
      pkgs.scc
      pkgs.jc
      pkgs.jq
      pkgs.jless
    ];
    file = {
      "${config.xdg.configHome}/k9s/hotkeys.conf".source = configPath "/k8s/k9s/hotkeys.yaml";
      "${config.xdg.configHome}/k9s/plugins.conf".source = configPath "/k8s/k9s/plugins.yaml";
      "${config.xdg.configHome}/nvim/".source = configPath "/vim/nvim";
      "${config.xdg.configHome}/yazi/plugins/tab.yazi".source = configPath "/yazi/plugins/tab.yazi";
      "${config.xdg.configHome}/yazi/plugins/enter.yazi".source = configPath "/yazi/plugins/enter.yazi";
    };
  };
  # services = {
  #   syncthing.enable = !input.isWSL;
  # };
  programs = {
    home-manager.enable = true;
    nix-index-database.comma.enable = true;
    # nh = {
    #   enable = true;
    #   package = pkgs.nh;
    #   flake = "/home/${user}/.dotfiles";
    #   clean = {
    #     enable = true;
    #     extraArgs = "--keep-since 10d --keep 3";
    #   };
    # };
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
    ssh = {
      enable = true;
      includes = [ "./*.config" ];
      extraConfig = ''
        # vim: ft=sshconfig

        # Host test
        #   HostName test.com
        #   Port 1234
        #   DynamicForward 9999
        #   LocalForward 84321 0.0.0.0:4321
        #   User myuser
        #   ProxyJump dmz
        #   #_Desc This is a sample description

        # Host *
        #   ControlMaster auto
        #   ControlPath ~/.ssh/mux-%r@%h:%p
        #   ControlPersist 4h
      '';
    };
    btop.enable = true;
    fd.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd";
      defaultOptions = [
        "-m"
        "--ansi"
        "--preview 'bat {}'"
        "--preview-window hidden"
        "--bind 'alt-a:toggle-all'"
        "--bind 'alt-p:toggle-preview'"
        ''--bind 'alt-l:execute(bat --pager \"less -L\" {})' ''
        "--bind 'alt-o:execute(e {})'"
        "--bind 'alt-e:become(vi {+} </dev/tty >/dev/tty)'"
      ];
    };
    ripgrep.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    atuin = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      flags = [ "--disable-up-arrow" ];
    };
    nushell = {
      enable = true;
    };
    carapace = {
      enable = false; # it breaks other completions
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    /* https://home-manager-options.extranix.com/? */
    git = {
      enable = true;
      delta.enable = true;
      lfs.enable = true;
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
      enableNushellIntegration = true;
      config = {
        global.hide_env_diff = true;
      };
      stdlib = ''
        onefetch
      '';
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
      enableNushellIntegration = true;
      settings = {
        log = { enabled = true; };
        manager = {
          ratio = [ 0 3 7 ];
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
      #   # hide-preview = hide-preview;
      #   tab = "${inputs.dotfiles}/yazi/plugins/tab.yazi";
      # };
      keymap = {
        manager = {
          prepend_keymap = [
            { on = "<Tab>"; run = "plugin --sync tab"; desc = "create or switch tab"; }
            { on = "T"; run = "plugin --sync hide-preview"; desc = "Toggle preview"; }
            { on = "<Enter>"; run = "plugin --sync enter"; desc = "Enter dir"; }
            {
              on = "<C-n>";
              run = ''
                shell 'ripdrag -x "$@"' --confirm
              '';
              desc = "drag and drop";
            }
          ];
        };
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        source ~/.dotfiles/zsh/zshrc
      '';
      shellAliases = {
        y = "yy";
        l = "ll";
        v = "nvim";
        pstree = "pstree -A";
        mv = "nocorrect mv";
        cp = "nocorrect cp";
        rm = "rm -i";
        yt-dlp = "noglob yt-dlp";
      };
    };
  };
}

