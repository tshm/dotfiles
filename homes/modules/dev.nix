{ pkgs, system, ... } @ inputs:

{
  home.packages = [
    # langs
    pkgs.luajitPackages.luarocks
    pkgs.dotnet-runtime
    pkgs.cargo
    pkgs.go
    pkgs.nodejs
    pkgs.sqlite
    # git extras
    pkgs.git-cliff
    pkgs.git-imerge
    pkgs.git-absorb
    pkgs.commitizen
    # misc
    inputs.localias.packages."${system}".default
    # pkgs.radicle-node
    # pkgs.oils-for-unix
  ];
}
