{ nixos-hardware, twindesk, user, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./fingerprint.nix
    twindesk.nixosModules.default
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-cpu-intel
    nixos-hardware.nixosModules.common-gpu-intel
  ];
  programs.twindesk = {
    enable = true;
    inherit user;
    enableWifiDirect = false;
  };
  # Keep TwinDesk's input-group access after hardware.uinput's default rule.
  services.udev.extraRules = lib.mkAfter ''
    KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
  '';
}
