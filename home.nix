{ pkgs, ... }:

{
  home.packages = [
    pkgs.neovim
    pkgs.qsv
    pkgs.deno
    pkgs.teller
    pkgs.sq
    pkgs.duckdb
    pkgs.podman
    pkgs.podman-compose
  ];
  programs.java = { enable = true; };
  programs.go = { enable = true; };
}

