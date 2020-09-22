@echo off
setlocal enabledelayedexpansion
for /f "delims=: tokens=1*" %%a in ('systeminfo^|findstr "KB"') do (
	set tmp=%%b
	set tmp=!tmp:KB=!
	set tmp=!tmp: =!
	echo uninstall:[KB!tmp!]
	wusa /quiet /norestart /uninstall /KB:!tmp!
)
echo Uninstall done.
echo Please restart computer
pause