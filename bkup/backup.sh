#!/usr/bin/env bash
cd $(dirname "$0") || exit
eval "$(sed '/^#/d; /^$/d; s/^/export /' .*env | xargs -0)"
restic backup --skip-if-unchanged "$BKUP_SRC"
restic forget --keep-weekly 5 --keep-monthly 5 --keep-yearly 2 --prune
