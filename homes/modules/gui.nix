{
  user,
  config,
  pkgs,
  ...
}@args:

let
  configPath = pathStr: config.lib.file.mkOutOfStoreSymlink "/home/${user}/.dotfiles${pathStr}";
  tailscaleVicinaeExtension = pkgs.buildNpmPackage {
    pname = "vicinae-tailscale-control";
    version = "1.0.0";
    src = ../../x/vicinae/extensions/tailscale;
    npmDepsHash = "sha256-8In9NQ1StAzn2VSP3naNeymXzjkx/rPL0iBw4fAFops=";
    npmBuildFlags = [
      "--"
      "--out"
      "dist"
    ];
    doCheck = true;
    checkPhase = "npm test";
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r dist/. "$out/"
      runHook postInstall
    '';
  };
  /*
    platformSystem = pkgs.stdenv.hostPlatform.system;
    hyprlandGuiutils =
      args.hyprland.inputs."hyprland-guiutils".packages.${platformSystem}.hyprland-guiutils.overrideAttrs
        (old: {
          buildInputs = old.buildInputs ++ [ pkgs.pango ];
          postPatch = (old.postPatch or "") + ''
            substituteInPlace CMakeLists.txt \
              --replace-fail "  libdrm)" "  libdrm
            pango)"
          '';
        });
    hyprlandPackage =
      args.hyprland.packages.${platformSystem}.hyprland.override {
        hyprland-guiutils = hyprlandGuiutils;
      };
    hyprlandPortal =
      args.hyprland.packages.${platformSystem}.xdg-desktop-portal-hyprland.override
        {
          hyprland = hyprlandPackage;
        };
  */
