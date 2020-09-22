::code by nameyu8023 cmd@Win8
@echo off
mode con: cols=65 lines=30
title ºÚ¿ÍµÛ¹ú^&ÊýÂëÓê
setlocal enabledelayedexpansion
set str=abcdefghijklmnopqrstuvwxyz1234567890+-/;:?$#@ABCDEFGHIJKLMNOPQRSTUVWXYZ
::set str=0100100100101100100

for /l %%a in (1,1,1000) do (
	if "!str:~%%a,1!"=="" (
		set str_num=%%a
		goto next
	)
)
:next
call :str_ver %str_num% str
set /p s=.   <nul
for /l %%a in (1,1,28) do (
	call :rnd str_rd %str_num%
	call :str_cut str_rdt str_!str_rd!
	set /p=!str_rdt! <nul
)
echo   .
set str_lx=
goto next


:str_ver
for /l %%a in (0,1,%1) do (
	set %2_%%a=!str:~%%a,1!
)
goto :eof

:rnd
set /a %1=!random!%%%2
goto :eof


:str_cut
set %1=!%2!
goto :eof