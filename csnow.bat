@echo off
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"
echo copy %1.mac %1.%fullstamp%.txt
copy %1.mac %1.%fullstamp%.txt
set sfdir=C:\Users\PrentRodgers\Music\sflib
samples %1.mac %1.csd %1a.csd 2014 217
@if errorlevel 1 goto error
@echo on
csound %1.csd -O%1a.log
@if errorlevel 1 goto error
csound %1a.csd -O%1b.log
@if errorlevel 1 goto error
@echo off
copy %1a.log+%1b.log %1.log
@find /i "invalid" %1.log | sort >save.txt
@type save.txt
@find /i "failed" %1.log
@find /i "error" %1.log
@find /i "range" %1.log
@find /i "overall" %1.log
@find /i "init error" %1.log
@find /i "memory allocate failure" %1.log
@find /i "replacing previous ftable" %1.log
@find /i "Total processing time:" %1.log
@rem lily
@rem copy samples.ly \cygwin\home\prodgers /y
@sndinfo %sfdir%\%1a.wav
@echo on
IF (%2)==() sox "%sfdir%\%1a.wav" -t waveaudio 0 -q
@echo off
@IF (%2)==(nop) goto end
@IF NOT (%2)==() trim %1 %2
@goto end
:error
@echo Preprocessor Samples or Csound failed. Most likely Samples failed.
:end
