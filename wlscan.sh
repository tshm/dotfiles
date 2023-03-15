#!/bin/sh
LANG=C
set -e

IF=$1
logger "bring up $IF"
/sbin/ifconfig "$IF" up
A='No scan results'
while [ "$A" = "No scan results" ]; do
	sleep 1
	A=$(iwlist scan 2>/dev/null)
done
/sbin/ifconfig "$IF" down

while read -r key name; do
	echo "$A" | grep -q "$key" && logger "ESSID: $name" && echo "$name" && exit 0
done
exit 1
