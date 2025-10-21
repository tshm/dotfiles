{
  home-manager,
  pkgs,
  extraSpecialArgs,
  ...
}:

{
  "tshm@tp" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ../modules/base.nix
      ../modules/dev.nix
      {
        home.packages = [
          pkgs.qsv
          pkgs.deno
          # pkgs.ollama
          pkgs.nodePackages.localtunnel
          # pkgs.lmstudio
        ];
        programs.java = {
          enable = true;
        };
        programs.go = {
          enable = true;
        };
      }
    ];
  };
}
