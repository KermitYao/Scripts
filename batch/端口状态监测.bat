@echo off
setlocal enabledelayedexpansion
mode con: cols=77 lines=45
color 6f
title tcp^&port 连接状态监测.
:t
set LISTENING=监听中
set ESTABLISHED=连接中
set TIME_WAIT=超时 1
set  CLOSE_WAIT=超时 2
set COUNT=0
echo 正在加载...
echo -------------------------------------------------->TcpPort.log
(
for %%z in (LISTENING ESTABLISHED TIME_WAIT CLOSE_WAIT)  do (
	::原始信息提取
	for /f "tokens=1-5" %%a in ('netstat /ano ^| find /i "%%z"') do (
		if  %%e neq 0 (
			if %%e neq 4 (
				::提取相关进程
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

::进行最后处理
echo -------------------------------------------------->>TcpPort.log
echo [本机地址和端口]   [外部地址和端口]   [连接状态]   [相关进程]>>TcpPort.log
cls
more TcpPort.log
echo --------------------------------------------------
echo 连接数量 [!count!] 下次刷新时间 :
for /l %%a in (20,-1,0) do (
	ping /n 2 127.1 >nul
	set /p=%%a   <nul
	set /p=<nul

)
goto t

::ip分离
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

::字符计算
:ty
for /l %%a in (0,1,1000) do (
	if "!%1:~%%a,1!"=="" (
		set t_num=%%a
		goto :eof
		)
)
goto :eof

::打印排版
:ty1
set "kg= "
set /a kg_num=%1-%2
if not !kg_num! equ 0 (
	for /l %%a in (1,1,!kg_num!) do (
		set "%3=!%3!!kg!"
	)
)
goto :eof