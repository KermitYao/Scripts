@echo off
setlocal enabledelayedexpansion
echo 正在收集信息...
for /f "delims=" %%a in ('wmic product get') do (
	for /f "delims={} tokens=2*" %%x in ('echo "%%~a"^| findstr /c:"McAfee Endpoint Security 自适应威胁防护"') do set avCode=%%x&set mcafee_1=%%x
	for /f "delims={} tokens=2*" %%x in ('echo "%%~a"^| findstr /c:"McAfee Endpoint Security 威胁防护"') do set avCode=%%x&set mcafee_2=%%x
	for /f "delims={} tokens=2*" %%x in ('echo "%%~a"^| findstr /c:"McAfee Endpoint Security 防火墙"') do set avCode=%%x&set mcafee_3=%%x
	for /f "delims={} tokens=2*" %%x in ('echo "%%~a"^| findstr /c:"McAfee Endpoint Security Web 控制"') do set avCode=%%x&set mcafee_4=%%x
	for /f "delims={} tokens=2*" %%x in ('echo "%%~a"^| findstr /c:"McAfee Data Exchange Layer for MA"') do set avCode=%%x&set mcafee_5=%%x
	for /f "delims={} tokens=2*" %%x in ('echo "%%~a"^| findstr /c:"McAfee Endpoint Security 平台"') do set avCode=%%x&set mcafee_6=%%x
	for /f "delims={} tokens=2*" %%x in ('echo "%%~a"^| findstr /c:"McAfee Active Response"') do set avCode=%%x&set mcafee_7=%%x
	for /f "delims={} tokens=2*" %%x in ('echo "%%~a"^| findstr /c:"McAfee Agent"') do set avCode=%%x&set mcafee_8=%%x
)

for /l %%a in (1 1 9) do (
	if not "!mcafee_%%a!"=="" (
		echo. 卸载 {!mcafee_%%a!}
		msiexec /qn /x {!mcafee_%%a!}&&echo ok||echo failed
	)
)

call :avUninstMcAfee

echo end...
pause
exit /b 0

:avUninstMcAfee
set pathList="C:\Program Files (x86)\McAfee\Agent\x86\FrmInst.exe" "C:\Program Files\McAfee\Agent\x86\FrmInst.exe" "C:\Program Files (x86)\McAfee\Common Framework\FrmInst.exe" "C:\Program Files\McAfee\Common Framework\FrmInst.exe"

for %%a in (%pathList%) do (
	if exist %%a (
		echo %%a found
		start /min /b %%~fsa /Forceuninstall
	)
)
goto :eof