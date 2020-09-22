@echo off&setlocal enabledelayedexpansion
if not exist "%~1" exit /b 0
title make  .  %cd%
set path=%path%;Z:\Soft Ware\MinGW\bin
echo File [%~1] make.
echo\
echo --------------------

for /f "delims=,. tokens=2" %%a in ('type "%~1"^|find /i "#pragma"') do set comment=%%a&set comment=!comment:"=!
if "%comment%"=="" (
	gcc "%~1" -o "%temp%\%~n1_m.exe" 
) else (
	echo %comment%
	gcc "%~1" -l%comment% -o "%temp%\%~n1_m.exe"  
)

if not exist "%temp%\%~n1_m.exe" (
	echo make error.
	echo --------------------
	goto nexit
)
call "%temp%\%~n1_m.exe"
echo\
echo --------------------
echo return:%errorlevel%
:nexit
echo\
echo\
pause&exit /b 0