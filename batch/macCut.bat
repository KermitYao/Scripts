@echo off
setlocal enabledelayedexpansion


(for /f "delims=" %%a in ('type macList.txt') do (
	call :cutMac %%a
	echo !tmpCount!
))>mac_new.txt
pause
exit


:cutMac
set strMac=%1
set tmpCurr=
set tmpCount=
for /l %%l in (0,2,10) do (
	set tmpCurr=!strMac:~%%l,2!
	set tmpCount=!tmpCount!!tmpCurr!-
	
)
set tmpCount=!tmpCount:~0,-1!
goto :eof