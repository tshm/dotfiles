{
  nixpkgs,
  user,
  home-manager,
  ...
}@args:
let
  inputs =
    system: username:
    args
    // {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = args // {
        inherit system;
        user = username;
      };
      inherit system;
      user = username;
      home-manager = home-manager;
    };
  arm_inputs = inputs "aarch64-linux" user;
  x86_inputs = inputs "x86_64-linux" user;
in
builtins.foldl' (s: i: s // i) { } [
  (import ./spi arm_inputs)
  (import ./minf x86_inputs)
  (import ./PD0056 x86_inputs)
  (import ./PN0093 x86_inputs)
  (import ./x360 x86_inputs)
  (import ./usb x86_inputs)
  (import ./t440p x86_inputs)
]
