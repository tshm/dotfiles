#!/usr/bin/env python3
import html
import json
import os
import subprocess

layouts = {
    layout["symbol"]: layout["name"].replace("_", " ")
    for layout in json.loads(subprocess.check_output(["mmsg", "get", "layouts"]))["layouts"]
}
with subprocess.Popen(
    ["mmsg", "watch", "monitor", os.environ["WAYBAR_OUTPUT_NAME"]],
    stdout=subprocess.PIPE,
    text=True,
) as stream:
    previous = None
    for line in stream.stdout:
        symbol = json.loads(line)["layout_symbol"]
        if symbol == previous:
            continue
        previous = symbol
        print(json.dumps({
            "text": html.escape(symbol),
            "tooltip": html.escape(layouts.get(symbol, symbol)) + "\nSuper+Space: cycle layout",
            "class": symbol,
        }), flush=True)
