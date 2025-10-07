{ nixos-hardware, nixpkgs, crossPkgs, user, ... }:

{
  imports = [
    nixos-hardware.nixosModules.raspberry-pi-4
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot = {
    loader = {
      grub.enable = false;
      grub.devices = [ "/dev/disk/by-label/NIXOS_SD" ];
      generic-extlinux-compatible.enable = true;
    };
    kernelParams = [ "console=ttyAMA0,115200n8" "console=tty1" ];
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];
    initrd.includeDefaultModules = false;
    kernelPackages = crossPkgs.linuxKernel.packages.linux_6_6;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

   networking.hostName = "spi";

  services.tlp.enable = false; # Not needed on Raspberry Pi
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "ignore"; # No lid on Raspberry Pi
    HandleLidSwitchExternalPower = "ignore";
  };
  services.getty.autologinUser = user;

  services.greetd.enable = false;
  services.kanata.enable = false;

  environment.systemPackages = [
    crossPkgs.libraspberrypi
    crossPkgs.raspberrypi-eeprom
  ];
}
