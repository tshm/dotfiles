#/usr/bin/bash
DEBUG=0
[ -z "$1" ] && echo "need a threshold argument" && exit
TH=$1
URL='https://maker.ifttt.com/trigger/burn/with/key/bCxTnGJ_T9EXjds2Ut68Vs'
HEAD='Content-Type: application/json'

function post {
  echo "post: $1"
  [ $DEBUG -eq 1 ] && return -1
  curl -X POST -H "$HEAD" -d '{"value1":"'$1'"}' $URL
  return -1
}

function check {
  x=$(echo "$1 > $TH" | bc)
  [ $x -eq 1 ] && return -1
  return 0
}

sensors -u \
  | sed -ne '/temp2_input/s/.*: //p' \
  | while read t; do check $t || { post $t; exit -1; }; done \
  && echo "OK" || echo "NG"

