#!/bin/sh
CONTENT=$(curl -s http://ip-api.com/json/)
echo $CONTENT
longitude=$(echo $CONTENT | jq .lon)
latitude=$(echo $CONTENT | jq .lat)
wlsunset -l $latitude -L $longitude 
