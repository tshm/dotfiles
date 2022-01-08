#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run autorandr horizontal
run alacritty
run alttab -w 1

run fcitx-autostart
run nm-applet
run blueman-tray
run pa-applet
# run volumeicon
# run cbatticon
run xfce4-power-manager

