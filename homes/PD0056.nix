{ pkgs, ... }:

{
  home.packages = [
    pkgs.qsv
    pkgs.deno
    pkgs.teller
    pkgs.sq
    pkgs.duckdb
    pkgs.podman
    pkgs.podman-compose
    pkgs.podman-tui
  ];
  programs.java = { enable = true; };
  programs.go = { enable = true; };
}

