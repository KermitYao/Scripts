@echo off
setlocal enabledelayedexpansion

call :getSysVer
echo %returnValue%
pause
exit


rem 设置初始变量
:getPackagePatch
set path_agetn_x86=
set path_agetn_amd64=

set path_eea_v6.5_x86=
set path_eea_v6.5_amd64=

set path_eea_v8.0_x86=
set path_eea_v8.0_amd64=

set path_efsw_v6.5_x86=
set path_efsw_v6.5_amd64=

set path_efsw_v7.3_x86=
set path_efsw_v7.3_amd64=

set path_hotfix_kb4474419_x86=
set path_hotfix_kb4474419_amd64=

set path_hotfix_kb4490628_x86=
set path_hotfix_kb4490628_amd64=

set config_file=

set params_msiexec="/qn /i "

set params_hotfix="/quiet /norestart"

set path_log="%temp%\esetInstall.log"

goto :eof

rem  获取系统版本;return = Null|SysVersion
:getSysVer
set sysVer="Windows XP" "Windows 7" "Windows 10" "Windows Server 2008" "Windows Server 2012" "Windows Server 2016" "Windows Server 2019"
set returnValue=
set sysVersion=
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') do (
	for %%x in (%sysVer%) do (
		set tmp=%%x
		echo %%b|find /i %%x>nul&&set  sysVersion=!tmp: =!
	)
)

set tmp=
if "#"=="#!sysVersion!" (
	set returnValue=Null
) else (
	set returnValue=!sysVersion!
)
goto :eof

rem  获取系统平台;return = x86|AMD64
:getSysArch
set sysArch=x86
if exist C:\Windows\SysWOW64\ (
	set sysArch=AMD64
)

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	set sysArch=AMD64
)

set tmp=
if "#"=="#!sysArch!" (
	set returnValue=Null
) else (
	set returnValue=!sysArch!
)
goto :eof

rem rem  判断是否安装补丁;传入 call :getHotfixStatus   KB4474419; return = false|true
:getHotfixStatus
set hotfixStatus=false
wmic qfe get hotfixid|find /i "%1" >nul&&set hotfixStatus=true

if "#"=="#!hotfixStatus!" (
	set returnValue=Null
) else (
	set returnValue=!hotfixStatus!
)
goto :eof

rem 对msi进行安装;传入 call :msiInstall "installPath" "params_msiexec"
:msiInstall
start /wait msiexec "%~1" "%~2"
goto :eof

rem 对msi进行安装;传入 call :msiInstall "installPath" "params_msiexec"
rem 对msi进行安装
:hotFixInstall
start /wait wusa  "%~1" "%~1" 
goto :eof

rem 写入日志 %1 标题，%2 消息类型, %3 消息文本, %4 写入标准输出,%5 写入日志文件
:writeLog
if "%4"=="true" (
	echo ****************%1********************
	echo.*%date% %time% - %1 - %2 - %3
)

if "%5"=="true" (
	(
	echo ****************%1******************** 
	echo.*%date% %time% - %1 - %2 - %3
	)>>%path_log%
)

goto :eof