#!/usr/bin/env bash
set -euo pipefail

ensure_warp_cli() {
  if ! command -v warp-cli >/dev/null 2>&1; then
    echo "warp-cli is not installed or not in PATH" >&2
    exit 1
  fi
}

current_warp_status() {
  local status

  status=$(
    warp-cli --json status |
      sed -n 's/.*"status":[[:space:]]*"\([^"]*\)".*/\1/p'
  )

  if [ -z "$status" ]; then
    echo "Unable to determine current WARP status" >&2
    exit 1
  fi

  printf '%s\n' "$status"
}

set_warp_state() {
  local target="$1"
  local status

  status=$(current_warp_status)

  case "$target:$status" in
    connect:Connected | disconnect:Disconnected)
      ;;
    connect:Disconnected)
      warp-cli connect >/dev/null
      ;;
    disconnect:Connected)
      warp-cli disconnect >/dev/null
      ;;
    *)
      printf 'Cloudflare WARP is %s; wait for it to settle and try again\n' "$status" >&2
      exit 1
      ;;
  esac

  printf 'Cloudflare WARP status: %s\n' "$(current_warp_status)"
}
