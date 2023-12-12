@echo off
set /p ip=输入要监测的目的地址:
title 正在持续检测ip连接信息 %ip%

:loop
echo %date% %time%
for /f "tokens=5" %%a in ('netstat -anop tcp^|findstr "%ip%"') do (
	for /f "delims=, tokens=1" %%x in ('tasklist /fi "pid eq %%a" /nh /fo csv') do (
		for /f "delims=" %%k in ('wmic process where processid^=%%a get executablepath') do (
			echo ip:%ip% - 进程号: %%a - 进程名: %%x - 进程路径:%%k
		)
	)
)
ping /n 4 127.0.0.1 >nul
goto :loop
pause