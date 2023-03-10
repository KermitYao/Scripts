1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto :begin
::* 此脚本可以自动安装360epp客户端,主要用于批量安装、域控等自动安装场景
::* 2022-10-30 脚本完成
::* 2022-11-28 1.新增 自动弹出其他安全软件卸载程序
::* 2022-12-25 1.修复 软件卸载功能现在可以支持msi格式的安装包了（国外软件常用）使用｛ESET Management Agent｝方式指定
::* v2.0.0_20230310_beta
	1.重构部分代码
	2.新增 现在可以通过命令行参数来使用脚本了
	3.新增 新增了支持功能,方便排查问题
	4.修复 某些情况下使用js下载失败,但是未能切换到powershell下载的问题。

:begin

cls
@set version=v2.0.1_20230310_beta
@echo off
title 360Inst tool.
setlocal enabledelayedexpansion

::-----------user var-----------

rem 设置360只能安装包下载地址
set sdUrl=http://360epp.yjyn.top:8081/online/Ent_360EPP1383860355[360epp.yjyn.top-8084]-W.exe

rem 开启此参数，命令行指定参数和gui选择将会失效;
rem 相当于强制使用命令行参数；
rem 如果不需要保持为空即可
rem 使用方法 ： SET DEFAULT=-o --agent -l --remove -, 与正常的cmd参数保持一致
SET DEFAULT_ARGS=

rem 日志等级 DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

::-----------user var-----------

rem 用于域控推送的时候静默运行 True|False
set quiet=False

rem 脚本会搜索其他软件,并弹出卸载窗口, 通过 avList 变量指定
set argsAvUninst=True

rem 脚本会自动安装360epp客户端
set args360Inst=True

rem 设置日志等级
set logLevel=DEBUG

rem 调试开关
set DEBUG=True

rem ----------- init -----------
set DEBUG=True
set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem 解析参数列表
set argsList=argsHelp argsProduct argsUndoProduct argsSysStatus argsLog argsRemove argsGui argsAvUninst argsVersion

rem 临时文件和日志存放路径
set path_Temp=%temp%\360inst

rem 记录初始命令行参数
set srcArgs=%*

if "#%DEFAULT_ARGS%"=="#" (
	set args=%srcArgs%

) else (
	set args=%DEFAULT_ARGS%
)

rem 下载文件阈值,小于多少判定为下载失败,  单位kb
set errorFileSize=4

if not exist %path_Temp% md %path_Temp%

if "#%args%"=="#" (
	call :getGuiHelp
	if "#%DEFAULT_ARGS%"=="#" (set args=!returnValue!) 
)
call :getArgs %args%
call :getSysInfo
goto :exitScript

rem 用于启动第三方杀毒软件卸载程序,本质是搜索注册表键值,如果存在相应的键值,则启动卸载程序
rem 以键的方式配置, "产品名称:注册表键值名称", 如果是msi类安装程序建议使用 {程序安装代码或名称},脚本会自动搜索 wimc product 进行匹配
set avList= "360安全卫士:360安全卫士" "360杀毒:360SD" "腾讯电脑管家:QQPCMgr" "火绒安全软件:HuorongSysdiag" "亚信安全:OfficeScanNT" "金山毒霸:Kingsoft Internet Security" "赛门铁克:{Symantec Endpoint Protection}"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem 下载文件阈值,小于多少判定为下载失败,  单位kb
set errorFileSize=4



if "%~1"=="/q" set quiet=True
for /f "delims=/ tokens=4" %%a in ("%sdUrl%") do (
	echo %%a|findstr "^Ent_360EPP[0-9]*\[.*\]-W.exe" >nul
	if !errorlevel! equ 0 set name_360=%%a
)
rem ----------- init -----------



echo 正在处理相关信息...
call :getSysInfo

rem 判断epp是否安装
for %%a in (%registryKey%) do (
	for /f "tokens=1-2*" %%e in ('reg query "%%~a\360EPPX" /v %registryValue% 2^>nul') do (
		if not "%%~g"=="" (
			set eppFlag=True
			set eppPath=%%~g
		)
	)
)
if "%eppFlag%"=="True" (
	echo 检测到已经安装EPP,无需再次安装.
	set exitCode=0
	goto :close
)
rem 卸载第三方安全软件
if "#%argsAvUninst%"=="#True" (
	echo 开始扫描第三方安全软件...
	call :avUninst
	if "!avUninstFlag!"=="" (
		echo 未扫描到其他安全软件.
	) else (
		echo 请手动点击卸载程序选项进行卸载...
		if not "%quiet%"=="True" (
		echo 按任意键进行下一步操作.
		pause >nul
			)
		)	
)

