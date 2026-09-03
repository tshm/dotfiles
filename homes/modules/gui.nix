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

    dataFile = {
      "vicinae/scripts/cloudflare-warp-common.sh".source =
        configPath "/x/vicinae/scripts/cloudflare-warp-common.sh";
      "vicinae/scripts/cloudflare-warp-connect.sh".source =
        configPath "/x/vicinae/scripts/cloudflare-warp-connect.sh";
      "vicinae/scripts/cloudflare-warp-disconnect.sh".source =
        configPath "/x/vicinae/scripts/cloudflare-warp-disconnect.sh";
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
      terminal = "${pkgs.kitty}/bin/kitty";
      extraConfig = {
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
      "source-optional" = [
        "~/.dotfiles/x/mango/vars.conf"
        "~/.dotfiles/x/mango/general.conf"
      ];
    };
    topPrefixes = [ "source" ];
    autostart_sh = ''
      exec bash ~/.dotfiles/x/wayland-startup-order.sh
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
