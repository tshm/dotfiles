{ pkgs, config, ... }:

let
  base =
    (import ./baseos.nix)
      { hostname = "minf"; }
      { pkgs = pkgs; config = config; };
in
{
  imports = [
    ./hardware-configuration.nix
    base
  ];
}
