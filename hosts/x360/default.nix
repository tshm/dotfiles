{ nixos-hardware, ... }:
{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-pc-laptop
    nixos-hardware.nixosModules.common-pc-laptop-ssd
    nixos-hardware.nixosModules.common-cpu-amd
    nixos-hardware.nixosModules.common-gpu-amd
  ];
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
  boot.blacklistedKernelModules = [ "snd_sof" "snd_sof_amd_acp" "snd_sof_pci" ];

  # Audio device configuration
  hardware.pulseaudio.enable = false;
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


}
