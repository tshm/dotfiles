{ pkgs, ... }:

{
  home.packages = [
    # langs
    pkgs.luajitPackages.luarocks
    pkgs.dotnet-sdk
    pkgs.cargo
    pkgs.go
    pkgs.nodejs
  ];
}

