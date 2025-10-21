{
  user,
  config,
  pkgs,
  ...
}@args:

let
  configPath = pathStr: config.lib.file.mkOutOfStoreSymlink "/home/${user}/.dotfiles${pathStr}";
in
{
  imports = [
    args.mango.hmModules.mango
    # args.vicinae.homeManagerModules.default
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
        args.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-termfilechooser
      ];
      config = {
        common = {
          default = [ "hyprland" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
        hyprland = {
          default = [ "hyprland" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };
      };
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
  # services.vicinae = {
  #   enable = true;
  #   autoStart = true;
  #   settings = {
  #     faviconService = "twenty"; # twenty | google | none
  #     font.size = 14;
  #     popToRootOnClose = false;
  #     rootSearch.searchFiles = false;
  #     theme.name = "vicinae-dark";
  #     window = {
  #       csd = true;
  #       opacity = 0.95;
  #       rounding = 10;
  #     };
  #   };
  # };
  home = {
    packages = [
      (pkgs.callPackage ../apps/zen.nix { inherit pkgs; })
      (pkgs.callPackage ../apps/beeper.nix { inherit pkgs; })
      pkgs.wezterm
      pkgs.appimage-run
      pkgs.catppuccin-gtk
      pkgs.xdg-desktop-portal-termfilechooser
      pkgs.hyprshade
      # pkgs.gammastep
      # pkgs.deskflow
      # pkgs.input-leap
      pkgs.bluetuith
      pkgs.waybar
      pkgs.mpv
      pkgs.mediainfo
      pkgs.swaynotificationcenter
      pkgs.copyq
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
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = args.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = args.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    plugins = [
      args.hyprland-plugins.packages.${pkgs.system}.hyprscrolling
      args.hyprland-plugins.packages.${pkgs.system}.hyprexpo
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
}
