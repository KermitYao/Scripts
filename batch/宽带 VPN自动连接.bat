::code by nameyu8023 cmd@Win7
@echo off
mode con: cols=40 lines=15
color 6f
title ��������,����ر�.



::---------------------�û�����-----------------------------
:: 1 Ϊ�ظ��������,��ͨ���Զ����²��ţ� 0 Ϊ����һ�κ��˳�����
set test_loop=1
set test_net=192.168.4.250
set adsl_name=��������
set adsl_id=vpn001
set adsl_pw=vpn001
::---------------------�û�����-----------------------------



echo �������� [%adsl_name%]...
call :adsl %adsl_name% %adsl_id% %adsl_pw%
ping /n 2 127.1 >nul



if not "%test_loop%"=="1" exit


::ÿ 10 ����һ�����磬��ͨ����²���.
:net_chk
call :net
if "%tm%"=="false" (
	echo ����Ͽ� %date% %time% >>d:\net_chk.log
	call :adsl %adsl_name% %adsl_id% %adsl_pw%
	) else (
	ping /n 5 127.1 >nul
)
ping /n 10 127.1 >nul
goto :net_chk


::��������Ƿ���ͨ
:net
set tm=false
for /f "delims=" %%a in ('ping /n 2 %test_net% ^| findstr /i "TTL"') do (
	if not "%%a"=="" set tm=true
)

if "%tm%"=="false" (
	echo ����δ���� %date% %time% >>d:\net_chk.log
	echo ����δ���� %time%
	) else (
	echo ���������� %date% %time% >>d:\net_chk.log
	echo ���������� %time%
)

goto :eof


::��������
:adsl
echo ���ڲ��� %date% %time% >>d:\net_chk.log
Rasdial %1 %2 %3 >nul
goto :eof