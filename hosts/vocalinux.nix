{ lib
, fetchPypi
, python3
, python3Packages
, stdenv
, atk
, autoPatchelfHook
, cmake
, gdk-pixbuf
, glib
, gobject-introspection
, gtk3
, harfbuzz
, libayatana-appindicator
, libnotify
, ninja
, patchelf
, libdbusmenu-gtk3
, pkg-config
, portaudio
, pango
, wl-clipboard
, wtype
, xdotool
, ydotool
, wrapGAppsHook3
}:

let
  pywhispercpp = python3Packages.buildPythonPackage rec {
    pname = "pywhispercpp";
    version = "1.4.1";
    pyproject = true;

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-UgzpJ1u2/IHg2qLggUSoDuAGsRehgFineGDFscnBIvQ=";
    };

    build-system = [
      python3Packages.cmake
      python3Packages.ninja
      python3Packages.setuptools
      python3Packages.wheel
      python3Packages.setuptools-scm
    ];

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      patchelf
    ];

    dontUseCmakeConfigure = true;


    propagatedBuildInputs = [
      python3Packages.numpy
      python3Packages.platformdirs
      python3Packages.requests
      python3Packages.tqdm
    ];

    patchPhase = ''
      substituteInPlace pyproject.toml --replace-fail '"repairwheel",' ""
    '';

    env.NO_REPAIR = "1";

    preFixup = ''
      sitePackages="$out/${python3.sitePackages}"
      runtimeRpath="\$ORIGIN:${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}"

      for so in "$sitePackages"/*.so "$sitePackages"/*.so.*; do
        if [ -e "$so" ]; then
          patchelf --set-rpath "$runtimeRpath" "$so"
        fi
      done
    '';


    doCheck = false;
    pythonImportsCheck = [
      "pywhispercpp"
      "_pywhispercpp"
    ];

    meta = {
      description = "Python bindings for whisper.cpp";
      homepage = "https://github.com/absadiki/pywhispercpp";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  };

  vosk = python3Packages.buildPythonPackage rec {
    pname = "vosk";
    version = "0.3.45";
    format = "wheel";

    src = fetchPypi {
      inherit pname version format;
      dist = "py3";
      python = "py3";
      platform = "manylinux_2_12_x86_64.manylinux2010_x86_64";
      hash = "sha256-JeAlCTxDmdcnj1Q1aO2MxUYKw6S/SMI2c6zh4l0mYZ8=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];

    propagatedBuildInputs = [
      python3Packages.cffi
      python3Packages.requests
      python3Packages.srt
      python3Packages.tqdm
      python3Packages.websockets
    ];

    doCheck = false;
    pythonImportsCheck = [ "vosk" ];

    meta = {
      description = "Offline open source speech recognition API based on Kaldi and Vosk";
      homepage = "https://github.com/alphacep/vosk-api";
      license = lib.licenses.asl20;
      platforms = lib.platforms.linux;
    };
  };
in
python3Packages.buildPythonApplication rec {
  pname = "vocalinux";
  version = "0.10.2b0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-n5cYxi0H03c5n0EL9pwdB0Tl170z9A7ob1HBqzUowYU=";
  };

  build-system = [
    python3Packages.setuptools
    python3Packages.wheel
  ];

  nativeBuildInputs = [ wrapGAppsHook3 ];

  buildInputs = [
    atk
    gdk-pixbuf
    gdk-pixbuf.dev
    glib
    glib.dev
    gobject-introspection
    gtk3
    gtk3.dev
    libayatana-appindicator
    libayatana-appindicator.dev
    libdbusmenu-gtk3
    pango.out
    harfbuzz
    portaudio
  ];

  propagatedBuildInputs = [
    pywhispercpp
    python3Packages.evdev
    python3Packages.lxml
    python3Packages.numpy
    python3Packages.pyaudio
    python3Packages.pydub
    python3Packages.pygobject3
    python3Packages.pynput
    python3Packages.psutil
    python3Packages.requests
    python3Packages.tqdm
    python3Packages.xlib
    vosk
  ];

  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    makeWrapperArgs+=(--prefix GI_TYPELIB_PATH : "${lib.makeSearchPath "lib/girepository-1.0" [
      atk
      gdk-pixbuf
      glib
      gtk3
      harfbuzz
      libayatana-appindicator
      libdbusmenu-gtk3
      pango.out
    ]}")
    makeWrapperArgs+=(--prefix PATH : "${lib.makeBinPath [
      libnotify
      wl-clipboard
      wtype
      xdotool
      ydotool
    ]}")
  '';

  postInstall = ''
    sitePackages="$out/${python3.sitePackages}"
    resourcesDir="$sitePackages/vocalinux/resources"

    mkdir -p "$out/share/vocalinux"
    cp -r "$resourcesDir" "$out/share/vocalinux/resources"

    install -Dm444 vocalinux.desktop "$out/share/applications/vocalinux.desktop"

    for icon in \
      vocalinux.svg \
      vocalinux-microphone.svg \
      vocalinux-microphone-off.svg \
      vocalinux-microphone-process.svg
    do
      install -Dm444 \
        "$resourcesDir/icons/scalable/$icon" \
        "$out/share/icons/hicolor/scalable/apps/$icon"
    done
  '';

  doCheck = false;
  pythonImportsCheck = [ "vocalinux" ];

  meta = {
    description = "Offline voice dictation for Linux";
    homepage = "https://vocalinux.com/";
    license = lib.licenses.gpl3Only;
    mainProgram = "vocalinux";
    platforms = lib.platforms.linux;
  };
}
