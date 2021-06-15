#!/bin/bash
set -v
MUSIC/samples "$1".mac "$1".csd "$1"a.csd '2014' '216'
if [ $? -eq 0 ]  
then  
  echo "Successfully excuted samples" 
else   
  echo "Samples failed" 
  exit 1  
fi
export SFDIR="/home/prent/Music/sflib"
echo $SFDIR
ls $SFDIR -lt | head
csound "$1".csd -O"$1"a.log
csound "$1"a.csd -O"$1"b.log
cat "$1"a.log "$1"b.log >"$1".log
grep 'invalid' "$1".log | sort
grep 'range' "$1".log | sort
grep 'init error' "$1".log | sort
grep 'replacing previous' "$1".log | sort
echo "$2"
if [ "$2" == "" ]; then
    play $SFDIR/"$1"a.wav
fi
