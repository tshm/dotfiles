{ pkgs, system, lib, ... } @ inputs:

let
  nodePackages = pkgs.callPackage ./node2nix { inherit pkgs system; };
in
{
  home.packages = [
    pkgs.lima
    pkgs.scrcpy
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
    # nodePackages."opencode-ai"
    # nodePackages."@google/gemini-cli"
    # pkgs.radicle-node
    # pkgs.oils-for-unix
  ] ++ (
    if (lib.hasInfix "x86" system) then [
      inputs.localias.packages."${system}".default
    ]
    else
      [ ]
  );
}