rem 下载360安装文件
if "#%args360Inst%"=="#True" (
	echo 开始下载360安装文件: [%sdUrl%]
	call :downFile "%~f0" "%sdUrl%" "%path_Temp%\%name_360%"
	if "#!returnValue!"=="#True" (
		if exist "%path_Temp%\%name_360%" (
			echo 启动360安装程序...
			if "%quiet%"=="True" (
				start /b "360Install" "%path_Temp%\%name_360%" /s
				set exitCode=0
			) else (
				start /b "360Install" "%path_Temp%\%name_360%"
				set exitCode=0
			)

		) else (
			echo 未知错误,无法启动360安装程序.
			set exitCode=99
		)
	) else (
		echo 360安装文件下载失败.
		set exitCode=1
	)
)


rem exitCode: 正常:0,标准命令行报错:1,系统版本错误:2,系统平台错误:3,无法获取补丁包:4,有补丁安装失败或挂起:5,安装Agent失败:6,卸载agent失败:7,卸载product失败:8,进入安装模式失败:9,退出安装模式失败:10,安装product失败:11,Win7系统不是sp1:12，权限不足错误:96,参数错误:97,无法解析参数:98,未知错误:99
:exitScript

rem 测试函数,开启debug模式此处代码将被执行
 if %DEBUG%==True (
	call :debug

	set exitCode=999
 )
if "#%argsGui%"=="#True" (
	call :writeLog INFO argsList "argsList:[!args!]" False True
	call :writeLog INFO exit "脚本已完成,按任意键结束" True True
	pause >nul
	exit /b %exitCode%
) else (
	exit /b %exitCode%
)

rem ----------- begin end -----------

:debug
echo --------------- debug ---------------
echo ----------参数状态-----------
for %%a in (%argsList%) do (
	call :getVar tmpStatus %%a
	echo %%a:!tmpStatus!
	rem if not "#!tmpStatus!"=="#" echo %%a:!tmpStatus!
)
echo ----------参数状态-----------

echo ----------变量状态-----------
set valueList=args sysType sysArch ntVer ntVerNumber errorlevel exitCode
for %%a in (!valueList!) do echo %%a:[!%%a!]
echo ----------变量状态-----------

echo ----------URL-----------
set valueList=sdUrl
for %%a in (!valueList!) do echo %%a:[!%%a!]

echo ----------URL-----------
echo.
echo --------------- debug ---------------
goto :eof

:getCmdHelp
echo  Usage: %~nx0 [options]
echo\
echo  -h,	--help		[optional] Print the help message
echo  -p,	--product	[optional] Install Product
echo  -d,	--undoProduct	[optional] Uninstall Product
echo  -s,	--status	[optional] Check status
echo  -l,	--log		[optional] Disable log
echo  -r,	--remove	[optional] Remove downloaded files
echo  -i,    --avUninst	[optional] Remove antivirus of other
echo  -u,	--gui		[optional] Like GUI show
echo  -v,	--version	[optional] Print current version of the script.
echo.
echo		Example:%~nx0 -o --agent -l --remove
echo\
echo              Code by Kermit Yao @ Windows 10, 2021-04-5 ,kermit.yao@outlook.com
goto :eof

rem 获取 gui 界面,返回;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.*************************************************
echo.*						*
echo.*	p.安装安全产品				*
echo.*	d.卸载 安全产品				*
echo.*	s.检查状态				*
echo.*	i.卸载其他软件				*
echo.*	v.打印当前脚本版本			*
echo.*	h.显示命令行帮助			*
echo.*	kermit.yao@outlook.com			*
echo.*						*
echo.*************************************************
echo.
echo.
set /p input=请选择:(p^|d^|s^|^i^|v^|h):
for %%a in (p d s i v h) do (
	if /i "#!input!"=="#%%a" (
		cls
		echo.
		set guiArgsStatus=-%%a -u
	)
)

