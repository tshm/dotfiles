{ home-manager, pkgs, nixpkgs, extraSpecialArgs, ... }:

{
  "pi@spi" = home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.aarch64-linux;
    extraSpecialArgs = extraSpecialArgs // { user = "pi"; };
    modules = [
      ../modules/base.nix
      ../modules/dev.nix
      {
        home.packages = [
          pkgs.deno
        ];
        programs.java = { enable = false; };
        programs.go = { enable = false; };
      }
    ];
  };
}
