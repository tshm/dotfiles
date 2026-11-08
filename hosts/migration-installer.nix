{ config, lib, pkgs, modulesPath, ... }:

let
  migrationConfig = config.services.btrfsMigration.config;
  migrationSource = pkgs.writeText "migrate-btrfs.py" (builtins.readFile ../scripts/migrate-btrfs.py);
  migrationCli = pkgs.writeShellApplication {
    name = "migrate-btrfs";
    runtimeInputs = with pkgs; [
      python3
      restic
      cifs-utils
      btrfs-progs
      e2fsprogs
      util-linux
      coreutils
      systemd
      nixos-install-tools
    ];
    text = ''
      exec ${pkgs.python3}/bin/python3 ${migrationSource} "$@"
    '';
  };
  migrationConfigFile = pkgs.writeText "btrfs-migration.json" (builtins.toJSON migrationConfig);
in {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  options.services.btrfsMigration.config = lib.mkOption {
    type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
    default = null;
    description = "Configuration for the dedicated Btrfs migration installer.";
  };

  config = {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    environment.systemPackages = [ migrationCli ];
    environment.etc."btrfs-migration.json".source =
      lib.mkIf (migrationConfig != null) migrationConfigFile;

    assertions = lib.optional (migrationConfig != null) {
      assertion = migrationConfig ? system && migrationConfig ? hardware_replacement;
      message = "services.btrfsMigration.config requires system and hardware_replacement store paths";
    };

    isoImage.storeContents =
      lib.optionals (migrationConfig != null) (
        lib.optional (migrationConfig ? system) migrationConfig.system
        ++ lib.optional (migrationConfig ? hardware_replacement) migrationConfig.hardware_replacement
      );

    environment.etc."issue".text = lib.mkAfter ''

      Btrfs migration USB: booting does NOT start a backup or erase a disk.
      Run `sudo migrate-btrfs` only when you are ready to begin.
    '';
  };
}
