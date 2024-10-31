{ config, lib, pkgs, self, ... }:

let
  configPath = pathStr: builtins.path { path = "${self}${pathStr}"; };
  wrapElectronApp = { appName, binName ? appName }:
    pkgs.symlinkJoin {
      name = appName;
      paths = [ pkgs.${appName} ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = lib.strings.concatStrings [
        "wrapProgram $out/bin/"
        binName
        " --add-flags \"--ozone-platform-hint=auto\""
        " --add-flags \"--enable-wayland-ime\""
      ];
    };
in
{
  fonts.fontconfig.enable = true;
  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
  gtk = {
    enable = true;
    iconTheme.name = "Flat-Remix-Blue";
  };
  home = {
    packages = [
      pkgs.bluetuith
      pkgs.waybar
      pkgs.xdragon
      pkgs.ags
      (wrapElectronApp { appName = "beeper"; })
      (wrapElectronApp { appName = "vscode-fhs"; binName = "code"; })
      pkgs.neovide
    ];
    file = {
      "${config.xdg.configHome}/mpv/mpv.conf".source = configPath "/mpv.conf";
      "${config.xdg.configHome}/wezterm/wezterm.lua".source = configPath "/wezterm/wezterm.lua";
      "${config.xdg.configHome}/waybar/".source = configPath "/x/waybar";
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland; # use system installed binary
    extraConfig = ''
      # extraConfig
      source = ~/.dotfiles/x/hyprland/vars.conf
      source = *local.conf
      source = ~/.dotfiles/x/hyprland/general.conf
    '';
  };
}
