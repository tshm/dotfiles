{ lib, nixos-hardware, pkgs, ... }:
let
  libfprint = pkgs.libfprint.overrideAttrs (old: {
    version = "1.94.9-synatlsmoc";
    src = pkgs.fetchurl {
      url = "https://github.com/vojtapl/libfprint/archive/28d391839b9d9f71e2952528894d730c28d3ec4b.tar.gz";
      hash = "sha256-8rZUiQAmPFMRHhnwYu5mRQKVmT2LK3Q3vn0hJJD2uE4=";
    };
    postPatch = old.postPatch + ''
      for id in 00c9 00d8 00e7 00ff; do
        substituteInPlace libfprint/fprint-list-udev-hwdb.c --replace-fail \
          "  { .vid = 0x06cb, .pid = 0x$id }," ""
      done
    '';
    mesonFlags = (lib.filter (flag: !(lib.hasPrefix "-Ddrivers=" flag)) old.mesonFlags)
      ++ [ "-Ddrivers=synatlsmoc,virtual_image,virtual_device,virtual_device_storage" ];
  });
  fprintd = (pkgs.fprintd.override { inherit libfprint; }).overrideAttrs (old: {
    patches = old.patches ++ [
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/vojtapl/synaTudorMiS/b700a346e735e429f757828bffe7fbbdaf9f9415/libfprint/fprintd-load-store-persistent-data-from-device.patch";
        hash = "sha256-Oo3++qxm+w/7wynfFuy1EdXAE8xl716a7SrjPLhQFQA=";
      })
    ];
  });
in {
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-gpu-amd
  ];
  # Fingerprints are only for local login, not privilege escalation or locking.
  options.security.pam.services = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      fprintAuth = lib.mkDefault false;
    });
  };
  config = {
  services.fprintd = {
    enable = true;
    package = fprintd;
  };
  security.pam.services.login.fprintAuth = true; # greetd includes this stack.

  hardware.sensor.iio.enable = true;

  # Audio configuration for PC speakers
  boot.kernelModules = [ "snd-hda-intel" ];
  boot.extraModprobeConfig = ''
    # Force HDA Intel codec and enable internal speakers for ALC285
    options snd-hda-intel model=auto probe_mask=1 position_fix=0
    # Specific ALC285 model for HP laptops - enable jack detection
    options snd-hda-codec-realtek model=hp-headset-mic
    # Enable internal speakers and jack detection
    options snd-hda-intel enable_msi=1 jackpoll_ms=5000
  '';
  # tiny_power_button bypasses logind and powers off when the button wakes us.
  boot.blacklistedKernelModules = [
    "snd_sof" "snd_sof_amd_acp" "snd_sof_pci" "tiny_power_button"
  ];

  # Audio device configuration
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = false;
    wireplumber = {
      enable = true;
      extraConfig = {
        "10-alsa-card" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                { "device.name" = "~alsa_card.pci-0000_04_00.6"; }
              ];
              actions = {
                update-props = {
                  "device.description" = "PC Speakers";
                  "api.alsa.use-acp" = true;
                  "api.acp.auto-profile" = true;
                  "api.acp.auto-port" = true;
                };
              };
            }
          ];
        };
        "10-auto-switch-headphones" = {
          "wireplumber.settings" = {
            "device.routes.default-sink-route" = "headphones";
          };
        };
        "10-bluetooth-enhancements" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
          };
        };
      };
    };
  };


  };
}
