{ pkgs, ... }:

{
  home.packages = [
    pkgs.deno
  ];
  programs.java = { enable = false; };
  programs.go = { enable = false; };
}

