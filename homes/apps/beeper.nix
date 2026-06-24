{ pkgs, ... }:
let
  pname = "beeper";
  version = "4.2.945";
  src = pkgs.fetchurl {
    url = "https://beeper-desktop.download.beeper.com/builds/Beeper-${version}-x86_64.AppImage";
    # sha256 = pkgs.lib.fakeSha256;
    sha256 = "sha256-opr2Fqzr7nJTCa66d9S0+WToD9zmOXJRfA2hnSvRiaE=";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in pkgs.appimageTools.wrapType2 {
  inherit pname version src;
  pkgs = pkgs;
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/beepertexts.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/beepertexts.desktop \
      --replace-fail "AppRun" "beeper"
    install -m 444 -D ${appimageContents}/beepertexts.png -t $out/share/icons/hicolor/128x128/apps

    . ${pkgs.makeWrapper}/nix-support/setup-hook
    wrapProgram $out/bin/beeper \
      --set OZONE_PLATFORM x11
  '';

  # extraBwrapArgs = [
  #   "--bind-try /etc/nixos/ /etc/nixos/"
  # ];

  dieWithParent = false;

  meta = {
    description = "Beeper";
    license = pkgs.lib.licenses.unfree;
    platforms = with pkgs.lib.platforms; linux;
  };
}
