{ pkgs, ... }:
let
  pname = "zen";
  version = "latest";
  src = pkgs.fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/latest/download/zen-x86_64.AppImage";
    # sha256 = pkgs.lib.fakeSha256;
    sha256 = "sha256-V8I8Qj03lxovJjW54MCgQQlXxFLorrwF0opo55pxSqI=";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in pkgs.appimageTools.wrapType2 {
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
