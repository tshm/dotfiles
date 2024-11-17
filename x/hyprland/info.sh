#!/bin/sh

[ -d /sys/class/power_supply/BAT0 ] &&\
  BAT="Battery $(cat /sys/class/power_supply/BAT0/status) : $(cat /sys/class/power_supply/BAT0/capacity)%"

BT=$(bluetoothctl devices Connected | cut -d' ' -f3)
[ -n "$BT" ] && BT="Bluetooth: $BT\n"

VPN=$(warp-cli status | cut -d' ' -f3)
[ -n "$VPN" ] && VPN="VPN: $VPN\n"

notify-send "$(date '+%Y/%m/%d %H:%M')" \
  "$BT$VPN$BAT"

