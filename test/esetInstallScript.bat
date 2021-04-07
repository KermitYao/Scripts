1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem 开启此参数，cmd指定参数和gui选择将会失效;
rem 相当于使用强制使用命令行参数；

rem 如果不需要保持为空即可

rem 使用方法 ： SET DEFAULT=-o --agent -l --del -, 与正常的cmd参数保持一致

SET DEFAULT=

rem 开启调试信息
set debug=True
rem 解析参数列表
set argsList=argsHelp argsAll argsHotfix argsProduct argsAgent argsStatus argsLog argsDel argsGui
::----------------------------------

rem ----------- init -----------
rem 设置初始变量
:getPackagePatch

rem 已安装的软件,小于此本版则进行安装
set version_Agent=8.0
set version_Product_eea=8.0
set version_Product_efsw=7.3
rem -------------------

rem Agent 下载地址
set path_agetn_x86=
set path_agetn_x64=

rem Agent 配置文件
set config_file=

rem 追加参数,不需要则保持为空
set params_agent=

rem -------------------

rem PC Product 下载地址
set path_eea_v6.5_x86=
set path_eea_v6.5_x64=

set path_eea_v8.0_x86=
set path_eea_v8.0_x64=


rem SERVER Product 下载地址
set path_efsw_v6.5_x86=
set path_efsw_v6.5_x64=

set path_efsw_v7.3_x86=
set path_efsw_v7.3_x64=

rem 追加参数,不需要则保持为空
set params_Product=
rem -------------------

rem 补丁文件 下载地址
set path_hotfix_kb4474419_x86=
set path_hotfix_kb4474419_x64=

set path_hotfix_kb4490628_x86=
set path_hotfix_kb4490628_x64=
rem -------------------

rem 临时文件和日志存放路径
set path_Temp=%temp%\ESET_TEMP_INSTALL\
set params_msiexec="msiexec /qn /i "

set params_hotfix="wusa /quiet /norestart"

set path_log="%temp%\esetInstall.log"
set srcArgs=%*

if "#%DEFAULT%"=="#" (
	set args=%srcArgs%
) else (
	set args=%DEFAULT%
)

rem ----------- init -----------

rem ----------- begin start -----------
:begin
echo %args%
if "#%args%"=="#" (
	call :getGuiHelp
) else (
	call :getArgs %args%
)

call :getSysVer
echo %returnValue%

call :debug
pause
exit /b 0

rem ----------- begin end -----------



:debug
echo --------------- debug ---------------
echo exitCode: 
echo ----------参数状态-----------
for %%a in (%argsList%) do (
	call :getVar tmpStatus %%a
	if not "#!tmpStatus!"=="#" echo %%a:!tmpStatus!
)
echo ----------参数状态-----------
echo.systemActivateOption=!systemActivateOption!
echo.officeActivateOption=!officeActivateOption!
echo.keyValue=!keyValue!
echo.pathValue=!pathValue!
echo.helpValue=!helpValue!
echo.kmsValue=!kmsValue!
echo.kmsReset=!kmsReset!
echo.activateEnd=!returnValue!
echo netStatus=!returnValue!
echo.kmsValue=!kmsValue!
echo.keyValue=!keyValue!
echo.uacStatus=!uacStatus!
echo sysVersion=!sysVersion!

echo --------------- debug ---------------
goto :eof




rem 获取系统版本; 传入参数:无需传入；例：call :getSysVer ; 返回值: returnValue = "Windows XP"|"Windows 7"|"Windows 10"|"Windows Server 2008"|"Windows Server 2012"|"Windows Server 2016"|"Windows Server 2019"
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

rem 获取系统平台; 传入参数:无需传入；例：call :getSysArch ; 返回值: returnValue = x86|x64
:getSysArch
set sysArch=x86
if exist C:\Windows\SysWOW64\ (
	set sysArch=x64
)

if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
	set sysArch=x64
)

set tmp=
if "#"=="#!sysArch!" (
	set returnValue=Null
) else (
	set returnValue=!sysArch!
)
goto :eof

