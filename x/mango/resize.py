#!/usr/bin/env python3
"""Leave maximized/fullscreen mode before cycling the scroller width."""
import json
import subprocess

client = json.loads(subprocess.check_output(["mmsg", "get", "focusing-client"], text=True))
if not client or "id" not in client:
    raise SystemExit(0)

for flag, action in (
    ("is_fullscreen", "togglefullscreen"),
    ("is_maximized", "togglemaximizescreen"),
    (None, "switch_proportion_preset"),
):
    if flag is None or client[flag]:
        subprocess.run(["mmsg", "dispatch", action, f"client,{client['id']}"], check=True)
