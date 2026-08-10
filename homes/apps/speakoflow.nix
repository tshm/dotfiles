{ pkgs, ... }:
let
  pname = "speakoflow";
  version = "1.2.0";
  src = pkgs.fetchurl {
    url = "https://github.com/AbhishekBarali/SpeakoFlow/releases/download/v${version}/SpeakoFlow_${version}_amd64.AppImage";
    hash = "sha256-assYoK7zdHBGUvW7YCda7P9pj/J699Plxo2ghjaoVV0=";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/usr/share/applications/SpeakoFlow.desktop -t $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share/
  '';

  dieWithParent = false;

  meta = {
    description = "Free, local-first desktop voice assistant";
    homepage = "https://github.com/AbhishekBarali/SpeakoFlow";
    license = pkgs.lib.licenses.mit;
    mainProgram = "speakoflow";
    platforms = [ "x86_64-linux" ];
  };
}
