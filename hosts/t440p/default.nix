{ nixos-hardware, ... }:
{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-t440p
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

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

  services.tailscale.extraSetFlags = [ "--advertise-exit-node" ];
}
