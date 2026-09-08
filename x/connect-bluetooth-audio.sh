#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title reconnect bluetooth audio device
# @vicinae.mode compact
# @vicinae.keywords ["bluetooth", "audio", "headset", "reconnect"]
# @vicinae.description Reconnect a paired Bluetooth device's A2DP audio profile.
# @vicinae.exec ["bash"]

profile=0000110b-0000-1000-8000-00805f9b34fb

while read -r _ address _; do
  bluetoothctl info "$address" | grep -q "$profile" || continue
  bluetoothctl connect "$address"
  exit
done < <(bluetoothctl devices Paired)

printf 'No paired Bluetooth audio device found\n' >&2
exit 1
