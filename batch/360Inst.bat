1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
title 360Inst tool.
setlocal enabledelayedexpansion
set sdUrl=http://360epp.yjyn.top:8081/online/Ent_360EPP1383860355[360epp.yjyn.top-8084]-W.exe

rem 临时文件和日志存放路径
set path_Temp=%temp%\360install

rem 用于域控推送的时候静默运行 True|False
set quiet=False

if "%~1"=="/q" set quiet=True
for /f "delims=/ tokens=4" %%a in ("%sdUrl%") do (
	echo %%a|findstr "^Ent_360EPP[0-9]*\[.*\]-W.exe" >nul
	if !errorlevel! equ 0 set name_360=%%a
)
if not exist %path_Temp% md %path_Temp%

rem 用于启动第三方杀毒软件卸载程序,本质是搜索注册表键值,如果存在相应的键值,则启动卸载程序
rem 以键的方式配置, "产品名称:注册表键值名称"
set avList= "360安全卫士:360安全卫士" "360杀毒:360SD" "腾讯电脑管家:QQPCMgr" "火绒安全软件:HuorongSysdiag" "亚信安全:OfficeScanNT" "金山毒霸:Kingsoft Internet Security"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem 下载文件阈值,小于多少判定为下载失败,  单位kb
set errorFileSize=4
set argsAvUninst=True
set args360Inst=True
echo 正在处理相关信息...

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

:close
if not "%quiet%"=="True" (
		echo 脚本已完成,按任意键退出.
		pause >nul
)
exit /b %exitCode%

rem 卸载第三方杀毒软件
:avUninst
for %%a in (%avList%) do (
	for /f "delims=: tokens=1*" %%b in (%%a) do (
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
	)
)
goto :eof

rem 下载文件; 传入参数: %1 = 当前文件路径， %2 = url, %3 = 保存地址; 例：call :downFile "%~f0" "http://192.168.31.99/test.rar" "d:\test.rar"; 返回值: returnValue=True | False
:downFile
set downStatus=False
for  /f %%a in  ('cscript /nologo /e:jscript "%~f1" /downUrl:%2 /savePath:%3') do (
	if "#%%a"=="#True" set downStatus=False
)

if "#!downStatus!"=="#False" (
	if not "#%sysVersion%"=="#WindowsXp" (
		for  /f "delims=" %%a in  ('powershell -Command "& {(New-Object Net.WebClient).DownloadFile('%~2', '%~3');($?)}" 2^>nul') do (
				if "#%%a"=="#True" set downStatus=True
		)
	)
)

if exist "%~3" (
	set /a currentFileSize=%~z3/1024
	if !currentFileSize! lss %errorFileSize% (
		set downStatus=False
		move "%~3" "%~3.error"
	)

)

set returnValue=!downStatus!
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