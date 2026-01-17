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

  # Fix for Realtek ALC285 audio codec - force use of snd_hda_intel
  boot.kernelModules = [ "snd-hda-intel" ];
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=auto
    options snd-hda-intel probe_mask=1
  '';
  boot.blacklistedKernelModules = [ "snd_sof" "snd_sof_amd_acp" "snd_sof_pci" ];
}
