#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title reconnect bluetooth audio device
# @vicinae.mode fullOutput
# @vicinae.keywords ["bluetooth", "audio", "headset", "reconnect"]
# @vicinae.description Reconnect a paired Bluetooth audio device and switch playback to it.
# @vicinae.exec ["bash"]

audio_sink_uuid=0000110b-0000-1000-8000-00805f9b34fb

fail() {
  printf 'Failed: %s\n' "$1" >&2
  exit 1
}

recover_stereo() {
  printf 'Connecting the Bluetooth stereo service on %s…\n' "$name"
  # BlueZ can report busy or already connected while PipeWire brings up stereo.
  timeout --verbose 10s bluetoothctl connect "$address" "$audio_sink_uuid" ||
    printf 'BlueZ did not confirm the connection; checking PipeWire anyway.\n'
  wait_for_stereo
}

wait_for_stereo() {
  local card=bluez_card.${address//:/_} sink_prefix=bluez_output.${address//:/_}
  local requested_profile='' attempt cards profile_state a2dp_profile sinks

  # A connected A2DP service does not mean PipeWire selected that profile.
  printf 'Waiting for PipeWire stereo output…\n'
  sink_id='' sink=''
  for ((attempt = 0; attempt < 20; attempt++)); do
    cards=$(LC_ALL=C pactl list cards) || fail 'Could not list audio cards.'
    read -r profile_state a2dp_profile < <(awk -v card="$card" '
      /^Card #/ { matching = 0 }
      $1 == "Name:" && $2 == card { matching = 1 }
      matching && $1 ~ /^a2dp-sink[^:]*:$/ && /, available: yes\)$/ {
        name = substr($1, 1, length($1) - 1)
        if (!first) first = name
        available[name] = 1
      }
      matching && $1 == "Active" && $2 == "Profile:" { active = $3 }
      END {
        if (active in available) print "active", active
        else if (first) print "available", first
      }
    ' <<< "$cards")
    if [[ $profile_state == active ]]; then
      sinks=$(pactl list short sinks) || fail 'Could not list playback outputs.'
      read -r sink_id sink < <(awk -v prefix="$sink_prefix" '
        ($2 == prefix || index($2, prefix ".") == 1) && $5 == "2ch" {
          print $1, $2; exit
        }
      ' <<< "$sinks") && return 0
    elif [[ -n $a2dp_profile && $a2dp_profile != "$requested_profile" ]]; then
      printf 'Selecting stereo profile %s…\n' "$a2dp_profile"
      if ! pactl set-card-profile "$card" "$a2dp_profile"; then
        printf 'Could not select stereo profile %s.\n' "$a2dp_profile" >&2
        return 1
      fi
      requested_profile=$a2dp_profile
    fi
    sleep 0.25
  done
  return 1
}

printf 'Looking for a paired Bluetooth audio device…\n'
devices=$(bluetoothctl devices Paired) || fail 'Could not list paired Bluetooth devices.'
while read -r _ address name; do
  [[ -n $address ]] || continue
  info=$(bluetoothctl info "$address")
  [[ $info == *"$audio_sink_uuid"* ]] || continue

  if ! recover_stereo; then
    printf 'Direct stereo recovery did not work; trying a full reconnect…\n'
    info=$(bluetoothctl info "$address") || fail "Could not check connection status for $name."
    if [[ $info == *'Connected: yes'* ]]; then
      printf 'Disconnecting %s…\n' "$name"
      timeout --verbose 10s bluetoothctl disconnect "$address" || fail "Could not disconnect $name."
    fi
    printf 'Connecting to %s…\n' "$name"
    timeout --verbose 15s bluetoothctl connect "$address" || fail "Could not connect to $name. Check that it is awake and in range."
    recover_stereo || fail 'No active A2DP stereo output appeared for the headset.'
  fi

  printf 'Switching playback to %s…\n' "$name"
  pactl set-default-sink "$sink" || fail 'Could not set the headset as the default audio output.'
  streams=$(pactl list short sink-inputs) || fail 'Default output switched, but current playback streams could not be listed.'
  status=0
  while read -r stream current_sink _; do
    [[ -n $stream && $current_sink != "$sink_id" ]] || continue
    pactl move-sink-input "$stream" "$sink" || status=1
  done <<< "$streams"
  (( status == 0 )) || fail 'Default output switched, but some playback streams could not be moved.'
  printf 'OK: Bluetooth stereo is ready on %s.\n' "$name"
  exit 0
done <<< "$devices"

fail 'No paired Bluetooth audio device found.'
