{
  home-manager,
  pkgs,
  extraSpecialArgs,
  ...
}:

{
  "tshm@PD0056" = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    inherit extraSpecialArgs;
    modules = [
      ../modules/base.nix
      ../modules/wsl.nix
      ../modules/dev.nix
      {
        targets.genericLinux.enable = true;
        home.packages = [
          pkgs.sshfs
          pkgs.qsv
          pkgs.deno
          pkgs.teller
          pkgs.sq
          pkgs.duckdb
          pkgs.podman
          pkgs.podman-compose
          pkgs.podman-tui
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
