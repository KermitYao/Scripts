1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
title 360Inst tool.
setlocal enabledelayedexpansion
set sdUrl=http://360epp.yjyn.top:8081/online/Ent_360EPP1383860355[360epp.yjyn.top-8084]-W.exe

rem ��ʱ�ļ�����־���·��
set path_Temp=%temp%\360install

rem ����������͵�ʱ��Ĭ���� True|False
set quiet=False

if "%~1"=="/q" set quiet=True
for /f "delims=/ tokens=4" %%a in ("%sdUrl%") do (
	echo %%a|findstr "^Ent_360EPP[0-9]*\[.*\]-W.exe" >nul
	if !errorlevel! equ 0 set name_360=%%a
)
if not exist %path_Temp% md %path_Temp%

rem ��������������ɱ�����ж�س���,����������ע����ֵ,���������Ӧ�ļ�ֵ,������ж�س���
rem �Լ��ķ�ʽ����, "��Ʒ����:ע����ֵ����"
set avList= "360��ȫ��ʿ:360��ȫ��ʿ" "360ɱ��:360SD" "��Ѷ���Թܼ�:QQPCMgr" "���ް�ȫ���:HuorongSysdiag" "���Ű�ȫ:OfficeScanNT" "��ɽ����:Kingsoft Internet Security"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem �����ļ���ֵ,С�ڶ����ж�Ϊ����ʧ��,  ��λkb
set errorFileSize=4
set argsAvUninst=True
set args360Inst=True
echo ���ڴ��������Ϣ...

rem �ж�epp�Ƿ�װ
for %%a in (%registryKey%) do (
	for /f "tokens=1-2*" %%e in ('reg query "%%~a\360EPPX" /v %registryValue% 2^>nul') do (
		if not "%%~g"=="" (
			set eppFlag=True
			set eppPath=%%~g
		)
	)
)
if "%eppFlag%"=="True" (
	echo ��⵽�Ѿ���װEPP,�����ٴΰ�װ.
	set exitCode=0
	goto :close
)
rem ж�ص�������ȫ���
if "#%argsAvUninst%"=="#True" (
	echo ��ʼɨ���������ȫ���...
	call :avUninst
	if "!avUninstFlag!"=="" (
		echo δɨ�赽������ȫ���.
	) else (
		echo ���ֶ����ж�س���ѡ�����ж��...
		if not "%quiet%"=="True" (
		echo �������������һ������.
		pause >nul
			)
		)	
)

rem ����360��װ�ļ�
if "#%args360Inst%"=="#True" (
	echo ��ʼ����360��װ�ļ�: [%sdUrl%]
	call :downFile "%~f0" "%sdUrl%" "%path_Temp%\%name_360%"
	if "#!returnValue!"=="#True" (
		if exist "%path_Temp%\%name_360%" (
			echo ����360��װ����...
			if "%quiet%"=="True" (
				start /b "360Install" "%path_Temp%\%name_360%" /s
				set exitCode=0
			) else (
				start /b "360Install" "%path_Temp%\%name_360%"
				set exitCode=0
			)

		) else (
			echo δ֪����,�޷�����360��װ����.
			set exitCode=99
		)
	) else (
		echo 360��װ�ļ�����ʧ��.
		set exitCode=1
	)
)

:close
if not "%quiet%"=="True" (
		echo �ű������,��������˳�.
		pause >nul
)
exit /b %exitCode%

rem ж�ص�����ɱ�����
:avUninst
for %%a in (%avList%) do (
	for /f "delims=: tokens=1*" %%b in (%%a) do (
		for %%d in (%registryKey%) do (
			for /f "tokens=1-2*" %%e in ('reg query "%%~d\%%~c" /v %registryValue% 2^>nul') do (
				if not "%%~g"=="" (
					if exist "%%~g" (
						set avUninstFlag=True
						echo ������%%b��ж�س���: %%~g
						start /b "avUninst" "%%~g"
					)
				)
			)
		)
	)
)
goto :eof

rem �����ļ�; �������: %1 = ��ǰ�ļ�·���� %2 = url, %3 = �����ַ; ����call :downFile "%~f0" "http://192.168.31.99/test.rar" "d:\test.rar"; ����ֵ: returnValue=True | False
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