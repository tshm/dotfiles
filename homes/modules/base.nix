{
  user,
  config,
  pkgs,
  lib,
  ...
}@inputs:

let
  configPath = pathStr: config.lib.file.mkOutOfStoreSymlink "/home/${user}/.dotfiles${pathStr}";
  platformSystem = pkgs.stdenv.hostPlatform.system;
  emojiCli = pkgs.fetchFromGitHub {
    owner = "babarot";
    repo = "emoji-cli";
    rev = "0fbb2e48e07218c5a2776100a4c708b21cb06688";
    sha256 = "1hfjhng5y8pldrnbd1qhylnf5g0ikjz5szmk5cmf56xz686x2bla";
  };
  zshMoreCompletions = pkgs.fetchFromGitHub {
    owner = "MenkeTechnologies";
    repo = "zsh-more-completions";
    rev = "cf16fbfdfc9d920078a08f42570c2fea4abdfab6";
    sha256 = "12vc0mqlk845cy0wcxf3y3z7y2dykhkgf39alm78k1kc60nhhyv9";
  };
  zshSsh = pkgs.fetchFromGitHub {
    owner = "sunlei";
    repo = "zsh-ssh";
    rev = "cee8c2a119dd53f01dc6aef1ce79faa783aa2e3f";
    sha256 = "0qmgjb2vygl12xw82lnmdrz7hn2847r0m9dyizyf9qx2hsqml8np";
  };
  compiledZshPlugins = pkgs.runCommand "compiled-zsh-plugins" { nativeBuildInputs = [ pkgs.zsh ]; } ''
    mkdir -p $out
    cp -r ${pkgs.zsh-autosuggestions} $out/autosuggestions
    cp -r ${pkgs.zsh-history-search-multi-word} $out/history-search-multi-word
    cp -r ${pkgs.zsh-fast-syntax-highlighting} $out/fast-syntax-highlighting
    cp -r ${pkgs.zsh-autopair} $out/autopair
    cp -r ${pkgs.pure-prompt} $out/pure
    cp -r ${pkgs.zsh-history-substring-search} $out/history-substring-search
    cp -r ${pkgs.zsh-forgit} $out/forgit
    cp -r ${emojiCli} $out/emoji
    cp -r ${pkgs.zsh-clipboard} $out/clipboard
    cp -r ${pkgs.zsh-fzf-tab} $out/fzf-tab
    cp -r ${zshSsh} $out/zsh-ssh
    chmod -R u+w $out

    zsh -fc '
    zcompile $out/autosuggestions/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
    zcompile $out/autosuggestions/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    zcompile $out/history-search-multi-word/share/zsh/zsh-history-search-multi-word/history-search-multi-word.plugin.zsh
    zcompile $out/fast-syntax-highlighting/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
    zcompile $out/autopair/share/zsh/zsh-autopair/autopair.zsh
    zcompile $out/pure/share/zsh/site-functions/async
    zcompile $out/pure/share/zsh/site-functions/prompt_pure_setup
    zcompile $out/history-substring-search/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
    zcompile $out/history-substring-search/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
    zcompile $out/forgit/share/zsh/zsh-forgit/forgit.plugin.zsh
    zcompile $out/emoji/emoji-cli.plugin.zsh
    zcompile $out/emoji/emoji-cli.zsh
    zcompile $out/clipboard/share/zsh/plugins/clipboard/clipboard.plugin.zsh
    zcompile $out/fzf-tab/share/fzf-tab/fzf-tab.plugin.zsh
    zcompile $out/fzf-tab/share/fzf-tab/fzf-tab.zsh
    zcompile $out/zsh-ssh/zsh-ssh.plugin.zsh
    zcompile $out/zsh-ssh/zsh-ssh.zsh
    '
  '';
