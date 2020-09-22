@echo off&setlocal enabledelayedexpansion
title %cd%
:g
set n=
cls&echo  %cd%Portable Soft\&echo\
for /f "delims=" %%a in ('type "portable soft\..ln"') do set /a n+=1&set  p!n!=%%~a&echo 	!n!.%%~a
echo\&set /p i=Please Enter[1-%n%]:
echo %i%|findstr [1-%n%]>nul&start "" "%cd%Portable Soft\!p%i%!"||goto :g
exit