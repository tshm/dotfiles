#!/bin/sh
cd $(dirname $0)

HOST=insp.hn.org
PASS=$(cat ./.ddns.passwd)
URL=https://inspzqj32v3.hn.org/update.php 
RIP=$(host $HOST | cut -d' ' -f4)
IP=$(curl -s http://ipinfo.io/ip)

echo RIP=$RIP
echo IP=$IP
[ "$RIP" = "$IP" ] && exit

curl -s --data-urlencode hostname=$HOST \
        --data-urlencode password=$PASS \
        --data-urlencode ipv4=$IP \
        $URL | grep code:

