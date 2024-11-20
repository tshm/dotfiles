{ nixpkgs, ... } @ args:
let
  system = "x86_64-linux";
  inputs = args // {
    pkgs = nixpkgs.legacyPackages.${system};
    extraSpecialArgs = args // { inherit system; user = "tshm"; };
    inherit system;
    user = "tshm";
  };
in
builtins.foldl' (s: i: s // i) { } [
  (import ./spi inputs)
  (import ./minf inputs)
  (import ./PD0056 inputs)
  (import ./x360 inputs)
  (import ./usb inputs)
]
