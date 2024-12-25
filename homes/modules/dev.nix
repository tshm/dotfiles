{ pkgs, ... }:

{
  home.packages = [
    # langs
    pkgs.luajitPackages.luarocks
    pkgs.dotnet-runtime
    pkgs.cargo
    pkgs.go
    pkgs.nodejs
    # git extras
    pkgs.git-cliff
    pkgs.git-imerge
    pkgs.git-absorb
    pkgs.pre-commit
    pkgs.commitizen
  ];
}
