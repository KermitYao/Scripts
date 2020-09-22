@echo off&setlocal enabledelayedexpansion
if not exist "%~1" exit /b 0
title make  .  %cd%
echo File [%~1] make.
echo\
echo --------------------

for /f "delims=,. tokens=2" %%a in ('type "%~1"^|find /i "#pragma"') do set comment=%%a&set comment=!comment:"=!
if "%comment%"=="" (
	gcc "%~1" -o "%temp%\%~n1_m.exe" 
) else (

	gcc "%~1" -l%comment% -o "%temp%\%~n1_m.exe"  
)

if not exist "%temp%\%~n1_m.exe" (
	echo make error.
	echo --------------------
)
call "%temp%\%~n1_m.exe"
echo\
echo --------------------
echo ·µ»ØÖµ:%errorlevel%

echo\
echo\
pause&exit /b 0