if "!helpValue!"=="True" (
	goto :eof
)

if not "#!guiArgsStatus!"=="#" (
	set returnValue=!guiArgsStatus!
) else (
	cls
	call :writeLog ERROR getGuiHelp "选择错误:[!input!]" True True
	goto getGuiHelp
)
goto :eof

rem 解析传入参数; 传入参数: %1 = 参数列表；例：call :getArgs args ; 返回值: 无返回值
:getArgs

for %%a in (%*) do (
	if /i "#%%a"=="#-h" set argsHelp=True
	if /i "#%%a"=="#--help" set argsHelp=True

	if /i "#%%a"=="#/h" set argsHelp=True

	if /i "#%%a"=="#-p" set argsProduct=True
	if /i "#%%a"=="#--product" set argsProduct=True

	if /i "#%%a"=="#-d" set argsUndoProduct=True
	if /i "#%%a"=="#--undoProduct" set argsUndoProduct=True

	if /i "#%%a"=="#-s" set argsSysStatus=True
	if /i "#%%a"=="#--status" set argsSysStatus=True

	if /i "#%%a"=="#-l" set argsLog=True
	if /i "#%%a"=="#--log" set argsLog=True

	if /i "#%%a"=="#-r" set argsRemove=True
	if /i "#%%a"=="#--remove" set argsRemove=True

	if /i "#%%a"=="#-u" set argsGui=True
	if /i "#%%a"=="#--gui" set argsGui=True

	if /i "#%%a"=="#-i" set argsAvUninst=True
	if /i "#%%a"=="#--avUninst" set argsAvUninst=True

	if /i "#%%a"=="#-v" set argsVersion=True
	if /i "#%%a"=="#--version" set argsVersion=True
	)
)
for %%a in (%argsList%) do (
	if "#!%%a!"=="#True" set argsStatus=True
	rem echo %%a: !%%a!
)
goto :eof

::多重变量获取
:getVar
set %1=!%2!
goto :eof

rem 写入日志; 传入参数: %1 = 消息类型， %2 = 标题, %3 = 消息文本， %4 = True 写入标准输出 | False，%5 = True 写入日志文件 | False; 例：call :writeLog witeLog ERROR "This is a error message." True False; 返回值:无返回值
:writeLog

if "%logLevel%"=="DEBUG" (set logLevelList=DEBUG INFO WARNING ERROR)
if "%logLevel%"=="INFO" (set logLevelList=INFO WARNING ERROR)
if "%logLevel%"=="WARNING" (set logLevelList=WARNING ERROR)
if "%logLevel%"=="ERROR" (set logLevelList=ERROR)

for %%a in (%logLevelList%) do (
	if "%%a"=="%~1" (
		if "%4"=="True" (
			echo.*%date% %time% - %1 - %2 - %3
		)
		
		if "%5"=="True" (
			(
			echo.*%date% %time% - %1 - %2 - %3
			)>>"%path_Temp%\%~nx0.log"
		)
	)
)

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

rem 卸载第三方杀毒软件
:avUninst
for %%a in (%avList%) do (
	for /f "delims=: tokens=1*" %%b in (%%a) do (
		set proFlag=exe
		echo %%~c|findstr "^{.*}$" >nul && set proType=msi
		if not "!proType!" == "msi" (
			for %%d in (%registryKey%) do (
				for /f "tokens=1-2*" %%e in ('reg query "%%~d\%%~c" /v %registryValue% 2^>nul') do (
					if not "%%~g"=="" (
						if exist "%%~g" (
							set avUninstFlag=True
							echo 启动【%%b】卸载程序: %%~g
							start /b "avUninst" "%%~g"
						)
					)
				)
			)
		) else (
			set isPresent=False
			set avName=%%~c
			set avName=!avName:{=!
			set avName=!avName:}=!
			for /f "delims={} tokens=2*" %%x in ('wmic product get ^| findstr /c:"!avName!"') do set avCode=%%x&set isPresent=True
			if "!isPresent!" == "True" (
				set avUninstFlag=True
				echo 启动【%%b】卸载程序: msiexec /x {!avCode!}
				if "%quiet%" == "True" (
					start /b "avUninst" msiexec /qn /norestart /x {!avCode!}
				) else (
					start /b "avUninst" msiexec /qb /norestart /x {!avCode!}
				)
			)
		)
	)
)
goto :eof


