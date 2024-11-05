{
  description = "Nix configurations";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # until zen-browser-flake is merged into nixos-unstable
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
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
