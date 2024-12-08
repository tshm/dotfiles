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
}
