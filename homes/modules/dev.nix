{ pkgs, system, config, lib, mcp-servers-nix, ... } @ inputs:

let
  # nodePackages = pkgs.callPackage ./node2nix { inherit pkgs system; nodejs = pkgs.nodejs_20; };
in
  {
  home.file."${config.xdg.configHome}/mcp/mcp.json".source = mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      context7.enable = true;
      memory.enable = true;
      sequential-thinking.enable = true;
      # fetch.enable = true;
    };
  };
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
    pkgs.gh
    pkgs.git-cliff
    pkgs.git-imerge
    pkgs.git-absorb
    pkgs.commitizen
    # misc
    # Temporarily disable opencode-ai due to build issues
    # nodePackages.opencode-ai
    pkgs.opencode
    # nodePackages."@google/gemini-cli"
    pkgs.gemini-cli
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
