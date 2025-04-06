#!/bin/sh

execCommand=$1
className=$2
workspaceOnStart=$3

running=$(hyprctl -j clients | jq -r ".[] | select(.class == \"${className}\")")

if [ -z "$running" ]; then
	echo "start"
	hyprctl dispatch workspace "$workspaceOnStart"
	${execCommand} &
else
	echo "focus"
  hyprctl dispatch focuswindow "class:(${className})"
fi
