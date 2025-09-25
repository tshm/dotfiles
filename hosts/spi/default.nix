{ config, lib, nixos-hardware, nixpkgs, crossPkgs, ... }:

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
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    # "/mnt/data" = {
    #   device = "/dev/sda1";
    #   fsType = "ext4";
    #   options = [ "defaults" ];
    # };
    # "/mnt/nfs" = {
    #   device = "192.168.1.1:/share/nfs";
    #   fsType = "nfs";
    #   options = [ "defaults" ];
    # };
  };

  networking = {
    hostName = "spi";
    interfaces.eth0.useDHCP = true;
  };

  # Remove x86_64 specific settings that don't work on ARM
  services.tlp.enable = false; # Not needed on Raspberry Pi
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "ignore"; # No lid on Raspberry Pi
    HandleLidSwitchExternalPower = "ignore";
  };

  # Disable services that don't make sense on Raspberry Pi
  services.greetd.enable = false;
  services.syncthing.enable = false;
  services.kanata.enable = false;
  virtualisation.podman.enable = false;
  virtualisation.docker.enable = false;

   # Basic packages only
   environment.systemPackages = [
     crossPkgs.curl
     crossPkgs.git
     crossPkgs.busybox
   ];

  system.stateVersion = "24.05";
}