in
{
  imports = [
    # args.noctalia.homeModules.default
    args.mango.hmModules.mango
    args.vicinae.homeManagerModules.default
    # args.hyprshell.homeModules.hyprshell
  ];
  fonts.fontconfig.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
  gtk = {
    enable = true;
    # iconTheme = {
    #   name = "Adwaita";
    #   package = pkgs.adwaita-icon-theme;
    # };
    # theme = {
    #   name = "Adapta-Nokto-Eta";
    #   package = pkgs.adapta-gtk-theme;
    # };
  };
  xdg = {
    enable = true;
    portal = {
      enable = true;
      extraPortals = [
        # hyprlandPortal
        pkgs.xdg-desktop-portal-gnome
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-termfilechooser
      ];
      config = {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
        /*
          hyprland = {
            default = [ "hyprland" "gnome" "gtk" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
            "org.freedesktop.impl.portal.Settings" = [ "gnome" ];
          };
        */
        mango = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Access" = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
          "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        };
        niri = {
          default = [
            "gnome"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Access" = [ "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
          "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        };
      };
    };

    configFile = {
      "fcitx5/config".text = ''
        [Hotkey]
        # Enumerate when holding modifier of Toggle key
        EnumerateWithTriggerKeys=False
        # Enumerate Input Method Forward
        EnumerateForwardKeys=
        # Enumerate Input Method Backward
        EnumerateBackwardKeys=
        # Skip first input method while enumerating
        EnumerateSkipFirst=False
        # Time limit in milliseconds for triggering modifier key shortcuts
        ModifierOnlyKeyTimeout=250

        [Hotkey/TriggerKeys]
        0=Zenkaku_Hankaku

        [Hotkey/ActivateKeys]
        0=Hangul

        [Hotkey/DeactivateKeys]
        0=Hangul_Hanja

        [Hotkey/AltTriggerKeys]
        0=Shift_L

        [Hotkey/EnumerateGroupForwardKeys]
        0=Super+space

        [Hotkey/EnumerateGroupBackwardKeys]
        0=Shift+Super+space

        [Hotkey/PrevPage]
        0=Up

        [Hotkey/NextPage]
        0=Down

        [Hotkey/PrevCandidate]
        0=Shift+Tab

        [Hotkey/NextCandidate]
        0=Tab

        [Hotkey/TogglePreedit]
        0=Control+Alt+P

        [Behavior]
        # Active By Default
        ActiveByDefault=False
        # Reset state on Focus In
        resetStateWhenFocusIn=No
        # Share Input State
        ShareInputState=No
        # Show preedit in application
        PreeditEnabledByDefault=True
        # Show Input Method Information when switch input method
        ShowInputMethodInformation=True
        # Show Input Method Information when changing focus
        showInputMethodInformationWhenFocusIn=False
        # Show compact input method information
        CompactInputMethodInformation=True
        # Show first input method information
        ShowFirstInputMethodInformation=True
        # Default page size
        DefaultPageSize=5
        # Override XKB Option
        OverrideXkbOption=False
        # Custom XKB Option
        CustomXkbOption=
        # Force Enabled Addons
        EnabledAddons=
        # Force Disabled Addons
        DisabledAddons=
        # Preload input method to be used by default
        PreloadInputMethod=True
        # Allow input method in the password field
        AllowInputMethodForPassword=False
        # Show preedit text when typing password
        ShowPreeditForPassword=False
        # Interval of saving user data in minutes
        AutoSavePeriod=30

      '';
      "fcitx5/profile".text = ''
        [Groups/0]
        # Group Name
        Name=Default
        # Layout
        Default Layout=jp
        # Default Input Method
        DefaultIM=mozc

        [Groups/0/Items/0]
        # Name
        Name=mozc
        # Layout
        # Layout=

        [GroupOrder]
        0=Default

      '';
    };

    dataFile = {
      "vicinae/scripts/cloudflare-warp-common.sh".source =
        configPath "/x/vicinae/scripts/cloudflare-warp-common.sh";
      "vicinae/scripts/cloudflare-warp-connect.sh".source =
        configPath "/x/vicinae/scripts/cloudflare-warp-connect.sh";
      "vicinae/scripts/cloudflare-warp-disconnect.sh".source =
        configPath "/x/vicinae/scripts/cloudflare-warp-disconnect.sh";
      "vicinae/scripts/reconnect-bluetooth-audio-device.sh".source =
        configPath "/x/connect-bluetooth-audio.sh";
      "vicinae/extensions/tailscale-control".source = tailscaleVicinaeExtension;
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "zen.desktop";
        "application/xhtml+xml" = "zen.desktop";
        "text/html" = "zen.desktop";
        "text/xml" = "zen.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "image/png" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
      };
    };
  };
  programs.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
    };
    settings = {
      faviconService = "twenty"; # twenty | google | none
      font.size = 14;
      popToRootOnClose = false;
      rootSearch.searchFiles = false;
      theme.name = "vicinae-dark";
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
    };
  };
  home = {
    pointerCursor.enable = true;
    packages = [
      (pkgs.callPackage ../apps/zen.nix { inherit pkgs; })
      (pkgs.callPackage ../apps/beeper.nix { inherit pkgs; })
      pkgs.wezterm
      pkgs.appimage-run
      pkgs.catppuccin-gtk
      pkgs.xdg-desktop-portal-termfilechooser
      # pkgs.hyprshade
      pkgs.gammastep
      # pkgs.deskflow
      # pkgs.input-leap
      pkgs.bluetuith
      args.waybar.packages.${pkgs.stdenv.hostPlatform.system}.waybar
      pkgs.mpv
      pkgs.mediainfo
      pkgs.swaynotificationcenter
      # pkgs.copyq
      pkgs.ripdrag
      pkgs.ags
      pkgs.vscode
      pkgs.neovide
      pkgs.brightnessctl
      pkgs.slurp
      pkgs.grim
      # extra
      pkgs.obsidian
      pkgs.brave
    ];
    file = {
      "${config.xdg.configHome}/wezterm/wezterm.lua".source = configPath "/wezterm/wezterm.lua";
      "${config.xdg.configHome}/waybar/".source = configPath "/x/waybar";
      "${config.xdg.configHome}/mpv/mpv.conf".source = configPath "/mpv.conf";
      # "${config.xdg.configHome}/niri/config.kdl".text = "include \"/home/${user}/.dotfiles/x/niri.kdl\"";
    };
  };
  programs = {
    yazi.settings = {
      opener.mpv = [{
        run = "mpv -- %s";
        orphan = true;
        desc = "mpv";
      }];
      open.prepend_rules = [{
        url = "*.{mkv,mp4}";
        use = "mpv";
      }];
    };
    # noctalia-shell = { enable = true; };
    # hyprshell = {
    #   enable = true;
    #   systemd.args = "-v";
    #   settings = {
    #     launcher = {
    #       max_items = 6;
    #       plugins.websearch = {
    #           enable = true;
    #           engines = [{
    #               name = "DuckDuckGo";
    #               url = "https://duckduckgo.com/?q=%s";
    #               key = "d";
    #           }];
    #       };
    #     };
    #   };
    # };
    rofi = {
      enable = true;
      settings = {
        terminal = "${pkgs.kitty}/bin/kitty";
        modi = "drun";
        show-icons = true;
        drun-display-format = "{icon} {name}";
        disable-history = false;
        hide-scrollbar = true;
        display-drun = "   Apps ";
        sidebar-mode = true;
      };
    };
    feh.enable = true;
  };
  catppuccin = {
    enable = true;
    accent = "green";
    cursors.enable = true;
  };
  wayland.windowManager.mango = {
    enable = true;
    settings = {
      source_optional = [
        "~/.dotfiles/x/mango/vars.conf"
        "~/.dotfiles/x/mango/general.conf"
      ];
    };
    topPrefixes = [ "source" ];
    autostart_sh = ''
      exec env WAYLAND_STARTUP_WAIT=15 bash ~/.dotfiles/x/wayland-startup-order.sh
    '';
  };
  /*
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      package = hyprlandPackage;
      portalPackage = hyprlandPortal;
      plugins = [
        # args.hyprland-plugins.packages.${platformSystem}.hyprscrolling  # FIXME: requires Hyprland source headers
        # args.hyprland-plugins.packages.${platformSystem}.hyprexpo  # FIXME: incompatible with current Hyprland
      ];
      settings = {
        source = [
          "~/.dotfiles/x/hyprland/vars.conf"
          "~/.dotfiles/x/hyprland/general.conf"
        ];
        device = [
          {
            name = "lenovo-thinkpad-compact-usb-keyboard-with-trackpoint-1";
            sensitivity = 1.0;
          }
          {
            name = "lenovo-thinkpad-compact-usb-keyboard-with-trackpoint-3";
            sensitivity = 1.0;
          }
          {
            name = "elecom-trackball-mouse-huge-trackball-1";
            sensitivity = 1.0;
          }
          {
            name = "syna3290:01-06cb:cd4f-touchpad";
            sensitivity = 0.0;
          }
        ];
        exec-once = [
          "[workspace 2] zen"
          "[workspace 1 silent] beeper"
          "[workspace 2 silent] $terminal"
        ];
      };
    };
  */
}
