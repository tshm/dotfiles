#!/bin/sh
hyprctl dispatch layoutmsg focusmaster master
hyprshell simple --sort-recent -w
hyprctl dispatch layoutmsg swapwithmaster
