@echo off
setlocal enabledelayedexpansion
mode con: cols=77 lines=45
color 6f
title tcp^&port ����״̬���.
:t
set LISTENING=������
set ESTABLISHED=������
set TIME_WAIT=��ʱ 1
set  CLOSE_WAIT=��ʱ 2
set COUNT=0
echo ���ڼ���...
echo -------------------------------------------------->TcpPort.log
(
for %%z in (LISTENING ESTABLISHED TIME_WAIT CLOSE_WAIT)  do (
	::ԭʼ��Ϣ��ȡ
	for /f "tokens=1-5" %%a in ('netstat /ano ^| find /i "%%z"') do (
		if  %%e neq 0 (
			if %%e neq 4 (
				::��ȡ��ؽ���
				for /f "delims=." %%y in ('tasklist /nh /fi "pid eq %%e"') do set "Process=%%y"
					set /a COUNT+=1
					call :sp %%b & set "str_1=!tmp2!"
					call :sp %%c & set "str_2=!tmp1!:!tmp2!"
					echo  [local:!str_1!] [!str_2!] !%%d! !Process!.exe	
			)
		)	
	)
)
)>>TcpPort.log

::���������
echo -------------------------------------------------->>TcpPort.log
echo [������ַ�Ͷ˿�]   [�ⲿ��ַ�Ͷ˿�]   [����״̬]   [��ؽ���]>>TcpPort.log
cls
more TcpPort.log
echo --------------------------------------------------
echo �������� [!count!] �´�ˢ��ʱ�� :
for /l %%a in (20,-1,0) do (
	ping /n 2 127.1 >nul
	set /p=%%a   <nul
	set /p=<nul

)
goto t

::ip����
:sp
set tmp=%1
set tmp=!tmp:::=!
for /f "delims=: tokens=1,2" %%a in ("!tmp!") do (
	set str_tmp1=%%a
	call :ty str_tmp1
	call :ty1 15 !t_num! str_tmp1

	set str_tmp2=%%b
	call :ty str_tmp2
	call :ty1 5 !t_num! str_tmp2

set "tmp1=!str_tmp1!" & set "tmp2=!str_tmp2!"
)
goto :eof

::�ַ�����
:ty
for /l %%a in (0,1,1000) do (
	if "!%1:~%%a,1!"=="" (
		set t_num=%%a
		goto :eof
		)
)
goto :eof

::��ӡ�Ű�
:ty1
set "kg= "
set /a kg_num=%1-%2
if not !kg_num! equ 0 (
	for /l %%a in (1,1,!kg_num!) do (
		set "%3=!%3!!kg!"
	)
)
goto :eof