in
{
  imports = [
    inputs.agenix.homeManagerModules.default
    inputs.nix-index-database.homeModules.nix-index
    inputs.catppuccin.homeModules.catppuccin
    inputs.hunk.homeManagerModules.default
  ];
  age = {
    identityPaths = [ "/home/${user}/.ssh/id_ed25519" ];
    secrets = {
      user-password.file = configPath "/secrets/user-password-hash.age";
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
    autoEnable = true;
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
      inputs.agenix.packages.${platformSystem}.default
      # platform
      pkgs.openssh
      pkgs.file
      pkgs.fastfetch
      pkgs.ncdu
      # shelltools
      pkgs.python3
      pkgs.pipx
      pkgs.python3Packages.markitdown
      pkgs.pandoc
      pkgs.trashy
      pkgs.trashy
      pkgs.file
      pkgs.psmisc
      pkgs.neovim
      pkgs.autossh
      pkgs.viddy
      pkgs.p7zip
      pkgs.entr
      pkgs.unzip
      pkgs.gnutar
      pkgs.gzip
      pkgs.bzip2
      pkgs.xz
      pkgs.findutils
      pkgs.coreutils
      pkgs.wget
      pkgs.pv
      pkgs.clipboard-jh
      pkgs.croc
      # devtools
      pkgs.bun
      pkgs.devbox
      pkgs.onefetch
      pkgs.tig
      (lib.hiPrio pkgs.git-extras)
      pkgs.ugit
      pkgs.zsh-forgit
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
      "${config.xdg.configHome}/yazi/run.zsh".source = configPath "/yazi/run.zsh";
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
          assume_yes = true;
          no_retry = true;
          no_self_update = true;
          disable = [
            "node"
            "nix"
            "home_manager"
            "system"
            "nix_helper"
            "yazi"
            "git_repos"
          ];
          set_title = false;
          cleanup = true;
        };
        commands = {
          "omp" = "omp update";
          "opencode" = "opencode upgrade";
          "hermes" = "hermes update";
          "devbox" = "devbox global update";
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
      settings."*" = { };
      extraConfig = ''
        # HostName test.com
        # Port 1234
        # User myuser
        # ForwardX11 yes
        # ForwardX11Trusted yes
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
      historyWidget.command = "";
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
    hunk = {
      enable = true;
      enableGitIntegration = true;
      settings = {
        theme = "graphite";
        mode = "split";
        line_numbers = true;
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
          local name="$1"
          shift
          local alias_dir="$PWD/.direnv/aliases"
          local target="$alias_dir/$name"
          local oldpath="$PATH"
          mkdir -p "$alias_dir"
          if ! [[ ":$PATH:" == *":$alias_dir:"* ]]; then
            PATH_add "$alias_dir"
          fi
          cat <<EOT > "$target"
        #!/usr/bin/env bash
        PATH="$oldpath:\$PATH"
        exec $@ "\$@"
        EOT
          chmod +x "$target"
        }
        # devbox
        use_devbox() {
          watch_file devbox.json devbox.lock
          eval "$(devbox shellenv --init-hook --install --no-refresh-alias)"
        }
        [ -f "$PWD/devbox.json" ] && {
          use devbox
        }
        source_env_if_exists .local.envrc
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
      shellWrapperName = "y";
      initLua = ''
        require("recycle-bin"):setup()
        require("archive-edit"):setup({ max_size = 100 * 1024 * 1024, max_files = 100 })
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
              url = "*.{docx,xlsx,pptx}";
              run = ''piper -- PYTHONWARNINGS=ignore::RuntimeWarning:pydub.utils markitdown "$1"'';
            }
            {
              url = "*.epub";
              run = ''piper -- pandoc "$1" -t plain'';
            }
            {
              mime = "{image,audio,video}/*";
              run = "mediainfo";
            }
            {
              mime = "application/x-subrip";
              run = "mediainfo";
            }
          ];
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
            url = "*.vtt";
            use = "less";
          }
          {
            url = "*.json";
            use = "jless";
          }
        ];
      };
      plugins = {
        archive-edit = ../../yazi/plugins/archive-edit.yazi;
        smart-tab = ../../yazi/plugins/smart-tab.yazi;
        chmod = pkgs.yaziPlugins.chmod;
        mediainfo = pkgs.yaziPlugins.mediainfo;
        piper = pkgs.yaziPlugins.piper;
        recycle-bin = pkgs.yaziPlugins.recycle-bin;
        toggle-pane = pkgs.yaziPlugins.toggle-pane;
      };
      keymap = {
        force = true;
        mgr = {
          prepend_keymap = [
            {
              on = ["R" "b"];
              run = "plugin recycle-bin";
              desc = "Open Recycle Bin";
            }
            {
              on = "<Tab>";
              run = "plugin smart-tab";
              desc = "create or switch tab";
            }
            {
              on = "i";
              run = "spot";
              desc = "Spot hovered file";
            }
            {
              on = "!";
              run = ''
                shell --block '$HOME/.config/yazi/run.zsh %s'
              '';
              desc = "Shell prefill";
            }
            {
              on = "T";
              run = "plugin toggle-pane min-preview";
              desc = "Toggle preview";
            }
            {
              on = "<Enter>";
              run = "plugin archive-edit enter";
              desc = "Enter dir or editable archive";
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
                "m"
                "s"
              ];
              run = "plugin archive-edit flush";
              desc = "Save editable archive";
            }
            {
              on = [
                "c"
                "m"
              ];
              run = "plugin chmod";
            }
          ];
        };
      };
    };
    zsh = {
      enable = true;
      dotDir = config.home.homeDirectory;
      enableCompletion = false;
      initContent = lib.mkBefore ''
        # Fix tmux socket permissions issue in WSL
        export TMUX_TMPDIR="/tmp"

        # Create tmux socket directory if it doesn't exist
        [ -n "$XDG_RUNTIME_DIR" ] && mkdir -p "$XDG_RUNTIME_DIR/tmux-$(id -u)" 2>/dev/null

        source ${compiledZshPlugins}/autosuggestions/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
        source ${compiledZshPlugins}/history-search-multi-word/share/zsh/zsh-history-search-multi-word/history-search-multi-word.plugin.zsh
        source ${compiledZshPlugins}/fast-syntax-highlighting/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
        source ${compiledZshPlugins}/autopair/share/zsh/zsh-autopair/autopair.zsh

        fpath+=(${compiledZshPlugins}/pure/share/zsh/site-functions)
        source ${compiledZshPlugins}/pure/share/zsh/site-functions/prompt_pure_setup

        source ${compiledZshPlugins}/history-substring-search/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh

        fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
        source ${zshMoreCompletions}/zsh-more-completions.plugin.zsh
        source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/completion.zsh
        source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/compfix.zsh

        source ${compiledZshPlugins}/forgit/share/zsh/zsh-forgit/forgit.plugin.zsh
        source ${compiledZshPlugins}/emoji/emoji-cli.plugin.zsh
        source ${compiledZshPlugins}/clipboard/share/zsh/plugins/clipboard/clipboard.plugin.zsh

        autoload -U compinit
        zmodload zsh/stat
        ZCOMPDUMP=${config.home.homeDirectory}/.zcompdump
        if [[ ! -f $ZCOMPDUMP ]] || (( $(date +%s) - $(zstat +mtime $ZCOMPDUMP 2>/dev/null || echo 0) > 86400 )); then
          compinit
        else
          compinit -C
        fi

        source ${compiledZshPlugins}/fzf-tab/share/fzf-tab/fzf-tab.plugin.zsh
        [ -n "$TMUX" ] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
        source ${compiledZshPlugins}/zsh-ssh/zsh-ssh.plugin.zsh

        # Patch _parse_config_file to use 'realpath -s' for symlink compatibility (e.g. home-manager)
        _parse_config_file() {
          setopt localoptions rematchpcre
          unsetopt nomatch
          local config_file_path=$(realpath -s "$1")
          while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ $line =~ ^[Ii]nclude[[:space:]]+(.*) ]] && (( $#match > 0 )); then
              local include_paths=(''${(z)match[1]})
              for raw_path in "''${include_paths[@]}"; do
                local expanded=''${~raw_path}
                if [[ "$expanded" != /* ]]; then
                  expanded="$(dirname "$config_file_path")/$expanded"
                fi
                for include_file_path in $~expanded; do
                  if [[ -f "$include_file_path" ]]; then
                    echo ""
                    _parse_config_file "$include_file_path"
                  fi
                done
              done
            else
              echo "$line"
            fi
          done < "$config_file_path"
        }

        source ~/.dotfiles/zsh/zshrc
        # zprof
      '';
      loginExtra = ''
        [ -f .local.zlogin ] && source .local.zlogin
        # [ -z "$TMUX" ] && tm
      '';
      shellAliases = {
        l = "ll";
        v = "nvim";
        pstree = "pstree -A";
        mv = "nocorrect mv";
        cp = "nocorrect cp";
        rm = "rm -i";
        jq = "yq";
        yt-dlp = "noglob yt-dlp";
        #omp = "LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib omp";
      };
    };
  };
}
