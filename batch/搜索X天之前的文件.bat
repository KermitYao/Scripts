::code by nameyu8023 cmd&Win 8
@echo off
title ����X��֮ǰ���ļ�
mode con: cols=60 lines=20
color 5a
setlocal enabledelayedexpansion
echo\
echo                ����XX��֮ǰ���ļ�
echo\
set path_0=%~dp0
set /p path_0=����Ŀ¼(Ĭ�ϵ�ǰĿ¼):
echo %path_0%
echo\
set path_1=n
set /p path_1=������Ŀ¼? y/n(Ĭ��n):
echo %path_1%
echo\
if "%path_1%"=="y" set path_1=/s
if "%path_1%"=="n" set path_1=
set path_3=*.*
set /p path_3=������׼     (Ĭ��*.*):
echo %path_3%
echo\
set path_2=10
set /p path_2=��������      (Ĭ��10):
echo %path_2%
cls
echo         ��������...
echo --------------------------------------
echo ����Ŀ¼:%path_0%
echo ����Ŀ¼:%path_1%
echo ������׼:%path_3%
echo ��������:%path_2%
echo --------------------------------------
echo\
for /f "delims=" %%a in ('forfiles /p %path_0% /m %path_3% %path_1% /d -%path_2% /c "cmd /c echo @path" 2^>nul') do (
	echo %%a >>filelog%path_2%.txt
	set /a num+=1
	title ����X��֮ǰ���ļ� !num!
)
(echo --------------------------------------
echo ����Ŀ¼:%path_0%
echo ����Ŀ¼:%path_1%
echo ������׼:%path_3%
echo ��������:%path_2%
echo �ļ�����:!num!
echo ��������:%date%%time%
echo --------------------------------------
)>>filelog%path_2%.txt
echo         �����,��־�����ڵ�ǰĿ¼[filelog%path_2%.txt]
START filelog%path_2%.txt
pause>nul
exit