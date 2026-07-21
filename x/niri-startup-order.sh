#!/usr/bin/env bash
set -euo pipefail

readonly WAIT_TIMEOUT_SECONDS=45
readonly WAIT_INTERVAL_SECONDS=0.2

log() {
  printf 'niri-startup-order: %s\n' "$*" >&2
}

matching_window_count() {
  local app_pattern="$1"
  local title_pattern="$2"
  local windows_json

  if ! windows_json=$(niri msg --json windows); then
    printf '0\n'
    return 1
  fi

  python3 -c '
import json
import re
import sys

app_pattern, title_pattern = sys.argv[1:3]
app_re = re.compile(app_pattern) if app_pattern else None
title_re = re.compile(title_pattern) if title_pattern else None
windows = json.load(sys.stdin)

count = 0
for window in windows:
    app_id = str(window.get("app_id") or "")
    title = str(window.get("title") or "")
    if (app_re and app_re.search(app_id)) or (title_re and title_re.search(title)):
        count += 1

print(count)
' "$app_pattern" "$title_pattern" <<<"$windows_json"
}

wait_for_new_window() {
  local description="$1"
  local app_pattern="$2"
  local title_pattern="$3"
  local previous_count="$4"
  local deadline=$((SECONDS + WAIT_TIMEOUT_SECONDS))
  local current_count=0

  while (( SECONDS < deadline )); do
    current_count=$(matching_window_count "$app_pattern" "$title_pattern") || current_count=0
    if (( current_count > previous_count )); then
      return 0
    fi

    sleep "$WAIT_INTERVAL_SECONDS"
  done

  log "timed out waiting for ${description}; continuing startup"
  return 1
}

spawn_and_wait() {
  local description="$1"
  local app_pattern="$2"
  local title_pattern="$3"
  local previous_count=0

  shift 3

  previous_count=$(matching_window_count "$app_pattern" "$title_pattern") || previous_count=0
  "$@" &
  wait_for_new_window "$description" "$app_pattern" "$title_pattern" "$previous_count" || true
}

waybar &
spawn_and_wait "Zen Browser" '(?i)(^zen$|app\.zen_browser\.zen)' '(?i)zen browser' zen
spawn_and_wait "WezTerm" '^org\.wezfurlong\.wezterm$' '(?i)wezterm' wezterm
spawn_and_wait "Beeper" '(?i)(beepertexts|beeper|com\.automattic\.beeper)' '(?i)beeper' beeper

nirius &
fcitx5 -d --replace &

opentypeless &
