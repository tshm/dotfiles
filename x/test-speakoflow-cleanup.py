#!/usr/bin/env python3
"""Run with python3 x/test-speakoflow-cleanup.py."""
import json
from pathlib import Path
import runpy
import tempfile

module = runpy.run_path(str(Path(__file__).with_name("speakoflow-cleanup.py")))
with tempfile.TemporaryDirectory() as directory:
    path = Path(directory) / "settings_store.json"
    original = {"settings": {"post_process_prompts": [{"id": "other", "name": "Other", "prompt": "Keep me"}], "private_setting": "preserved"}, "other_entry": 42}
    path.write_text(json.dumps(original))
    apply = module["apply"]
    apply(path, "日本語の指示\n")
    apply(path, "更新された指示\n")
    saved = json.loads(path.read_text())
    assert saved["other_entry"] == 42
    assert saved["settings"]["private_setting"] == "preserved"
    assert saved["settings"]["post_process_prompts"] == [original["settings"]["post_process_prompts"][0], {"id": "dotfiles_japanese_cleanup", "name": "Japanese editing (dotfiles)", "prompt": "更新された指示\n"}]
    assert saved["settings"]["post_process_selected_prompt_id"] == "dotfiles_japanese_cleanup"
    assert saved["settings"]["post_process_enabled"] is True
    assert saved["settings"]["post_process_selected_tone_id"] == "none"
    backup = path.with_name(path.name + ".before-dotfiles")
    assert json.loads(backup.read_text()) == original
    assert backup.stat().st_mode & 0o777 == 0o600
    assert path.stat().st_mode & 0o777 == 0o600
    path.write_text("{broken")
    try:
        apply(path, "指示")
    except json.JSONDecodeError:
        pass
    else:
        raise AssertionError("Invalid JSON must not be overwritten")
    assert path.read_text() == "{broken"
print("SpeakoFlow cleanup: preservation, replacement, backup and invalid-JSON checks passed")
