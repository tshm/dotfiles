{ pkgs, ... }:

{
  home.packages = [
    # browser automation dependencies (Playwright/Chromium)
    pkgs.chromium
    pkgs.glib
    pkgs.nss
    pkgs.libdrm
    pkgs.libxkbcommon
    pkgs.libXcomposite
    pkgs.libXdamage
    pkgs.libXrandr
    pkgs.libgbm
    pkgs.libXScrnSaver
    pkgs.alsa-lib
    pkgs.gtk3
    pkgs.cairo
    pkgs.gdk-pixbuf
    pkgs.libX11
    pkgs.libXext
    pkgs.libXfixes
    pkgs.libXi
    pkgs.libXtst
    pkgs.libXrender
    pkgs.libxcb
    pkgs.libxshmfence
  ];
}
