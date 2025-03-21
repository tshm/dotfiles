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
    hyprswitch.url = "github:h3rmt/hyprswitch/release";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    localias.url = "github:peterldowns/localias";
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
          "https://nix-community.cachix.org"
          "https://nixpkgs.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
          "tshmcache.cachix.org-1:0btnJOmOtW8UjTeoXCjhxOuc/TLcXcxL+DGBJ0sNEw0="
        ];
      };
      inputs = { user = user; nixsettings = nixsettings; } // args;

    in
    {
      nixosConfigurations = import ./hosts inputs;
      homeConfigurations = import ./homes inputs;
    };
}