rem 下载文件; 传入参数: %1 = 当前文件路径， %2 = url, %3 = 保存地址; 例：call :downFile "%~f0" "http://192.168.31.99/test.rar" "d:\test.rar"; 返回值: returnValue=True | False
:downFile
set downStatus=False
for  /f %%a in  ('cscript /nologo /e:jscript "%~f1" /downUrl:%2 /savePath:%3') do (
	call :writeLog INFO fileDownload "The file [%~2] was download by jscript" False True
	if "#%%a"=="#True" (
		call :checkFileSize "%~3"
		if "#!returnValue!"=="#True" (
			set downStatus=True
		)
	)
)

if "#!downStatus!"=="#False" (
	if not "#%sysVersion%"=="#WindowsXp" (
		call :writeLog INFO fileDownload "The file [%~2] was download by powershell" False True 
		for  /f "delims=" %%a in  ('powershell -Command "& {(New-Object Net.WebClient).DownloadFile('%~2', '%~3');($?)}" 2^>nul') do (
			if "#%%a"=="#True" (
				call :checkFileSize "%~3"
				if "#!returnValue!"=="#True" (
					set downStatus=True
				)
			)
		)
	)
)

set returnValue=!downStatus!
goto :eof

rem 检查下载文件是否正确,通过检测文件大小判断; 传入参数: 文件路径 ; 例: call :checkFileSize "%temp%\esetInst\eea.msi" ; 返回值: returnValue=True | False
:checkFileSize
set downStatus=False

if exist "%~1" (
	set /a currentFileSize=%~z1/1024
	if !currentFileSize! lss %errorFileSize% (
		set downStatus=False
		move /y "%~1" "%~1.error" >Nul
	) else (
		set downStatus=True
	)
)
set returnValue=%downStatus%
goto :eof


rem 获取系统版本; 传入参数:无需传入；例：call :getSysVer ; 返回值: returnValue = "Windows XP"|"Windows 7"|"Windows 10"|"Windows Server 2008"|"Windows Server 2012"|"Windows Server 2016"|"Windows Server 2019"
:getSysVer
set sysVer="Windows XP" "Windows 7" "Windows 10" "Windows Server 2008" "Windows Server 2012" "Windows Server 2016" "Windows Server 2019"
set returnValue=
set sysVersion=
set  sysType=PC
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') do (
	for %%x in (%sysVer%) do (
		set tm=%%~x
		echo %%b|findstr /i /c:%%x >nul&&set  sysVersion=!tm: =!
		echo %%b|findstr /i /c:"Server" >nul&&set sysType=Server
	)
)

for /f "delims=[] tokens=2*" %%a in ('ver') do (
	for /f "tokens=2" %%m in ("%%a") do (
		set ntVer=%%m
		for /f "tokens=1,2* delims=." %%x in ("!ntVer!") do (
			set ntVerNumber=%%x%%y
		)
	)
)

for /f "delims== tokens=2" %%a in ('wmic computersystem get name /value') do set "computerName=%%a"

for /f "delims={}, " %%a in ('wmic nicconfig get ipaddress ') do  echo %%a|findstr [0-9] >nul&&set "ipList=!ipList! %%a"
set ipList=!ipList:"=!

set tm=
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

set tm=
if "#"=="#!sysArch!" (
	set returnValue=Null
) else (
	set returnValue=!sysArch!
)
goto :eof

rem 当满足一定条件时,调用获取系统信息函数以提高运行效率.
:getSysInfo
set tmpArgsList_getSysVer=argsAll  argsHotfix argsProduct argsAgent argsEntrySafeMode argsExitSafeMode argsSysStatus argsEsetLog DEBUG
for %%a in (%tmpArgsList_getSysVer%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		call :getSysVer
	)
)

set tmpArgsList_getSysArch=argsAll argsHotfix argsProduct argsAgent argsSysStatus DEBUG
for %%a in (%tmpArgsList_getSysArch%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		call :getSysArch
	)
)

set tmpArgsList_getDownUrl=argsAll argsHotfix argsProduct argsAgent DEBUG
for %%a in (%tmpArgsList_getDownUrl%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
	)
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