#!/bin/sh

export LANG=
bati="/sys/class/power_supply/BAT0"
opt="-w 20 -s #"
while :; do
	date=$(date "+%x %H:%M")
	batm=$(dzen2-dbar $opt -max $(cat $bati/energy_full) < $bati/energy_now)
	xsetroot -name "$date $batm"
	sleep 60
done
