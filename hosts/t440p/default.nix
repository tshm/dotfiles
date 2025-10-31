{ nixos-hardware, ... }:
{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-t440p
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  services.auto-cpufreq.enable = true;
  services.greetd.enable = false;
  services.syncthing.enable = false;
  services.kanata.enable = false;

  services.logind.settings = {
    Login = {
      HandlePowerKey = "poweroff";
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
  };
}
