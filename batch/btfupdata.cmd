@echo off
title ngrain@betterlife
setlocal enabledelayedexpansion
set filePath_a="d:\xygl\fdb\"
set filePath_b="d:\"
set suffix="*.data"
set fileCount_a=0
set fileCount_b=0
set fileSpeed=1
set writePath="%temp%\btfClear.dat"
set back_vbs=%temp%\back%back_timename%.vbs
set back_wait=true
echo [#.btfFile.#]>%writePath%
echo 正在扫描...
for %%a in (%filePath_a% %filePath_b%) do (
	for /f "delims=" %%b in ('dir /a-d/b/s %%a%suffix%') do (
		echo %%b >>%writePath%
		set /a fileCount_a+=1
		if "!back_wait!" == "true" (call :back_wait !back_wait!&set back_wait=false) else (call :back_wait !back_wait!&set back_wait=true)
	)
)
echo\
cls
echo 开始更新...
echo\
for /f "delims=" %%a in ('type %writePath%') do (
	call :back_vbs_calc  !fileCount_b!/!fileCount_a!*100 %back_vbs%
	set /a fileCount_b+=1
	if !back_vbs_calc! == 100 set back_vbs_calc=100.00
	rem del /f/q %%a>nul 2>&1
	ping /n %fileSpeed% 127.0.0.1 >nul
	set /p=!back_vbs_calc! %%<nul 
	set /p=<nul
)
echo\
pause&exit


::等待动画 接收参数 [%1] true  false
:back_wait
if "%1" == "true" set /p=//////<nul
if "%1" == "false" set /p=\\\\\\<nul
set /p=<nul
goto :eof

::数学计算 接收参数 计算公式 [%1] 临时文件写入路径 [%2] 返回 [back_vbs_cal]
:back_vbs_calc
set back_vbs_calc=
echo WSH.echo " "^&Cdbl(%1) >%2
for /f "delims=. tokens=1*" %%x in ('cscript //nologo %2') do (
	set back_vbs_calc=%%y
	if not "%%y" == "" (set back_vbs_calc=.!back_vbs_calc:~,2!)
	if "%%x" == " " (set back_vbs_calc=0!back_vbs_calc!)
	set back_vbs_calc=%%x!back_vbs_calc!
	set back_vbs_calc=!back_vbs_calc: =!
)
goto :eof