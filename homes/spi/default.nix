{
  home-manager,
  pkgs,
  nixpkgs,
  extraSpecialArgs,
  ...
}:

let
  hermesServe = pkgs.writeShellApplication {
    name = "hermes-serve";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      tailscaleAddress="$(/run/current-system/sw/bin/tailscale ip -4 | head -n 1)"
      if [[ -z "$tailscaleAddress" ]]; then
        echo "No Tailscale IPv4 address is available" >&2
        exit 1
      fi

      exec "$HOME/.local/bin/hermes" serve --host "$tailscaleAddress" --port 9119
    '';
  };
in
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
        systemd.user.services.hermes-serve = {
          Unit = {
            Description = "Hermes Remote Desktop Backend";
            After = [
              "network-online.target"
              "hermes-gateway.service"
            ];
            Wants = [ "network-online.target" ];
            PartOf = [ "hermes-gateway.service" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${hermesServe}/bin/hermes-serve";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install.WantedBy = [ "hermes-gateway.service" ];
        };
      }
    ];
  };
}
