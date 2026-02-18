#!/usr/bin/env bash

# Get all sink IDs
sinks=$(pactl list short sinks | cut -f1)

# Get the current default sink name
current_sink_name=$(pactl get-default-sink)

# Find the ID corresponding to the current sink name
current_sink_id=$(pactl list short sinks | grep "$current_sink_name" | cut -f1)

# Find the next sink in the list
next_sink_id=""
found_current=false

for sink in $sinks; do
    if [ "$found_current" = true ]; then
        next_sink_id=$sink
        break
    fi
    if [ "$sink" = "$current_sink_id" ]; then
        found_current=true
    fi
done

# If next sink is empty (end of list), wrap around to the first sink
if [ -z "$next_sink_id" ]; then
    next_sink_id=$(echo "$sinks" | head -n1)
fi

# Set the new default sink
pactl set-default-sink "$next_sink_id"

# Move all currently playing streams to the new sink
inputs=$(pactl list short sink-inputs | cut -f1)
for input in $inputs; do
    pactl move-sink-input "$input" "$next_sink_id"
done

# Send a notification
sink_desc=$(pactl list sinks | grep -A 100 "Sink #$next_sink_id" | grep "Description:" | head -n 1 | cut -d: -f2 | xargs)
notify-send -u low "Audio Output" "Switched to: $sink_desc" -i audio-volume-high
