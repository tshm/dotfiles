#!/usr/bin/env python3
"""Live Mango smoke check; temporarily resizes the focused tiled scroller window."""
import json
from pathlib import Path
import subprocess
import time


def mmsg(*args):
    return subprocess.check_output(["mmsg", *args], text=True)


original = json.loads(mmsg("get", "focusing-client"))
client_id = original["id"]


def state():
    return json.loads(mmsg("get", "client", str(client_id)))


def dispatch(action):
    mmsg("dispatch", action, f"client,{client_id}")


def clear_state():
    if state()["is_fullscreen"]:
        dispatch("togglefullscreen")
    if state()["is_maximized"]:
        dispatch("togglemaximizescreen")


try:
    for mode in (None, "togglemaximizescreen", "togglefullscreen"):
        clear_state()
        dispatch("set_proportion,0.45")
        if mode:
            dispatch(mode)
        subprocess.run(["python3", str(Path(__file__).with_name("resize.py"))], check=True)
        time.sleep(0.2)
        after = state()
        assert not after["is_maximized"] and not after["is_fullscreen"], after
        assert abs(after["scroller_proportion"] - 0.3) < 0.001, after
        print(f"PASS {mode or 'normal'} -> normal, width preset 0.3")
finally:
    clear_state()
    dispatch(f"set_proportion,{original['scroller_proportion']}")
    if original["is_maximized"]:
        dispatch("togglemaximizescreen")
    if original["is_fullscreen"]:
        dispatch("togglefullscreen")
