@echo off
set /p ip=����Ҫ����Ŀ�ĵ�ַ:
title ���ڳ������ip������Ϣ %ip%

:loop
echo %date% %time%
for /f "tokens=5" %%a in ('netstat -anop tcp^|findstr "%ip%"') do (
	for /f "delims=, tokens=1" %%x in ('tasklist /fi "pid eq %%a" /nh /fo csv') do (
		for /f "delims=" %%k in ('wmic process where processid^=%%a get executablepath') do (
			echo ip:%ip% - ���̺�: %%a - ������: %%x - ����·��:%%k
		)
	)
)
ping /n 4 127.0.0.1 >nul
goto :loop
pause