{ user, config, pkgs, system, ... } @ inputs:

let
  configPath = pathStr: config.lib.file.mkOutOfStoreSymlink "/home/${user}/.dotfiles${pathStr}";
in
{
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
  home = {
    packages = [
      inputs.hyprswitch.packages."${system}".default
      inputs.zen-browser.packages."${system}".default
      pkgs.wezterm
      pkgs.appimage-run
      pkgs.catppuccin-gtk
      pkgs.hyprshade
      # pkgs.deskflow
      # pkgs.input-leap
      pkgs.bluetuith
      pkgs.waybar
      pkgs.mediainfo
      pkgs.papirus-icon-theme
      pkgs.swaynotificationcenter
      pkgs.copyq
      pkgs.ripdrag
      pkgs.ags
      pkgs.beeper
      pkgs.vscode
      pkgs.neovide
      pkgs.pamixer
      pkgs.brightnessctl
      pkgs.slurp
      pkgs.grim
      # extra
      pkgs.brave
    ];
    file = {
      "${config.xdg.configHome}/wezterm/wezterm.lua".source = configPath "/wezterm/wezterm.lua";
      "${config.xdg.configHome}/waybar/".source = configPath "/x/waybar";
    };
  };
  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
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
    mpv = {
      enable = true;
      config = {
        vo = "gpu";
        hwdec = "auto";
        speed = "1.21";
        sub-auto = "fuzzy";
        save-position-on-quit = "yes";
      };
    };
    feh.enable = true;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland; # use system installed binary
    settings = {
      source = [
        "~/.dotfiles/x/hyprland/vars.conf"
        "~/.dotfiles/x/hyprland/general.conf"
      ];
      device = [
        { name = "lenovo-thinkpad-compact-usb-keyboard-with-trackpoint-1"; sensitivity = 1.0; }
        { name = "lenovo-thinkpad-compact-usb-keyboard-with-trackpoint-3"; sensitivity = 1.0; }
        { name = "elecom-trackball-mouse-huge-trackball-1"; sensitivity = 1.0; }
        { name = "syna3290:01-06cb:cd4f-touchpad"; sensitivity = 0.0; }
      ];
      exec-once = [
        "[workspace 2] zen"
        # temporary fix...
        "[workspace 1 silent] beeper"
        "[workspace 2 silent] $terminal"
      ];
    };
  };
}
