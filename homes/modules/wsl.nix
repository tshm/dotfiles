{ pkgs, ... }:

{
  home = {
    packages = [
      pkgs.wsl-open
      pkgs.wslu
    ];
  };
}
