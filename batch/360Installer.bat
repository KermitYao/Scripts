1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off
title 360Install tool.
setlocal enabledelayedexpansion
set sdUrl=http://192.168.16.196:8081/online/Ent_360EPP1383860355[192.168.16.196-8084]-W.exe

rem ��ʱ�ļ�����־���·��
set path_Temp=%temp%\360install
set name_360=Ent_360EPP1383860355[192.168.16.196-8084]-W.exe
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

rem ж�ص�������ȫ���
if "#%argsAvUninst%"=="#True" (
	echo ��ʼɨ���������ȫ���...
	call :avUninst
	if "!avUninstFlag!"=="" (
		echo δɨ�赽������ȫ���.
	) else (
		echo ���ֶ����ж�س���ѡ�����ж��...
		echo �������������һ������.
		pause >nul
		)	
)

rem ����360��װ�ļ�
if "#%args360Inst%"=="#True" (
	echo ��ʼ����360��װ�ļ�: [%sdUrl%]
	call :downFile "%~f0" "%sdUrl%" "%path_Temp%\%name_360%"
	if "#!returnValue!"=="#True" (
		if exist "%path_Temp%\%name_360%" (
			echo ����360��װ����...
			start /b "360Install" "%path_Temp%\%name_360%"
			exit /b 0
		) else (
			echo δ֪����,�޷�����360��װ����.
			exit /b 99
		)
	) else (
		echo 360��װ�ļ�����ʧ��.
		exit /b 1
	)
)

exit /b 0

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
	echo The file [%~2] was download by "jscript"
)

if "#!downStatus!"=="#False" (
	if not "#%sysVersion%"=="#WindowsXp" (
		for  /f "delims=" %%a in  ('powershell -Command "& {(New-Object Net.WebClient).DownloadFile('%~2', '%~3');($?)}" 2^>nul') do (
				if "#%%a"=="#True" set downStatus=True
				echo The file [%~2] was download by "powershell"
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