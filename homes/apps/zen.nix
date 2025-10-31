{ pkgs, ... }:
let
  pname = "zen";
  version = "latest";
  src = pkgs.fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/latest/download/zen-x86_64.AppImage";
    # sha256 = pkgs.lib.fakeSha256;
<<<<<<< Updated upstream
    sha256 = "sha256-ZL/SMNLdZC0XYD8bGxDe+f7yFhDHtIRM+aiEoOg4JA8=";
||||||| Stash base
    sha256 = "sha256-CH+TUEN3Vm2sHH0Ijjfq1L8U1n0hoLoK5wRnSIf25HM=";
=======
    sha256 = "sha256-LZFKXdE1EIM4U+Fdz1b+/Z/HTzo3ypI0Q+2fnI6yYao=";
>>>>>>> Stashed changes
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;
  pkgs = pkgs;
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    install -m 444 -D ${appimageContents}/${pname}.png -t $out/share/icons/hicolor/128x128/apps
  '';

  # extraBwrapArgs = [
  #   "--bind-try /etc/nixos/ /etc/nixos/"
  # ];

  dieWithParent = false;

  meta = {
    description = "Zen";
    license = pkgs.lib.licenses.unfree;
    platforms = with pkgs.lib.platforms; linux;
  };
}
