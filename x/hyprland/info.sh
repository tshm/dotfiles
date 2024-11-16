#!/bin/sh
notify-send "$(date '+%Y/%m/%d %H:%M')" \
  "Bluetooth: $(bluetoothctl devices Connected | cut -d' ' -f3)\n\
  VPN: $(warp-cli status | cut -d' ' -f3)"

