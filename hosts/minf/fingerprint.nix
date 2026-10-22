{ lib, pkgs, ... }:
let
  driver = pkgs.fetchzip {
    url = "https://github.com/Deetss/ft9201-libfprint/archive/da599b389f41827617df8c1836926eff580f3733.tar.gz";
    hash = "sha256-dMRU7E419Wq9ahFW7L+t23rUlZiZ3Dr2LM/rqebVmiU=";
  };
  firmware = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mrrbrilliant/ft9201-static/ec8b704d34700e6e83b6ec7260c6faedaaa8e13e/libfprint_2_2_1_90_1%2Btod1_0ubuntu120_04_2_amd64_16c6e64404f8411.deb";
    hash = "sha256-qVrNeDps9tEwlZXQh1i14pWerICSBNVTmcyu9iDNPrw=";
  };
  cabinet = pkgs.fetchurl {
    url = "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2023/05/fd237921-f610-43de-b77c-f1685416480b_710b4d2c8dd2e80043e371b91bebb1721b5163a0.cab";
    hash = "sha256-Zd/9p93HbTCzJOvwLJict00OyFzurDseENN/zD0yGBE=";
  };
  matcher = pkgs.runCommand "ft9201-matcher" {
    nativeBuildInputs = [ pkgs.cabextract ];
    preferLocalBuild = true;
    allowSubstitutes = false;
    meta.license = lib.licenses.unfree;
  } ''
    mkdir -p "$out"
    cabextract -q -F ftWbioEngineAdapter.dll -d "$out" ${cabinet}
  '';
  libfprint = pkgs.libfprint.overrideAttrs (old: {
    pname = "libfprint-ft9201";
    version = "1.94.10";
    src = pkgs.fetchzip {
      url = "https://gitlab.freedesktop.org/libfprint/libfprint/-/archive/v1.94.10/libfprint-v1.94.10.tar.gz";
      hash = "sha256-aNBUIKY3PP5A07UNg3N0qq+2cwb6Fk67oKQcXgr2G/4=";
    };
    nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.binutils pkgs.python3 ];
    postPatch = old.postPatch + ''
      mkdir vendor-firmware
      (cd vendor-firmware && ar x ${firmware} && tar xf data.tar.*)
      python3 ${driver}/scripts/extract-firmware.py \
        vendor-firmware/usr/lib/x86_64-linux-gnu/libfprint-2.so.2.0.0 \
        libfprint/drivers/ft9201_fw.h
      cp ${driver}/src/ft9201.c ${driver}/src/ft_engine.{c,h} libfprint/drivers/
      patch -p1 < ${./ft9201-identify.patch}
      substituteInPlace libfprint/meson.build --replace-fail \
        'driver_sources = {' \
        "driver_sources = { 'ft9201': ['drivers/ft9201.c', 'drivers/ft_engine.c'],"
      # This ID is now implemented, so it must leave the unsupported-device table.
      substituteInPlace libfprint/fprint-list-udev-hwdb.c --replace-fail \
        '  { .vid = 0x2808, .pid = 0x93a9 },' ""
    '';
    # ponytail: only this reader plus virtual test drivers; add others when needed.
    mesonFlags = (lib.filter (flag: !(lib.hasPrefix "-Ddrivers=" flag)) old.mesonFlags)
      ++ [ "-Ddrivers=ft9201,virtual_image,virtual_device,virtual_device_storage" ];
    installCheckPhase = old.installCheckPhase + ''
      root="$NIX_BUILD_TOP/$sourceRoot"
      $CC -ffunction-sections -fdata-sections \
        -I"$root" -I"$root/libfprint" -I"$root/build" -I"$root/build/libfprint" \
        ${./test-ft9201-identify.c} -Wl,--gc-sections \
        -L"$out/lib" -Wl,-rpath,"$out/lib" -lfprint-2 \
        $(pkg-config --cflags --libs glib-2.0 gio-unix-2.0 gusb) \
        -o test-ft9201-identify
      ./test-ft9201-identify
    '';
    preferLocalBuild = true;
    allowSubstitutes = false;
    meta = old.meta // {
      description = "Experimental FT9201 driver with proprietary FocalTech firmware";
      license = lib.licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  });
in {
  # Fingerprints are only for local login, not privilege escalation or locking.
  options.security.pam.services = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      fprintAuth = lib.mkDefault false;
    });
  };

  config = {
    services.fprintd = {
      enable = true;
      package = pkgs.fprintd.override { inherit libfprint; };
    };
    security.pam.services.login.fprintAuth = true; # greetd includes this stack.
    systemd.services.fprintd.environment.FT9201_ENGINE_DLL =
      "${matcher}/ftWbioEngineAdapter.dll";
    services.udev.extraRules = builtins.readFile "${driver}/packaging/60-ft9201.rules";
  };
}
