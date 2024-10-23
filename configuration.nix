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

  location.enable = true;
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
    enabled = "fcitx5";
    fcitx5.addons = [ pkgs.fcitx5-mozc pkgs.fcitx5-gtk ];
  };
  services.xserver.xkb = { # Configure keymap in X11
    layout = "jp";
    variant = "";
  };

  # required for Codeium to work
  programs.nix-ld = {
    enable = true;
    libraries = [];
  };

  programs.hyprland = {
    enable = true;
  };
  fonts = {
    enableDefaultPackages = true;
    packages = [ # pkgs.nerdfonts
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
    pkgs.cargo
      pkgs.hyprland
      pkgs.wl-clipboard

      pkgs.cloudflare-warp

      pkgs.ffmpegthumbnailer
      pkgs.p7zip
      pkgs.poppler
      pkgs.imagemagick

      pkgs.mpv
      pkgs.wofi
      pkgs.waybar
      pkgs.kitty
      pkgs.wezterm
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-hyprland
      pkgs.mesa.drivers

      pkgs.dconf
      pkgs.neovim
      pkgs.gnumake
      pkgs.vim
      pkgs.curl
      pkgs.git
      pkgs.gcc
      pkgs.zig
      ];

  services.openssh.enable = true;
  services.flatpak.enable = true;

  system.stateVersion = "24.05";
}
