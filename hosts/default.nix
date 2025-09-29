 { nixpkgs, crossPkgs, ... } @ args:
 let
   base = import ./base.nix;
   gui = import ./gui.nix;
   system = "x86_64-linux";
   specialArgs = args // { inherit system; };
 in
{
   "tp" = nixpkgs.lib.nixosSystem {
     inherit system;
     inherit specialArgs;
     modules = [
       ./t440p
       (base { host = "tp"; forServer = true; })
     ];
   };

   "minf" = nixpkgs.lib.nixosSystem {
     inherit system;
     inherit specialArgs;
     modules = [
       ./minf
       (base { host = "minf"; })
       gui
     ];
   };

   "x360" = nixpkgs.lib.nixosSystem {
     inherit system;
     inherit specialArgs;
     modules = [
       ./x360
       (base { host = "x360"; })
       gui
     ];
   };

   "usb" = nixpkgs.lib.nixosSystem {
     inherit system;
     inherit specialArgs;
     modules = [
       ./usb
       (base { host = "usb"; })
       gui
     ];
   };

   "spi" = nixpkgs.lib.nixosSystem {
     system = "aarch64-linux";
     specialArgs = specialArgs // { inherit nixpkgs crossPkgs; };
     modules = [
       ./spi
       (base { host = "spi"; forServer = true; })
     ];
   };
}
