::code by nameyu8023 cmd&Win 8
@echo off
title 搜索X天之前的文件
mode con: cols=60 lines=20
color 5a
setlocal enabledelayedexpansion
echo\
echo                搜索XX天之前的文件
echo\
set path_0=%~dp0
set /p path_0=搜索目录(默认当前目录):
echo %path_0%
echo\
set path_1=n
set /p path_1=包含子目录? y/n(默认n):
echo %path_1%
echo\
if "%path_1%"=="y" set path_1=/s
if "%path_1%"=="n" set path_1=
set path_3=*.*
set /p path_3=搜索标准     (默认*.*):
echo %path_3%
echo\
set path_2=10
set /p path_2=输入天数      (默认10):
echo %path_2%
cls
echo         正在搜索...
echo --------------------------------------
echo 搜索目录:%path_0%
echo 含子目录:%path_1%
echo 搜索标准:%path_3%
echo 包含天数:%path_2%
echo --------------------------------------
echo\
for /f "delims=" %%a in ('forfiles /p %path_0% /m %path_3% %path_1% /d -%path_2% /c "cmd /c echo @path" 2^>nul') do (
	echo %%a >>filelog%path_2%.txt
	set /a num+=1
	title 搜索X天之前的文件 !num!
)
(echo --------------------------------------
echo 搜索目录:%path_0%
echo 含子目录:%path_1%
echo 搜索标准:%path_3%
echo 包含天数:%path_2%
echo 文件数量:!num!
echo 搜索日期:%date%%time%
echo --------------------------------------
)>>filelog%path_2%.txt
echo         已完成,日志保存在当前目录[filelog%path_2%.txt]
START filelog%path_2%.txt
pause>nul
exit