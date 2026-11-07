{ nixos-hardware, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    nixos-hardware.nixosModules.lenovo-thinkpad-t440p
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  systemd.oomd.enableUserSlices = true;
  zramSwap.enable = true;

  services.auto-cpufreq.enable = true;
  services.greetd.enable = false;
  services.syncthing.enable = false;
  services.kanata.enable = false;


  services.restic.backups.home = {
    repository = "sftp:dmz:/tank/bkup";
    passwordFile = "/var/lib/restic/home-password";
    paths = [ "/home/tshm" ];
    initialize = true;
    extraOptions = [
      ''sftp.command="${pkgs.util-linux}/bin/runuser -u tshm -- ${pkgs.openssh}/bin/ssh -o BatchMode=yes -o ClearAllForwardings=yes -o ConnectTimeout=30 dmz -s sftp"''
    ];
    timerConfig = {
      OnCalendar = "*-*-* 03:00:00";
      RandomizedDelaySec = "30m";
      Persistent = true;
    };
  };
  services.logind.settings = {
    Login = {
      HandlePowerKey = "poweroff";
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=192.168.84.0/24"
    ];
  };
}
