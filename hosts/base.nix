{ host
, user ? "tshm"
, baselocale ? "en_US.UTF-8"
, locale ? "ja_JP.UTF-8"
}:
{ pkgs, config, lib, ... }:

let
  useHibernation = builtins.length config.swapDevices > 0;
in
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    kernelParams = lib.mkIf useHibernation [ "mem_sleep_default=deep" ];
    resumeDevice = lib.mkIf useHibernation (builtins.head config.swapDevices).device;
    # initrd.prepend = [ "./acpi_override" ];
  };

  networking.hostName = host;
  networking.networkmanager.enable = true;
  console.useXkbConfig = true;

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 70;
    };
  };
  services.logind.extraConfig = ''
    #################################################
    HandlePowerKey=${if useHibernation then "hibernate" else "suspend"}
    # HandlePowerKey=poweroff
    HandleLidSwitch=suspend
    HandleLidSwitchExternalPower=suspend
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
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
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

  # required for Codeium to work
  programs.nix-ld = {
    enable = true;
    libraries = [ ];
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

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
      ${user} = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" "syncthing" "docker" ];
      };
    };
  };
  services.displayManager.sessionPackages = [
    ((pkgs.writeTextDir "share/wayland-sessions/zsh.desktop" ''
      [Desktop Entry]
      Name = zsh
      Exec = zsh
      Type = Application
      DesktopNames = zsh
      Terminal = true
    '').overrideAttrs (_: { passthru.providedSessions = [ "zsh" ]; }))
  ];

  virtualisation = {
    podman = {
      enable = true;
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
    user = user;
    dataDir = "/home/${user}/.syncthing_data";
    configDir = "/home/${user}/.config/syncthing";
    overrideDevices = false;
    overrideFolders = false;
    settings.gui = {
      user = user;
    };
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [
    # base tools
    pkgs.inxi
    pkgs.gnumake
    pkgs.vim
    pkgs.neovim
    pkgs.curl
    pkgs.git
    pkgs.gcc
    pkgs.busybox
    # container
    pkgs.podman-tui
    pkgs.podman-compose
    # desktop environment related
    pkgs.cloudflare-warp
    pkgs.p7zip
    pkgs.imagemagick
    pkgs.ffmpegthumbnailer
  ];

  services.openssh.enable = true;
  # services.flatpak.enable = true;
  # system.fsPackages = [ pkgs.bindfs ];
  # fileSystems =
  #   let
  #     mkRoSymBind = path: {
  #       device = path;
  #       fsType = "fuse.bindfs";
  #       options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
  #     };
  #   in
  #   {
  #     "/usr/share/fonts" = mkRoSymBind "${config.system.path}/share/X11/fonts";
  #     "/usr/local/share/fonts" = mkRoSymBind "/run/current-system/sw/share/X11/fonts";
  #   };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.05";
}