:getCmdHelp
echo  Usage: %~nx0 [options]
echo\
echo  -h,	--help		[optional] Print this help message
echo  -a,	--all		[optional] Install 'Hotfix & Product & Agent'
echo  -o,	--hotfix		[optional] Install Hotfix
echo  -p,	--product		[optional] Install Product
echo  -g,	--agent		[optional] Install Agent
echo  -s,	--status		[optional] Check status
echo  -l,	--log		[optional] Enable log
echo  -d,	--del		[optional] Delete downloaded files
echo  -u,	--gui		[optional] Like GUI show
echo.
echo		Example:%~nx0 -o --agent -l --del
echo\
echo              Code by Windows, 2021-04-5 ,kermit.yao@outlook.com
goto :eof

rem 获取 gui 界面,返回;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.#################################
echo.#				#
echo.#	s.自动激活Windows系列	#
echo.#				#
echo.#	o.自动激活Office系列	#
echo.#				#
echo.#	r.重置kms信息		#
echo.#				#
echo.#	h.显示命令行参数	#
echo.#				#
echo.#	kermit.yao@outlook.com	#
echo.#				#
echo.#################################
echo.
echo.
set /p input=请选择:(s^|o^|h):

for %%a in (s o h r) do (
	if "#!input!"=="#%%a" (
		cls
		echo.
		call :getArgs -!input!
		set guiArgsStatus=True
	)
)

if "!helpValue!"=="True" (
	goto :eof
)


if "#!guiArgsStatus!"=="#True" (
	set returnValue=!guiArgsStatus!
) else (
	call :getErrorMsg "选择错误:[!input!]" ERROR
	goto getGuiHelp
)
goto :eof

rem 解析传入参数; 传入参数: %1 = 参数列表；例：call :getArgs args ; 返回值: 无返回值
:getArgs
for %%a in (%*) do (
	if /i "#%%a"=="#-h" set argsHelp=True
	if /i "#%%a"=="#--help" set argsHelp=True

	if /i "#%%a"=="#-a" set argsAll=True
	if /i "#%%a"=="#--all" set argsAll=True

	if /i "#%%a"=="#-o" set argsHotfix=True
	if /i "#%%a"=="#--hotfix" set argsHotfix=True

	if /i "#%%a"=="#-p" set argsProduct=True
	if /i "#%%a"=="#--product" set argsProduct=True

	if /i "#%%a"=="#-g" set argsAgent=True
	if /i "#%%a"=="#--agent" set argsAgent=True

	if /i "#%%a"=="#-s" set argsStatus=True
	if /i "#%%a"=="#--status" set argsStatus=True

	if /i "#%%a"=="#-l" set argsLog=True
	if /i "#%%a"=="#--log" set argsLog=True

	if /i "#%%a"=="#-d" set argsDel=True
	if /i "#%%a"=="#--del" set argsDel=True

	if /i "#%%a"=="#-u" set argsGui=True
	if /i "#%%a"=="#--gui" set argsGui=True
	)
)

goto :eof

::多重变量获取
:getVar
set %1=!%2!
goto :eof


rem 判断是否安装补丁; 传入参数: %1 = 补丁号；例：call :getHotfixStatus KB4474419 ; 返回值: returnValue=True | False | Null
:getHotfixStatus
set hotfixStatus=false
wmic qfe get hotfixid|find /i "%1" >nul&&set hotfixStatus=true

if "#"=="#!hotfixStatus!" (
	set returnValue=Null
) else (
	set returnValue=!hotfixStatus!
)
goto :eof

rem 对msi进行安装;传入 call :msiInstall  "params_msiexec" "installPath"
:msiInstall
start /wait  %~1 "%~2"
goto :eof

rem 对msi进行安装;传入 call :msiInstall  "params_msiexec" "installPath"
rem 对msi进行安装
:hotFixInstall
start /wait   %~1 "%~2" 
goto :eof

rem 连接共享主机; 传入参数: %1 = 主机， %2 = 用户名, %3 = 密码; 例：call :connectShare "\\127.0.0.1" "kermit" "5698" ; 返回值: returnValue=True | False
:connectShare
set tmpStatus=False
if "#%~1" == "#" (
	set returnValue=!tmpStatus!
	goto :eof
)
set cmd_user_param=/user:"%~2"
echo %cmd_user_param%
for /f "delims=" %%a in ('net use "%~1" %cmd_user_param% "%~3" 2^>nul ^&^& echo statusTrue') do (
	set tmp=%%a
	if "#!tmp:~,10!"=="#statusTrue" (
		set tmpStatus=True
	)
)
set returnValue=!tmpStatus!

