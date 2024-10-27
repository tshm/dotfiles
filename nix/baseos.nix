{ hostname
, username ? "tshm"
, baselocale ? "en_US.UTF-8"
, locale ? "ja_JP.UTF-8"
}:
{ pkgs, config, ... }:

{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };

  hardware.graphics.enable = true;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  console.useXkbConfig = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

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
  i18n.defaultLocale = baselocale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = baselocale;
    LC_IDENTIFICATION = baselocale;
    LC_MEASUREMENT = locale;
    LC_MONETARY = locale;
    LC_NAME = baselocale;
    LC_NUMERIC = baselocale;
    LC_PAPER = locale;
    LC_TELEPHONE = locale;
    LC_TIME = baselocale;
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
  programs.hyprland = {
    enable = true;
  };
  fonts = {
    enableDefaultPackages = true;
    packages = [
      pkgs.nerdfonts
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
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # cloudflare-warp
  systemd.packages = [
    pkgs.cloudflare-warp
  ];
  systemd.targets.multi-user.wants = [
    "warp-svc.service"
  ];

  programs.zsh.enable = true;
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      ${username} = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" "syncthing" "docker" ];
      };
    };
  };

  virtualisation = {
    podman = {
      enable = false;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    docker = {
      enable = false;
      logDriver = "json-file";
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = username;
    dataDir = "/home/${username}/.syncthing_data";
    configDir = "/home/${username}/.config/syncthing";
    overrideDevices = false;
    overrideFolders = false;
    settings.gui = {
      user = username;
    };
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [
    # base tools
    pkgs.gnumake
    pkgs.vim
    pkgs.neovim
    pkgs.curl
    pkgs.git
    pkgs.gcc
    # container
    pkgs.podman-tui
    pkgs.podman-compose
    # desktop environment related
    pkgs.hyprland
    pkgs.wl-clipboard
    pkgs.cloudflare-warp
    pkgs.p7zip
    pkgs.poppler
    pkgs.imagemagick
    pkgs.mpv
    pkgs.wofi
    pkgs.pavucontrol
    #pkgs.mako
    pkgs.waybar
    pkgs.kitty
    pkgs.wezterm
    #
    pkgs.polkit_gnome
    #pkgs.lxqt.lxqt-policykit
    pkgs.libnotify
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

  system.fsPackages = [ pkgs.bindfs ];
  fileSystems =
    let
      mkRoSymBind = path: {
        device = path;
        fsType = "fuse.bindfs";
        options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
      };
    in
    {
      "/usr/share/fonts" = mkRoSymBind "${config.system.path}/share/X11/fonts";
      "/usr/local/share/fonts" = mkRoSymBind "/run/current-system/sw/share/X11/fonts";
    };

  system.stateVersion = "24.05";
}
