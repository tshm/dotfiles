{ pkgs, ... }:

{
  hardware.graphics.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [
      pkgs.fcitx5-mozc
      pkgs.fcitx5-gtk
    ];
  };
  services.xserver.xkb = {
    # Configure keymap in X11
    layout = "jp";
    variant = "";
  };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    enable = true;
    description = "Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      #Type = "Simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 10;
    };
  };

  programs.dconf = {
    enable = true;
  };
  programs.hyprland = {
    enable = true;
  };
  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.nerd-fonts.fira-code
      pkgs.noto-fonts-cjk-serif
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-emoji
      pkgs.fira-code
      pkgs.source-han-serif
      pkgs.font-awesome
    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK JP" ];
        serif = [ "Noto Serif CJK JP" ];
      };
    };
  };
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  services.xserver = {
    enable = true;
    displayManager.startx.enable = false;
    displayManager.gdm.enable = false;
    displayManager.lightdm.enable = false;
    desktopManager.gnome.enable = false;
  };
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = [
    pkgs.mesa.drivers
    # desktop environment related
    pkgs.hyprland
    pkgs.wl-clipboard
    pkgs.p7zip
    pkgs.poppler
    pkgs.imagemagick
    pkgs.pavucontrol
    pkgs.waybar
    pkgs.kitty
    pkgs.polkit_gnome
    #pkgs.lxqt.lxqt-policykit
    pkgs.libnotify
    pkgs.dconf
    pkgs.qt6ct
    ## Flatpak
    # pkgs.xdg-desktop-portal
    # pkgs.xdg-desktop-portal-gtk
    # pkgs.xdg-desktop-portal-wlr
    # pkgs.xdg-desktop-portal-hyprland
  ];
}
