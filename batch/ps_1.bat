@echo off
setlocal enabledelayedexpansion
rem ------sys var--------
set powershellScriptFunc="powershellScriptFunc"
set powershellScriptFileName=%temp%\pstmp.ps1
rem ------sys var--------

ver|find "版本 5.">nul&&set sysStatus=True
if  "%sysStatus%"=="True" (
    echo 不被支持的系统!
    pause
    exit /b 0
)

call :getUac
if not "%returnValue%"=="True" (
    echo 权限不足，请以管理员身份运行!
    pause
    exit /b 0
)

call :getPowershellLine %0
if "%returnValue%"=="False" (
    echo 无法找到 powershell 加载点...!
    pause
    exit /b 0
)

(
for /f "delims= skip=%lineNum%" %%a in ('type %0') do (
	echo.%%a
)
)>%powershellScriptFileName%

if not exist "%powershellScriptFileName%" (
    echo powershell 脚本加载失败!
    pause
    exit /b 0
)

echo 加载 powershell 脚本...
call :getExecutionPolicy
powershell set-executionpolicy -executionpolicy bypass 
powershell -file %powershellScriptFileName% %*
powershell set-ExecutionPolicy -executionpolicy %executionPolicy%
::del /q %powershellScriptFileName%
pause
exit /b 0

rem 获取UAC状态;return=Null|False|True
:getUac
set uacStatus=
set returnValue=
(echo u >%windir%\u.tmp)2>nul
if not exist %windir%\u.tmp (
	set uacStatus=False
) else (
	set uacStatus=True
	del /f %windir%\u.tmp 2>nul
)

if "#"=="#!uacStatus!" (
	set returnValue=Null
) else (
	set returnValue=%uacStatus%
)
goto :eof

:getPowershellLine
for /f "delims=" %%a in ('type %1 ^| findstr /n ":%powershellScriptFunc%"') do (
	if not "%%a"=="" (
		for /f "delims=: tokens=1*" %%x in ("%%a") do (
			set lineNum=%%x
		)
	) else (
		set lineNum=False
	)
)
goto :eof

:getExecutionPolicy
for /f "delims=" %%a in ('powershell get-ExecutionPolicy -scope LocalMachine') do (
	set executionPolicy="%%a"
)
goto :eof


:powershellScriptFunc
$pros = (Get-Process)
$prosMax = 20
write-host "$args"
for($n=1;$prosmax -gt $n;$n++)
{
    echo $n
}

