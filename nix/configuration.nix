{ ... }:

let
  base = (import ./baseos.nix) { hostname = "myhost"; };
in
{
  imports = [
    # <nixos-hardware/common/cpu/intel>
    # <nixos-hardware/common/gpu/intel>
    # <nixos-hardware/common/pc/ssd>
    ./hardware-configuration.nix
    base
  ];
}
