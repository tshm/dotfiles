{ pkgs, ... }:
let
  pname = "beeper";
  version = "latest";
  src = pkgs.fetchurl {
    curlOptsList = [ "-L" "-H" "Accept:application/octet-stream" ];
    url = "https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop";
    # sha256 = pkgs.lib.fakeSha256;
    sha256 = "sha256-uTPprGSOi2LlxzrHRtL2KSMPR4bOmQbV8g0Fm19T0n0=";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;
  pkgs = pkgs;
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/beepertexts.desktop -t $out/share/applications
    install -m 444 -D ${appimageContents}/beepertexts.png -t $out/share/icons/hicolor/128x128/apps
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
