#!/bin/sh

HOST=insp.hn.org
PASS=`cat ./.ddns.passwd`
URL=https://inspzqj32v3.hn.org/update.php 
IP=`curl -s http://ipinfo.io/ip`

echo IP=$IP

curl -s --data-urlencode hostname=$HOST \
        --data-urlencode password=$PASS \
        --data-urlencode ipv4=$IP \
        $URL | grep code:

