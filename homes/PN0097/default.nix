{
  home-manager,
  pkgs,
  extraSpecialArgs,
  ...
}:

{
  "tshm@PN0097" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ../modules/base.nix
      ../modules/wsl.nix
      ../modules/dev.nix
      {
        targets.genericLinux.enable = true;
        home.packages = [
          pkgs.duckdb
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
