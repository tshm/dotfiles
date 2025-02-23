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
    cursors.enable = true;
  };
  home = {
    stateVersion = "22.11";
    username = user;
    homeDirectory = "/home/${user}";
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
      pkgs.tig
      pkgs.pre-commit
      pkgs.lnav
      pkgs.scc
      pkgs.jc
      pkgs.jq
      pkgs.jless
      # extras
      #pkgs.chawan
    ];
    file = {
      "${config.xdg.configHome}/k9s/hotkeys.yaml".source = configPath "/k8s/k9s/hotkeys.yaml";
      "${config.xdg.configHome}/k9s/plugins.yaml".source = configPath "/k8s/k9s/plugins.yaml";
      "${config.xdg.configHome}/nvim/".source = configPath "/vim/nvim";
    };
  };
  # services = {
  #   syncthing.enable = !input.isWSL;
  # };
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
          disable = [ "node" ];
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
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
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
        PATH="$oldpath"
        exec $@ \$@
        EOT
          chmod +x "$target"
        }

        [ -f ./.local.envrc ] && {
          echo 'direnv: loading ./.local.envrc'
          source ./.local.envrc
        }
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
      initLua = ''
        require("git"):setup()
      '';
      settings = {
        log = { enabled = true; };
        manager = {
          ratio = [ 0 3 7 ];
          sort_by = "natural";
          sort_dir_first = true;
        };
        plugin = {
          prepend_fetchers = [
            { id = "git"; name = "*"; run = "git"; }
            { id = "git"; name = "*/"; run = "git"; }
          ];
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
      plugins = {
        # hide-preview = hide-preview;
        enter = ../../yazi/plugins/enter.yazi;
        tab = ../../yazi/plugins/tab.yazi;
        arrow = ../../yazi/plugins/arrow.yazi;
      };
      keymap = {
        manager = {
          prepend_keymap = [
            { on = "k"; run = "plugin arrow -1"; }
            { on = "j"; run = "plugin arrow 1"; }
            { on = "<Tab>"; run = "plugin tab"; desc = "create or switch tab"; }
            { on = "T"; run = "plugin hide-preview"; desc = "Toggle preview"; }
            { on = "<Enter>"; run = "plugin enter"; desc = "Enter dir"; }
            {
              on = "<C-n>";
              run = ''
                shell 'ripdrag -x "$@"' --confirm
              '';
              desc = "drag and drop";
            }
            {
              on = [ "g" "u" ];
              run = ''
                shell 'ya pub dds-cd --str "$(git rev-parse --show-toplevel)"' --confirm
              '';
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
