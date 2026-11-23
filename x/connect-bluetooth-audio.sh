#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title reconnect bluetooth audio device
# @vicinae.mode compact
# @vicinae.keywords ["bluetooth", "audio", "headset", "reconnect"]
# @vicinae.description Reconnect a paired Bluetooth audio device and switch playback to it.
# @vicinae.exec ["bash"]

profile=0000110b-0000-1000-8000-00805f9b34fb

while read -r _ address _; do
  info=$(bluetoothctl info "$address")
  [[ $info == *"$profile"* ]] || continue
  if [[ $info == *'Connected: yes'* ]]; then
    bluetoothctl --timeout 10 disconnect "$address" "$profile"
  fi
  bluetoothctl --timeout 15 connect "$address" "$profile" || exit 1

  # BlueZ can report success before PipeWire publishes the playback sink.
  sink_prefix=bluez_output.${address//:/_}
  for ((attempt = 0; attempt < 20; attempt++)); do
    sinks=$(pactl list short sinks) || exit 1
    read -r sink_id sink < <(awk -v prefix="$sink_prefix" '
      $2 == prefix || index($2, prefix ".") == 1 { print $1, $2; exit }
    ' <<< "$sinks") && break
    sleep 0.25
  done
  if [[ -z $sink ]]; then
    printf 'No Bluetooth playback output appeared; check that the headset is awake and in range\n' >&2
    exit 1
  fi

  pactl set-default-sink "$sink" || exit 1
  streams=$(pactl list short sink-inputs) || exit 1
  status=0
  while read -r stream current_sink _; do
    [[ -n $stream && $current_sink != "$sink_id" ]] || continue
    pactl move-sink-input "$stream" "$sink" || status=1
  done <<< "$streams"
  (( status == 0 )) && printf 'Switched audio output to Bluetooth\n'
  exit "$status"
done < <(bluetoothctl devices Paired)

printf 'No paired Bluetooth audio device found\n' >&2
exit 1
