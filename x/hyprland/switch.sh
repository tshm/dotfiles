#!/bin/sh
hyprctl dispatch layoutmsg focusmaster master
hyprswitch simple --sort-recent -w
hyprctl dispatch layoutmsg swapwithmaster

