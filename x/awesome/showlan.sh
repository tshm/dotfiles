#!/bin/sh
LANG=C
FG="white"
BG="#555"
W=250
X=$(xwininfo -root | awk "/Width:/{print \$2-$W}")
Y=20
GEOM="-fg $FG -bg $BG -y $Y -x $X -w $W"
SEL=$(\
(ip addr; /sbin/iwconfig) | awk '\
 /inet.*eth0/{ eth0_addr=$2; }\
 /inet.*wlan0/{wlan0_addr=$2; }\
 /ESSID/{ essid=$4; }\
 END{ print "--- NETWORKS ---";\
      print "eth0: ",eth0_addr;\
			print "wlan0:",wlan0_addr,"\n-->",essid; }\
 ' | dzen2 $GEOM -fn rk16 -ta c -sa l -p -l 3 -m \
 -e 'onstart=uncollapse,unhide;button3=exit;button1=menuprint,exit;leaveslave=exit;' ) 
case $SEL in
	eth0*) /sbin/ifconfig | grep -q "eth0" && sudo ifdown eth0 || sudo ifup eth0;;
	wlan0*) /sbin/ifconfig | grep -q "wlan0" && sudo ifdown wlan0 || sudo ifup wlan0;;
	*ESSID*) ESSID=$( ( echo "ESSID"; sudo iwlist wlan0 scan | awk -F \" '/ESSID/{print $2}' ) |\
	  dzen2 -fn rk16 -sa l -p -l 10 -m -e 'onstart=uncollapse,unhide;button3=exit;button1=menuprint,exit;leaveslave=exit' );
		sudo ifdown wlan0;  sudo ifup wlan0="$ESSID";;
esac

