{
  user,
  config,
  pkgs,
  lib,
  ...
}@inputs:

let
  configPath = pathStr: config.lib.file.mkOutOfStoreSymlink "/home/${user}/.dotfiles${pathStr}";
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
    inputs.catppuccin.homeModules.catppuccin
  ];
  age = {
    identityPaths = [ "/home/${user}/.ssh/id_ed25519" ];
    secrets = {
      user-password.file = configPath "/secrets/user-password.age";
    };
  };
  nix = {
    settings = inputs.nixsettings;
    package = pkgs.nix;
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };
  catppuccin = {
    enable = true;
    accent = "green";
  };
  targets.genericLinux.enable = true;
  nixpkgs.config.allowUnfree = true;
  home = {
    stateVersion = "22.11";
    username = user;
    homeDirectory = "/home/${user}";
    packages = [
      pkgs.nh
      pkgs.cachix
      inputs.agenix.packages.${pkgs.system}.default
      # platform
      pkgs.openssh
      pkgs.file
      pkgs.fastfetch
      pkgs.ncdu
      # shelltools
      pkgs.python3
      pkgs.trashy
      pkgs.file
      pkgs.psmisc
      pkgs.neovim
      pkgs.autossh
      pkgs.viddy
      pkgs.p7zip
      pkgs.entr
      pkgs.unzip
      # pkgs.archivemount
      pkgs.wget
      pkgs.pv
      pkgs.clipboard-jh
      pkgs.croc
      # devtools
      pkgs.devbox
      pkgs.onefetch
      pkgs.tig
      pkgs.jujutsu
      pkgs.pre-commit
      pkgs.lnav
      pkgs.jc
      pkgs.yq
      pkgs.jless
      # extras
      pkgs.restic
      pkgs.rclone
      #pkgs.chawan
    ];
    file = {
      "${config.xdg.configHome}/k9s/hotkeys.yaml".source = configPath "/k8s/k9s/hotkeys.yaml";
      "${config.xdg.configHome}/k9s/plugins.yaml".source = configPath "/k8s/k9s/plugins.yaml";
      "${config.xdg.configHome}/nvim/".source = configPath "/vim/nvim";
    };
  };
  home.sessionVariables = {
    TMUX_TMPDIR = lib.mkForce "/tmp";
  };
  programs = {
    home-manager.enable = true;
    nix-index-database.comma.enable = true;
    topgrade = {
      enable = true;
      settings = {
        misc = {
          pre_sudo = true;
          no_retry = true;
          no_self_update = true;
          disable = [
            "node"
            "nix"
          ];
          set_title = false;
          cleanup = true;
        };
        commands = {
          # "zinit" = "zsh -i -c 'source ~/.dotfiles/zsh/zshrc && zinit update'";
        };
      };
    };
    bat = {
      enable = true;
      # extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = [ "~/.ssh/*.config" ];
      matchBlocks = {
        "*" = { };
      };
      extraConfig = ''
        # HostName test.com
        # Port 1234
        # User myuser
        # DynamicForward 9999
        # LocalForward 84321 0.0.0.0:4321
        # ProxyJump dmz
        # #_Desc This is a sample description
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
      settings = {
        update_check = false;
        filter_model = "host";
        invert = true;
      };
    };
    nushell = {
      enable = true;
    };
    carapace = {
      enable = false; # it breaks other completions
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    # https://home-manager-options.extranix.com/?
    git = {
      enable = true;
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
        { path = "~/.gitconfig.local"; }
      ];
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      enableFishIntegration = false;
      config = {
        global.hide_env_diff = true;
      };
      # https://github.com/direnv/direnv/issues/73
      stdlib = ''
        # vim: ft=sh
        export_alias() {
          local name=$1
          shift
          local alias_dir=$PWD/.direnv/aliases
          local target="$alias_dir/$name"
          local oldpath="$PATH"
          mkdir -p "$alias_dir"
          if ! [[ ":$PATH:" == *":$alias_dir:"* ]]; then
            PATH_add "$alias_dir"
          fi
          cat <<EOT > $target
        #!/usr/bin/env bash
        PATH="$oldpath:\$PATH"
        exec $@ "\$@"
        EOT
          chmod +x "$target"
        }
        # load .local.envrc
        [ -f ./.local.envrc ] && {
          echo 'direnv: loading ./.local.envrc'
          source ./.local.envrc
        }
        # run onefetch
        git rev-parse --is-inside-work-tree >/dev/null 2>&1 && onefetch --nerd-fonts
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
      initLua = ''
        -- require("git"):setup()
        -- require("archivemount"):setup()
        require("projects"):setup({})
      '';
      settings = {
        log = {
          enabled = true;
        };
        mgr = {
          ratio = [
            0
            3
            7
          ];
          sort_by = "natural";
          sort_dir_first = true;
        };
        plugin = {
          prepend_previewers = [
            {
              mime = "{image,audio,video}/*";
              run = "mediainfo";
            }
            {
              mime = "application/x-subrip";
              run = "mediainfo";
            }
          ];
          # prepend_fetchers = [
          #   { id = "git"; name = "*"; run = "git"; }
          #   { id = "git"; name = "*/"; run = "git"; }
          # ];
        };
        opener = {
          less = [
            {
              run = ''less "$@"'';
              block = true;
              desc = "less";
            }
          ];
          jless = [
            {
              run = ''jless "$@"'';
              block = true;
              desc = "jless";
            }
          ];
        };
        open.prepend_rules = [
          {
            name = "*.vtt";
            use = "less";
          }
          {
            name = "*.json";
            use = "jless";
          }
        ];
      };
      plugins = {
        # hide-preview = hide-preview;
        enter = ../../yazi/plugins/enter.yazi;
        tab = ../../yazi/plugins/tab.yazi;
        shell-prefill = ../../yazi/plugins/shell-prefill.yazi;
        chmod = pkgs.yaziPlugins.chmod;
        git = pkgs.yaziPlugins.git;
        mediainfo = pkgs.yaziPlugins.mediainfo;
        # archivemount = pkgs.yaziPlugins.archivemount;
        projects = pkgs.yaziPlugins.projects;
        toggle-pane = pkgs.yaziPlugins.toggle-pane;
      };
      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = "<Tab>";
              run = "plugin tab";
              desc = "create or switch tab";
            }
            {
              on = "!";
              run = "plugin shell-prefill";
              desc = "Shell prefill";
            }
            {
              on = "T";
              run = "plugin toggle-pane min-preview";
              desc = "Toggle preview";
            }
            {
              on = "<Enter>";
              run = "plugin enter";
              desc = "Enter dir";
            }
            {
              on = "<C-n>";
              run = ''
                shell 'ripdrag -x "$@"' --confirm
              '';
              desc = "drag and drop";
            }
            {
              on = [
                "g"
                "u"
              ];
              run = ''
                shell 'ya pub dds-cd --str "$(git rev-parse --show-toplevel)"' --confirm
              '';
            }
            {
              on = [
                "g"
                "t"
              ];
              run = "cd ~/.local/share/Trash/";
            }
            # { on = [ "m" "a" ]; run = "plugin archivemount mount"; }
            # { on = [ "m" "u" ]; run = "plugin archivemount unmount"; }
            {
              on = [
                "c"
                "m"
              ];
              run = "plugin chmod";
            }
            {
              on = [
                "P"
                "s"
              ];
              run = "plugin projects save";
            }
            {
              on = [
                "P"
                "l"
              ];
              run = "plugin projects load";
            }
            {
              on = [
                "P"
                "P"
              ];
              run = "plugin projects load_last";
            }
            {
              on = [
                "P"
                "d"
              ];
              run = "plugin projects delete";
            }
          ];
        };
      };
    };
    zsh = {
      enable = true;
      enableCompletion = false;
      initContent = lib.mkBefore ''
        # Fix tmux socket permissions issue in WSL
        export TMUX_TMPDIR="/tmp"

        # Create tmux socket directory if it doesn't exist
        [ -n "$XDG_RUNTIME_DIR" ] && mkdir -p "$XDG_RUNTIME_DIR/tmux-$(id -u)" 2>/dev/null

        source ~/.dotfiles/zsh/zshrc
        # zprof
      '';
      loginExtra = ''
        [ -f .local.zlogin ] && source .local.zlogin
        # [ -z "$TMUX" ] && tm
      '';
      shellAliases = {
        y = "yy";
        l = "ll";
        v = "nvim";
        pstree = "pstree -A";
        mv = "nocorrect mv";
        cp = "nocorrect cp";
        rm = "rm -i";
        jq = "yq";
        yt-dlp = "noglob yt-dlp";
      };
    };
  };
}
