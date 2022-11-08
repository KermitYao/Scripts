@echo off
rem 自动隐藏脚本运行
if "%~1" == "h" goto :begin
mshta vbscript:createobject("wscript.shell").run("%~fs0 h",0)(window.close)&&exit
:begin
setlocal enabledelayedexpansion
set titleStr=checkProcess

rem 保证进程唯一性
for /f "delims=, tokens=10" %%a in ('tasklist  /FO CSV /V ^| findstr /c:"%titleStr%"') do (
	if "%%~a"=="%titleStr%" (
		exit /b 1
	)
)

title %titleStr%
rem -------------var-----------
rem 配置需要守护的进程
set checkList="jcp.exe,C:\Program Files (x86)\jatools\jcp.exe"  "Wireshark.exe,C:\Program Files\Wireshark\Wireshark.exe"
rem 检查周期,本质是通过ping 来检测的, 1 约等于 0.8s
set sleep=4
rem 日志保存路径
set logPath="%~0.log"

rem 主循环
:loop
set taskList=
for /f "delims=, tokens=1*" %%a in ('tasklist  /FO CSV') do if not "%%a"=="" set taskList=%%~a,!taskList!
for %%a in (%checkList%) do (
	for /f "delims=, tokens=1*" %%x in (%%a) do (
		echo %taskList% | findstr /c:"%%x" >nul
		if "!errorlevel!"=="0" (
			call :logPrint "进程【%%x】已存在."
		) else (
			call :logPrint "未找到进程【%%x】,开始启动【%%y】" True
			if exist "%%~y" (
				start /b "%%~x" "%%~y"
			) else (
				call :logPrint "进程【%%x】,启动路径未找到【%%y】" True
			)
		)
	)
)

ping -n %sleep% 127.0.0.1 >nul
goto :loop

:logPrint
echo %date% %time% -- "%~1"
if "%~2"=="True" (
	echo %date% %time% -- "%~1" >>%logPath%
)
goto :eof




