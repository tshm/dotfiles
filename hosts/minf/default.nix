{ nixos-hardware, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./fingerprint.nix
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-gpu-intel
  ];
}
