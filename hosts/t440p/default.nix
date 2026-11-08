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

  environment.etc."crypttab".text = ''
    cold UUID=ff5c12c7-d770-4f2d-8a39-0799bd4d0499 /var/lib/usb-cold/key luks,noauto,nofail,x-systemd.device-timeout=5s
  '';

  systemd.mounts = [
    {
      what = "/dev/mapper/cold";
      where = "/mnt/cold";
      type = "ext4";
      options = "nodev,nosuid,noatime";
      requires = [ "systemd-cryptsetup@cold.service" ];
      after = [ "systemd-cryptsetup@cold.service" ];
      mountConfig = {
        DirectoryMode = "0000";
        TimeoutSec = "10s";
      };
    }
  ];

  systemd.automounts = [
    {
      where = "/mnt/cold";
      wantedBy = [ "multi-user.target" ];
      automountConfig.DirectoryMode = "0000";
    }
  ];


  services.restic.backups.home = {
    repository = "sftp:dmz:/tank/bkup";
    passwordFile = "/var/lib/restic/home-password";
    paths = [ "/home/tshm" "/var/lib/usb-cold" ];
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
