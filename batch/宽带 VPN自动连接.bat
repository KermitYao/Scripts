::code by nameyu8023 cmd@Win7
@echo off
mode con: cols=40 lines=15
color 6f
title 拨号连接,请勿关闭.



::---------------------用户变量-----------------------------
:: 1 为重复检测网络,不通则自动从新拨号， 0 为拨号一次后退出程序
set test_loop=1
set test_net=192.168.4.250
set adsl_name=北京网络
set adsl_id=vpn001
set adsl_pw=vpn001
::---------------------用户变量-----------------------------



echo 正在连接 [%adsl_name%]...
call :adsl %adsl_name% %adsl_id% %adsl_pw%
ping /n 2 127.1 >nul



if not "%test_loop%"=="1" exit


::每 10 秒检测一下网络，不通则从新拨号.
:net_chk
call :net
if "%tm%"=="false" (
	echo 网络断开 %date% %time% >>d:\net_chk.log
	call :adsl %adsl_name% %adsl_id% %adsl_pw%
	) else (
	ping /n 5 127.1 >nul
)
ping /n 10 127.1 >nul
goto :net_chk


::检测网络是否连通
:net
set tm=false
for /f "delims=" %%a in ('ping /n 2 %test_net% ^| findstr /i "TTL"') do (
	if not "%%a"=="" set tm=true
)

if "%tm%"=="false" (
	echo 网络未连接 %date% %time% >>d:\net_chk.log
	echo 网络未连接 %time%
	) else (
	echo 网络已连接 %date% %time% >>d:\net_chk.log
	echo 网络已连接 %time%
)

goto :eof


::拨号连接
:adsl
echo 正在拨号 %date% %time% >>d:\net_chk.log
Rasdial %1 %2 %3 >nul
goto :eof