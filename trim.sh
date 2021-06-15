#!/bin/bash
set -v
export  SFDIR="/home/Music/sflib"
echo $SFDIR
cp xref.txt xref"$2".txt 
ls $SFDIR -lt | head
csound -U sndinfo $SFDIR/"$1"a.wav
csound "$1"c.csd >>"$1"c.log
sox $SFDIR/"$1"a-c.wav save1.wav reverse
sox save1.wav save2.wav silence 1 0.01 0.01
sox save2.wav save1.wav reverse
sox save1.wav $SFDIR/"$1"-t"$2".wav silence 1 0.01 0.01
csound -U sndinfo $SFDIR/"$1"-t"$2".wav
ffmpeg -i $SFDIR/"$1"-t"$2".wav -b:a 320k $SFDIR/"$1"-t"$2".mp3
eyeD3 --artist="Prent Rodgers" --album="Machines" --title="Machines3 v"$2"" --track="03" --genre="Microtonal" --release-year="2018" --add-image BosendorNew.jpg:FRONT_COVER $SFDIR/"$1"-t"$2".mp3
mv $SFDIR/"$1"-t"$2".mp3 /home/Uploads
rm save1.wav
rm save2.wav


