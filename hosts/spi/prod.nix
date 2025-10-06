{ nixpkgs, crossPkgs, agenix, user, config, ... }:

{
  imports = [
    agenix.nixosModules.default
  ];
  age.secrets.wifi-secrets.file = "/home/${user}/.dotfiles/secrets/wifi-secrets.age";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/mnt/data" = {
      device = "/dev/sda1";
      fsType = "ext4";
      options = [ "defaults" ];
    };
    "/mnt/nfs" = {
      device = "192.168.1.1:/share/nfs";
      fsType = "nfs";
      options = [ "defaults" ];
    };
  };

   networking = {
     hostName = "spi";
     # useNetworkd = false;
     interfaces = {
       eth0 = {
         useDHCP = false;
         ipv4.addresses = [{
           address = "192.168.1.113";
           prefixLength = 24;
         }];
       };
     };

     defaultGateway = {
       address = "192.168.1.1";
       interface = "eth0";
     };

     nameservers = [ "8.8.8.8" "1.1.1.1" ];

    wireless = {
      enable = true;
      networks =
        let
          wifiSecrets = builtins.fromJSON (builtins.readFile config.age.secrets.wifi-secrets.path);
        in {
          ${wifiSecrets.ssid} = { psk = wifiSecrets.psk; };
        };
    };
  };

  services.syncthing.enable = true;
  virtualisation.docker.enable = true;

  # Basic packages only
  environment.systemPackages = [
    crossPkgs.curl
    crossPkgs.git
    crossPkgs.busybox
  ];

  system.stateVersion = "24.05";
}
