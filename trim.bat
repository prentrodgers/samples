echo on
set sfdir=C:\Users\PrentRodgers\Music\sflib
echo convolv, trim, convert to MP3
copy xref.txt xref%2.txt /y
copy %1.log %1%2.log /y /v
csound -U sndinfo "%sfdir%\%1a.wav"
csound %1c.csd >>%1.log
csound -U sndinfo "%sfdir%\%1a-c.wav
sox "%sfdir%\%1a-c.wav" save1.wav reverse
sox save1.wav save2.wav silence 1 0.01 0.01
sox save2.wav save1.wav reverse
sox save1.wav "%sfdir%\%1-t%2.wav" silence 1 0.01 0.01
csound -U sndinfo %1-t%2.wav
erase save1.wav
erase save2.wav
"C:\Program Files (x86)\FFmpeg for Audacity\ffmpeg" -i "%sfdir%\%1-t%2.wav" -ab 320k "%sfdir%\%1-t%2.mp3"
move "%sfdir%\%1-t%2.mp3" C:\Users\PrentRodgers\Dropbox\Uploads