#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Cloudflare WARP Disconnect
# @vicinae.mode compact
# @vicinae.keywords ["vpn", "cloudflare", "warp", "disconnect"]
# @vicinae.description Disconnect Cloudflare WARP from Vicinae.
# @vicinae.exec ["bash"]

set -euo pipefail

script_dir=$(unset CDPATH; cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/cloudflare-warp-common.sh"

ensure_warp_cli
set_warp_state disconnect
