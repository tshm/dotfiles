#!/bin/sh
rofi \
  -show-icon \
  -show window \
  -kb-accept-entry '!Alt-Tab' \
  -kb-row-down Alt-Tab &
xdotool keyup Tab
xdotool keydown Tab
