{ ... }:

let
  base = (import ./baseos.nix) { hostname = "usb"; };
in
{
  imports = [
    #<nixos-hardware/common/cpu/intel/alder-lake>
    #<nixos-hardware/common/gpu/intel/alder-lake>
    #<nixos-hardware/common/pc/ssd>
    ./hardware-configuration.nix
    base
  ];
}
