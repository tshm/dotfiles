#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run autorandr horizontal
run alacritty
run alttab

run fcitx-autostart
run nm-applet
run blueman-tray
run volumeicon
run cbatticon

