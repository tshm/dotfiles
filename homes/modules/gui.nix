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
      pkgs.vscode-fhs
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
    extraConfig = ''
      # extraConfig
      source = ~/.dotfiles/x/hyprland/vars.conf
      source = ~/.dotfiles/x/hyprland/general.conf
    '';
  };
}
