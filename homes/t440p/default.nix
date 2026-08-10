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
      ../modules/playwright.nix
      {
        systemd.user.services.multica = {
          Unit = {
            Description = "Multica selfhost daemon";
            StartLimitBurst = 10;
            StartLimitIntervalSec = "infinity";
          };
          Service = {
            ExecStart = "/usr/local/bin/multica daemon start --profile selfhost";
            Restart = "on-failure";
          };
          Install.WantedBy = [ "default.target" ];
        };

        home.packages = [
          pkgs.qsv
          pkgs.deno
          # pkgs.ollama
          pkgs.localtunnel
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
