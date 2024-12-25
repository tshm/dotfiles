#!/usr/bin/bash
eval "$(sed '/^#/d; /^$/d; s/^/export /' .*env | xargs -0)"
restic backup "$BKUP_SRC"
restic forget --keep-weekly 5 --keep-monthly 5 --keep-yearly 2 --prune
