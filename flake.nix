{
  description = "Nix configurations";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    # hyprshell.url = "github:h3rmt/hyprswitch?ref=hyprshell";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # inputs = {
    #   lan-mouse.url = "github:feschber/lan-mouse";
    # };
    localias.url = "github:peterldowns/localias";
    # mcp-servers-nix.url = "github:natsukium/mcp-servers-nix";
    vicinae.url = "github:vicinaehq/vicinae";
  };

  outputs = { self, nixpkgs, ... } @ args:
    let
      user = "tshm";
      nixsettings = {
        keep-derivations = true;
        keep-outputs = true;
        trusted-users = [ "root" user ];
        substituters = [
          "https://cache.nixos.org"
          "https://tshmcache.cachix.org"
          "https://nix-community.cachix.org"
          "https://nixpkgs.cachix.org"
          "https://vicinae.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
          "tshmcache.cachix.org-1:0btnJOmOtW8UjTeoXCjhxOuc/TLcXcxL+DGBJ0sNEw0="
          "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
        ];
      };
      # Cross-compilation support for aarch64-linux
      crossSystem = "aarch64-linux";
      crossPkgs = import nixpkgs {
        system = crossSystem;
        config.allowUnfree = true;
      };
      inputs = { user = user; nixsettings = nixsettings; crossPkgs = crossPkgs;} // args;

    in
    {
      nixosConfigurations = import ./hosts inputs;
      homeConfigurations = import ./homes inputs;

      # Cross-compilation packages
      packages.${crossSystem} = {
        spi-image = self.nixosConfigurations.spi.config.system.build.sdImage;
      };
    };
}
