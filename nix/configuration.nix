{ pkgs, ... }:

let
  jalocale = "ja_JP.UTF-8";
  locale = "en_US.UTF-8";
in
{
  imports = [
    ./hardware-configuration.nix
  ];
  hardware.graphics.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "minf";
  networking.networkmanager.enable = true;
  console.useXkbConfig = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session";
        user = "greeter";
      };
    };
  };
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "weekly";
  };

  location.provider = "geoclue2";
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = locale;
    LC_IDENTIFICATION = locale;
    LC_MEASUREMENT = jalocale;
    LC_MONETARY = jalocale;
    LC_NAME = locale;
    LC_NUMERIC = locale;
    LC_PAPER = jalocale;
    LC_TELEPHONE = jalocale;
    LC_TIME = locale;
  };
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

  # required for Codeium to work
  programs.nix-ld = {
    enable = true;
    libraries = [ ];
  };

  security.polkit.enable = true;
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
  # environment.etc."gtk-3.0/settings.ini" = ''
  #   [Settings]
  #   gtk-application-prefer-dark-theme=1
  # '';
  programs.hyprland = {
    enable = true;
  };
  # xdg.portal = {
  #   enable = true;
  #   extraportals = [ pkgs.xdg-desktop-portal-gtk ];
  # };
  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.nerdfonts
      pkgs.noto-fonts-cjk-serif
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-emoji
      pkgs.fira-code
      pkgs.source-han-serif
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
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  systemd.packages = [
    pkgs.cloudflare-warp
  ];
  systemd.targets.multi-user.wants = [
    "warp-svc.service"
  ];

  users.users.tshm = {
    isNormalUser = true;
    description = "tshm";
    extraGroups = [ "networkmanager" "wheel" "syncthing" ];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings.gui = {
      user = "tshm";
    };
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [
    # base tools
    pkgs.gnumake
    pkgs.vim
    pkgs.neovim
    pkgs.curl
    pkgs.git
    pkgs.gcc
    # desktop environment related
    pkgs.hyprland
    pkgs.wl-clipboard
    pkgs.cloudflare-warp
    pkgs.p7zip
    pkgs.poppler
    pkgs.imagemagick
    pkgs.mpv
    pkgs.wofi
    pkgs.waybar
    pkgs.kitty
    pkgs.wezterm
    # pkgs.adwaita-qt
    # pkgs.gnome3.adwaita-icon-theme
    # pkgs.lxappearance
    #
    pkgs.polkit_gnome
    #pkgs.lxqt.lxqt-policykit
    pkgs.dconf
    pkgs.qt6ct
    pkgs.ffmpegthumbnailer
    pkgs.xdg-desktop-portal
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-wlr
    pkgs.xdg-desktop-portal-hyprland
    pkgs.mesa.drivers
  ];

  services.openssh.enable = true;
  services.flatpak.enable = true;

  system.stateVersion = "24.05";
}
