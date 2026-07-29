{ pkgs, ... }:
let
  pname = "speakoflow";
  version = "1.0.2";
  src = pkgs.fetchurl {
    url = "https://github.com/AbhishekBarali/SpeakoFlow/releases/download/v${version}/SpeakoFlow_${version}_amd64.AppImage";
    hash = "sha256-x/o2GQnwdqt83UWoBp/zS4TVTkHTtaZILFrPF4V4yeY=";
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
