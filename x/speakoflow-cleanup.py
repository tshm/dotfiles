#!/usr/bin/env python3
"""Apply the tracked cleanup instructions while SpeakoFlow is stopped."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

PROMPT_ID = "dotfiles_japanese_cleanup"


def apply(path, prompt):
    if not prompt.strip():
        raise ValueError("Cleanup prompt must not be empty")
    document = json.loads(path.read_text())
    settings = document["settings"]
    settings["post_process_prompts"] = [
        item for item in settings.get("post_process_prompts", [])
        if item["id"] != PROMPT_ID
    ] + [{"id": PROMPT_ID, "name": "Japanese editing (dotfiles)", "prompt": prompt}]
    settings["post_process_selected_prompt_id"] = PROMPT_ID
    settings["post_process_selected_tone_id"] = "none"
    settings["post_process_enabled"] = True
    settings["post_process_timeout_secs"] = 30
    backup = path.with_name(path.name + ".before-dotfiles")
    if not backup.exists():
        descriptor = os.open(backup, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(descriptor, "wb") as output, path.open("rb") as source:
            shutil.copyfileobj(source, output)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=path.parent, delete=False) as output:
            temporary = Path(output.name)
            json.dump(document, output, ensure_ascii=False, indent=2)
            output.write("\n")
            output.flush()
            os.fsync(output.fileno())
        temporary.replace(path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    if subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", "speakoflow"], stdout=subprocess.DEVNULL).returncode == 0:
        raise SystemExit("Quit SpeakoFlow before applying its cleanup prompt")
    data = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
    path = data / "com.abhishekbarali.speakoflow/settings_store.json"
    if not path.exists():
        print("SpeakoFlow: first launch; initialize settings before applying cleanup")
        raise SystemExit(0)
    apply(path, Path(__file__).with_name("speakoflow-cleanup.txt").read_text())
    print("SpeakoFlow: Japanese editing (dotfiles) selected; AI cleanup enabled")
