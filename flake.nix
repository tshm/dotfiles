{
  description = "Home Manager configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations = {
        "tshm@PD0056" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = inputs;
          modules = [
            (import ./base.nix { isWSL = true; })
            ./home.nix
          ];
        };
        "tshm@minf" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = inputs;
          modules = [
            (import ./base.nix)
          ];
        };
      };
    };
}
