{ user, config, lib, pkgs, system, ... } @ inputs:

let
  configPath = pathStr: config.lib.file.mkOutOfStoreSymlink "/home/${user}/.dotfiles${pathStr}";
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
      inputs.hyprswitch.packages."${system}".default
      inputs.zen-browser.packages."${system}".specific
      pkgs.bluetuith
      pkgs.waybar
      pkgs.colloid-icon-theme
      pkgs.swaynotificationcenter
      pkgs.copyq
      pkgs.rofi-wayland-unwrapped
      pkgs.ripdrag
      pkgs.ags
      (wrapElectronApp { appName = "beeper"; })
      (wrapElectronApp { appName = "vscode-fhs"; binName = "code"; })
      pkgs.neovide
      pkgs.pamixer
      pkgs.brightnessctl
      pkgs.slurp
      pkgs.grim
    ];
    file = {
      "${config.xdg.configHome}/wezterm/wezterm.lua".source = configPath "/wezterm/wezterm.lua";
      "${config.xdg.configHome}/waybar/".source = configPath "/x/waybar";
    };
  };
  programs.mpv = {
    enable = true;
    config = {
      vo = "gpu";
      hwdec = "auto";
      speed = "1.21";
      sub-auto = "fuzzy";
      save-position-on-quit = "yes";
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland; # use system installed binary
    extraConfig = ''
      # extraConfig
      source = ~/.dotfiles/x/hyprland/vars.conf
      source = ~/.dotfiles/x/hyprland/general.conf
    '';
  };
}