goto :eof

rem 下载文件; 传入参数: %1 = 当前文件路径， %2 = url, %3 = 保存地址; 例：call :downFile "%~f0" "http://192.168.31.99/test.rar" "d:\test.rar"; 返回值: returnValue=True | False
:downFile
set downStatus=Flase

for  /f %%a in  ('cscript /nologo /e:jscript "%~f1" /downUrl:%2 /savePath:%3') do (
	if "#%%a"=="#True" set downStatus=True
)

if "#%downStatus%"=="#False" (
	if not "#%sysVer%"=="#xp" (
		for  /f "delims=" %%a in  ('powershell -Command "& {(New-Object Net.WebClient).DownloadFile('%~2', '%~3');($?)}" 2^>nul') do (
				if "#%%a"=="#True" set downStatus=True
		)
	)
)

set returnValue=%downStatus%
goto :eof

rem 获取UAC状态; 传入参数: 无参数传入 ; 例：call :getUac ; 返回值: returnValue=True | False | Null
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
	set returnValue=!uacStatus!
)

goto :eof

rem 写入日志; 传入参数: %1 = 标题， %2 = 消息类型, %3 = 消息文本， %4 = True 写入标准输出 | False，%5 = True 写入日志文件 | False; 例：call :writeLog witeLog ERROR "This is a error message." True False; 返回值:无返回值
:writeLog
if "%4"=="true" (
	echo ****************%1********************
	echo.*%date% %time% - %1 - %2 - %3
)

if "%5"=="true" (
	(
	echo ****************%1******************** 
	echo.*%date% %time% - %1 - %2 - %3
	)>>"%~f0.log"
)

goto :eof

rem 获取软件版本; 传入参数: %1 =Product | Agent ; 例：call :getVersion Product; 返回值:returnValue=版本号 | Null
:getVersion
set version=
if "#%~1"=="#Product" (
	set keyValue="HKEY_LOCAL_MACHINE\SOFTWARE\ESET\ESET Security\CurrentVersion\Info"
) else (
	set keyValue="HKEY_LOCAL_MACHINE\SOFTWARE\ESET\RemoteAdministrator\Agent\CurrentVersion\Info"
)
for /f "skip=2 tokens=3" %%a in ('reg query %keyValue% /v ProductVersion 2^>nul') do (
	set version=%%a
)

if "#"=="#%version%" (
	set returnValue=Null
) else (
	set returnValue=%version%
)
goto :eof

:exitCode
if "#%guiStatus%"=="#True" (
	echo 按任意键退出
	if "!debug!"=="True" call :debug
	pause>nul
	exit /b !exitCode!
) else (
	if "!debug!"=="True" call :debug
	exit /b !exitCode!
)
goto :eof



exit /b %errorlevel%

*/
var WShell  = new ActiveXObject('WScript.Shell');
try{
    var XMLHTTP = new ActiveXObject('WinHttp.WinHttpRequest.5.1');
    }
    catch(Err){
        var XMLHTTP = new ActiveXObject('Microsoft.XMLHTTP');
    }

var ADO     = new ActiveXObject('ADODB.Stream');
var Argv    = WScript.Arguments.Named;

download(Argv.Item('downUrl'), Argv.Item('savePath'));

function download(downUrl, savePath)
{

    XMLHTTP.Open('GET', downUrl, 0);
    try{
      XMLHTTP.setRequestHeader('Content-type','application/x-www-form-urlencoded');
    }
    catch(Err){}

    try{
        XMLHTTP.Send();
        ADO.Mode = 3;
        ADO.Type = 1;
        ADO.Open();
        ADO.Write(XMLHTTP.ResponseBody);
        ADO.SaveToFile(savePath, 2);
        ADO.Close();
	WScript.StdOut.Write('True');
    }
    catch(Err){
        WScript.StdOut.Write('False');
    }

}

