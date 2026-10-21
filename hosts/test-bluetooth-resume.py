#!/usr/bin/env python3
"""Run with: python3 hosts/test-bluetooth-resume.py (requires Nix and Bash)."""
import json
from pathlib import Path
import subprocess
import tempfile


with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    (root / "bin").mkdir()
    bluetoothctl = root / "bin/bluetoothctl"
    bluetoothctl.write_text('''#!/usr/bin/env bash
case "$1" in
  devices)
    printf 'Device AA:BB:CC:DD:EE:%02d Device with spaces\\n' {1..5}
    ;;
  info)
    case "$2" in
      *01) printf 'Icon: audio-headset\\nTrusted: yes\\nConnected: no\\n' ;;
      *02) printf 'Icon: input-keyboard\\nTrusted: no\\nConnected: no\\n' ;;
      *03) printf 'Icon: input-keyboard\\nTrusted: yes\\nConnected: yes\\n' ;;
      *) printf 'Icon: input-keyboard\\nTrusted: yes\\nConnected: no\\n' ;;
    esac
    ;;
  --timeout)
    echo "$4" >> "${0%/bin/bluetoothctl}/connections"
    [[ $4 != *04 ]]
    ;;
  *) exit 1 ;;
esac
''')
    bluetoothctl.chmod(0o755)
    module = Path(__file__).resolve().with_name("gui.nix")
    expression = (
        f'(import {module} {{ pkgs.bluez = {json.dumps(directory)}; }})'
        '.powerManagement.resumeCommands'
    )
    script = json.loads(subprocess.check_output(
        ["nix-instantiate", "--eval", "--strict", "--json", "--expr", expression],
        text=True,
    ))
    result = subprocess.run(["bash", "-e", "-c", script], capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    assert (root / "connections").read_text().splitlines() == [
        "AA:BB:CC:DD:EE:04", "AA:BB:CC:DD:EE:05",
    ], "Only disconnected, trusted keyboards should be connected, even after a failure"
    assert "Bluetooth keyboard reconnect failed: AA:BB:CC:DD:EE:04" in result.stderr
    print("PASS: skips audio/untrusted/connected devices; reports failure and continues")
