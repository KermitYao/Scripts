@echo off
rem �Զ����ؽű�����
if "%~1" == "h" goto :begin
mshta vbscript:createobject("wscript.shell").run("%~fs0 h",0)(window.close)&&exit
:begin
setlocal enabledelayedexpansion
set titleStr=checkProcess

rem ��֤����Ψһ��
for /f "delims=, tokens=10" %%a in ('tasklist  /FO CSV /V ^| findstr /c:"%titleStr%"') do (
	if "%%~a"=="%titleStr%" (
		exit /b 1
	)
)

title %titleStr%
rem -------------var-----------
rem ������Ҫ�ػ��Ľ���
set checkList="jcp.exe,C:\Program Files (x86)\jatools\jcp.exe"  "Wireshark.exe,C:\Program Files\Wireshark\Wireshark.exe"
rem �������,������ͨ��ping ������, 1 Լ���� 0.8s
set sleep=4
rem ��־����·��
set logPath="%~0.log"

rem ��ѭ��
:loop
set taskList=
for /f "delims=, tokens=1*" %%a in ('tasklist  /FO CSV') do if not "%%a"=="" set taskList=%%~a,!taskList!
for %%a in (%checkList%) do (
	for /f "delims=, tokens=1*" %%x in (%%a) do (
		echo %taskList% | findstr /c:"%%x" >nul
		if "!errorlevel!"=="0" (
			call :logPrint "���̡�%%x���Ѵ���."
		) else (
			call :logPrint "δ�ҵ����̡�%%x��,��ʼ������%%y��" True
			if exist "%%~y" (
				start /b "%%~x" "%%~y"
			) else (
				call :logPrint "���̡�%%x��,����·��δ�ҵ���%%y��" True
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




