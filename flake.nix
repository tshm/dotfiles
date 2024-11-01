{
  description = "Home Manager configurations";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # until zen-browser-flake is merged into nixos-unstable
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs = { self, nixpkgs, home-manager, ... } @ args:
    {
      homeConfigurations = import ./homes ({ user = "tshm"; } // args);
    };
}
