::code by betterlife cmd@win10 20170905
@echo off
setlocal enabledelayedexpansion
title Backup Tools
::����Ŀ¼
call :back_timename
set fs=d:\XYGL\FDA\laundry.btf

call :driveu

if "%Driveu_1%"=="" (
	echo δ�ҵ�U��.
	ping /n 3 127.0.0.1 >nul&exit
	) else ( 
	copy /y %fs%  %Driveu_1: =%\laundry_%back_timename%.btf >nul
	echo �������.
	ping /n 3 127.0.0.1 >nul&exit
)



:driveu
(for /f "tokens=2 delims==" %%a in ('wmic LogicalDisk where "DriveType='2'" get DeviceID /value') do (
	set /a count+=1  
	set Driveu_!count!=%%a  
))>nul 2>&1
goto :eof


:back_timename
set back_timename=%date:~,10%
set back_timename=%back_timename:/=%
set back_timename=%back_timename:-=%
set back_timename=%back_timename: =%
set back_timename=%back_timename::=%
goto :eof
