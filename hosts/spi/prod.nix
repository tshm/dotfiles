{ user, ... }:

{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/mnt/data" = {
      device = "/dev/sda1";
      fsType = "ext4";
      options = [ "defaults" "nofail" ];
    };
    "/mnt/nfs" = {
      device = "192.168.1.1:/share/nfs";
      fsType = "nfs";
      options = [ "defaults" "noauto" "nofail" ];
    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "10 *     * * *   ${user}   . /etc/profile && /mnt/data/srv/duck.sh"
      "30 */2   * * *   ${user}   . /etc/profile && /mnt/data/yt/Video/dl.sh"
    ];
  };

  networking = {
    hostName = "spi";
    interfaces.eth0.useDHCP = true;

    # useNetworkd = false;
    # interfaces = {
    #   eth0 = {
    #     useDHCP = false;
    #     ipv4.addresses = [{
    #       address = "192.168.1.113";
    #       prefixLength = 24;
    #     }];
    #   };
    # };
    #
    # defaultGateway = {
    #   address = "192.168.1.1";
    #   interface = "eth0";
    # };
    # nameservers = [ "8.8.8.8" "1.1.1.1" ];

    wireless = {
      enable = true;
      networks = {
      };
    };
  };

  services.syncthing.enable = true;
  virtualisation.docker.enable = true;
}
