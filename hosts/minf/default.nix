{ nixpkgs, nixos-hardware, ... } @ args:
{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-gpu-intel
  ];
}
