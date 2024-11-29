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
    # until zen-browser-flake is merged into nixos-unstable
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    hyprswitch.url = "github:h3rmt/hyprswitch/release";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... } @ args:
    let
      inputs = { user = "tshm"; } // args;
    in
    {
      nixosConfigurations = import ./hosts inputs;
      homeConfigurations = import ./homes inputs;
    };
}
