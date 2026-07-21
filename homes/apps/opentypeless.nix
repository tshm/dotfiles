{ pkgs, ... }:
let
  pname = "opentypeless";
  version = "1.1.50";
  src = pkgs.fetchurl {
    url = "https://github.com/tover0314-w/opentypeless/releases/download/v${version}/OpenTypeless_${version}_amd64.AppImage";
    hash = "sha256-PfvDqiBu5HHViIeVWwuXbN+koQRaLWXkwKxexjXO/IU=";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in pkgs.appimageTools.wrapType2 {
  inherit pname version src;
  pkgs = pkgs;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/usr/share/applications/OpenTypeless.desktop -t $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  dieWithParent = false;

  meta = {
    description = "AI-powered speech-to-text and text polishing desktop app";
    homepage = "https://www.opentypeless.com";
    license = pkgs.lib.licenses.mit;
    mainProgram = "opentypeless";
    platforms = [ "x86_64-linux" ];
  };
}
