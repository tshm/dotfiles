{ host
, forServer ? false
, user ? "tshm"
, baselocale ? "en_US.UTF-8"
, locale ? "ja_JP.UTF-8"
}:
{ config, lib, nixsettings, agenix, pkgs ? config.nixpkgs.pkgs, ... }:

let
  useHibernation = builtins.length config.swapDevices > 0;
  isRaspberryPi = host == "spi";
in
{
  imports = [
    agenix.nixosModules.default
  ];
  boot = {
    binfmt.emulatedSystems = lib.mkIf (!isRaspberryPi) [ "aarch64-linux" ];
    loader = {
      systemd-boot = {
        enable = lib.mkIf (!isRaspberryPi && host != "tp") true;
        configurationLimit = 10;
      };
      efi = lib.mkIf (!isRaspberryPi && host != "tp") {
        canTouchEfiVariables = true;
      };
      timeout = 3;
    };
    kernelParams = lib.mkIf useHibernation [ "mem_sleep_default=deep" ];
    resumeDevice = lib.mkIf useHibernation (builtins.head config.swapDevices).device;
    # initrd.prepend = [ "./acpi_override" ];
  };
  nix.settings = nixsettings // {
    keep-derivations = true;
    keep-outputs = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  networking.hostName = host;
  networking.networkmanager.enable = lib.mkIf (!isRaspberryPi) true;
  console.useXkbConfig = true;

  services.tlp = lib.mkIf (!forServer) {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 70;
    };
  };
  services.logind.settings = lib.mkIf (!forServer) {
    Login = {
      HandlePowerKey = if useHibernation then "hibernate" else "suspend";
      HandleLidSwitch = lib.mkIf (!isRaspberryPi) "suspend";
      HandleLidSwitchExternalPower = lib.mkIf (!isRaspberryPi) "suspend";
    };
  };

  services.greetd = lib.mkIf (!forServer) {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
        user = "greeter";
      };
    };
  };
  systemd.services.greetd.serviceConfig = lib.mkIf (!forServer) {
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

  # required for Codeium to work
  programs.nix-ld = {
    enable = true;
    libraries = [ ];
  };

  programs.appimage = {
    enable = !forServer;
    binfmt = !forServer;
  };

  security.polkit.enable = lib.mkIf (!isRaspberryPi) true;
  security.rtkit.enable = lib.mkIf (!isRaspberryPi) true;
  security.sudo.wheelNeedsPassword = false;

  # cloudflare-warp
  systemd.packages = lib.mkIf (!forServer) [
    pkgs.cloudflare-warp
  ];
  systemd.targets.multi-user.wants = lib.mkIf (!forServer) [
    "warp-svc.service"
  ];

  programs.zsh.enable = true;
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      ${user} = {
        isNormalUser = true;
        # password = null;
        hashedPasswordFile = config.age.secrets.user-password.path;
        extraGroups = [ "networkmanager" "wheel" "syncthing" "podman" ];
      };
    };
  };
  services.displayManager.sessionPackages = lib.mkIf (!forServer) [
    ((pkgs.writeTextDir "share/wayland-sessions/zsh.desktop" ''
      [Desktop Entry]
      Name = zsh
      Exec = zsh
      Type = Application
      DesktopNames = zsh
      Terminal = true
    '').overrideAttrs (_: { passthru.providedSessions = [ "zsh" ]; }))
  ];
  services.tailscale = {
    enable = lib.mkDefault true;
    useRoutingFeatures = "both";
  };

  virtualisation = {
    podman = lib.mkIf (!isRaspberryPi) {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    docker = lib.mkIf (!isRaspberryPi) {
      enable = false;
      logDriver = "json-file";
    };
  };

  programs.nh = {
    enable = true;
    flake = "/home/${user}/.dotfiles";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 10d";
    };
  };
  services.kanata = lib.mkIf (!forServer) {
    enable = true;
    keyboards = {
      internalKeyboard = {
        # devices = [
        #   "/dev/input/by-id/usb-Lenovo_ThinkPad_Compact_USB_Keyboard_with_TrackPoint-event-kbd"
        # ];
        extraDefCfg = "process-unmapped-keys yes";
        config = builtins.readFile ./../kanata/map.kbd;
      };
    };
  };

  services.syncthing = {
    enable = lib.mkDefault true;
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
  ] ++ lib.optionals (!isRaspberryPi) [
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

  system.stateVersion = "24.05";

  # Agenix configuration for secrets
  age.secrets.user-password.file = "/home/${user}/.dotfiles/secrets/user-password.age";
  age.identityPaths = [ "/home/${user}/.ssh/id_ed25519" ];
}
