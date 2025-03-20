{ pkgs, ... }:
let
  pname = "beeper";
  version = "4.0.551";
  src = pkgs.fetchurl {
    url = "https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop";
    hash = "sha256-38bc0b8e05853a2052e51904a6f847ee1adeae2f0417e251bcacbe29dadef203";
  };
  appimageContents = pkgs.appimageTools.extract { inherit pname version src; };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;
  pkgs = pkgs;
  extraInstallCommands = ''
        install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace 'Exec=AppRun' 'Exec=${pname}'
        cp -r ${appimageContents}/usr/share/icons $out/share

        # unless linked, the binary is placed in $out/bin/${pname}-${version}
        # ln -s $out/bin/${pname}-${version} $out/bin/${pname}
      '';

  extraBwrapArgs = [
    "--bind-try /etc/nixos/ /etc/nixos/"
  ];

  dieWithParent = false;

  extraPkgs = pkgs: with pkgs; [
    unzip
    autoPatchelfHook
    asar
    # override doesn't preserve splicing https://github.com/NixOS/nixpkgs/issues/132651
    (buildPackages.wrapGAppsHook.override { inherit (buildPackages) makeWrapper; })
  ];
}
