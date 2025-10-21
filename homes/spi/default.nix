{
  home-manager,
  pkgs,
  nixpkgs,
  extraSpecialArgs,
  ...
}:

{
  "tshm@spi" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
    extraSpecialArgs = extraSpecialArgs;
    modules = [
      ../modules/base.nix
      ../modules/dev.nix
      {
        targets.genericLinux.enable = true;
        home.packages = [
          pkgs.deno
        ];
        programs.java = {
          enable = false;
        };
        programs.go = {
          enable = false;
        };
      }
    ];
  };
}
