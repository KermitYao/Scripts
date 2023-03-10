1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto :begin
::* �˽ű������Զ���װ360epp�ͻ���,��Ҫ����������װ����ص��Զ���װ����
::* 2022-10-30 �ű����
::* 2022-11-28 1.���� �Զ�����������ȫ���ж�س���
::* 2022-12-25 1.�޸� ���ж�ع������ڿ���֧��msi��ʽ�İ�װ���ˣ�����������ã�ʹ�ã�ESET Management Agent����ʽָ��
::* v2.0.0_20230310_beta
	1.�ع����ִ���
	2.���� ���ڿ���ͨ�������в�����ʹ�ýű���
	3.���� ������֧�ֹ���,�����Ų�����
	4.�޸� ĳЩ�����ʹ��js����ʧ��,����δ���л���powershell���ص����⡣

:begin

cls
@set version=v2.0.1_20230310_beta
@echo off
title 360Inst tool.
setlocal enabledelayedexpansion

::-----------user var-----------

rem ����360ֻ�ܰ�װ�����ص�ַ
set sdUrl=http://360epp.yjyn.top:8081/online/Ent_360EPP1383860355[360epp.yjyn.top-8084]-W.exe

rem �����˲�����������ָ��������guiѡ�񽫻�ʧЧ;
rem �൱��ǿ��ʹ�������в�����
rem �������Ҫ����Ϊ�ռ���
rem ʹ�÷��� �� SET DEFAULT=-o --agent -l --remove -, ��������cmd��������һ��
SET DEFAULT_ARGS=

rem ��־�ȼ� DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

::-----------user var-----------

rem ����������͵�ʱ��Ĭ���� True|False
set quiet=False

rem �ű��������������,������ж�ش���, ͨ�� avList ����ָ��
set argsAvUninst=True

rem �ű����Զ���װ360epp�ͻ���
set args360Inst=True

rem ������־�ȼ�
set logLevel=DEBUG

rem ���Կ���
set DEBUG=True

rem ----------- init -----------
set DEBUG=True
set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem ���������б�
set argsList=argsHelp argsProduct argsUndoProduct argsSysStatus argsLog argsRemove argsGui argsAvUninst argsVersion

rem ��ʱ�ļ�����־���·��
set path_Temp=%temp%\360inst

rem ��¼��ʼ�����в���
set srcArgs=%*

if "#%DEFAULT_ARGS%"=="#" (
	set args=%srcArgs%

) else (
	set args=%DEFAULT_ARGS%
)

rem �����ļ���ֵ,С�ڶ����ж�Ϊ����ʧ��,  ��λkb
set errorFileSize=4

if not exist %path_Temp% md %path_Temp%

if "#%args%"=="#" (
	call :getGuiHelp
	if "#%DEFAULT_ARGS%"=="#" (set args=!returnValue!) 
)
call :getArgs %args%
call :getSysInfo
goto :exitScript

rem ��������������ɱ�����ж�س���,����������ע����ֵ,���������Ӧ�ļ�ֵ,������ж�س���
rem �Լ��ķ�ʽ����, "��Ʒ����:ע����ֵ����", �����msi�లװ������ʹ�� {����װ���������},�ű����Զ����� wimc product ����ƥ��
set avList= "360��ȫ��ʿ:360��ȫ��ʿ" "360ɱ��:360SD" "��Ѷ���Թܼ�:QQPCMgr" "���ް�ȫ���:HuorongSysdiag" "���Ű�ȫ:OfficeScanNT" "��ɽ����:Kingsoft Internet Security" "��������:{Symantec Endpoint Protection}"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem �����ļ���ֵ,С�ڶ����ж�Ϊ����ʧ��,  ��λkb
set errorFileSize=4



if "%~1"=="/q" set quiet=True
for /f "delims=/ tokens=4" %%a in ("%sdUrl%") do (
	echo %%a|findstr "^Ent_360EPP[0-9]*\[.*\]-W.exe" >nul
	if !errorlevel! equ 0 set name_360=%%a
)
rem ----------- init -----------



echo ���ڴ��������Ϣ...
call :getSysInfo

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


rem exitCode: ����:0,��׼�����б���:1,ϵͳ�汾����:2,ϵͳƽ̨����:3,�޷���ȡ������:4,�в�����װʧ�ܻ����:5,��װAgentʧ��:6,ж��agentʧ��:7,ж��productʧ��:8,���밲װģʽʧ��:9,�˳���װģʽʧ��:10,��װproductʧ��:11,Win7ϵͳ����sp1:12��Ȩ�޲������:96,��������:97,�޷���������:98,δ֪����:99
:exitScript

rem ���Ժ���,����debugģʽ�˴����뽫��ִ��
 if %DEBUG%==True (
	call :debug

	set exitCode=999
 )
if "#%argsGui%"=="#True" (
	call :writeLog INFO argsList "argsList:[!args!]" False True
	call :writeLog INFO exit "�ű������,�����������" True True
	pause >nul
	exit /b %exitCode%
) else (
	exit /b %exitCode%
)

rem ----------- begin end -----------

:debug
echo --------------- debug ---------------
echo ----------����״̬-----------
for %%a in (%argsList%) do (
	call :getVar tmpStatus %%a
	echo %%a:!tmpStatus!
	rem if not "#!tmpStatus!"=="#" echo %%a:!tmpStatus!
)
echo ----------����״̬-----------

echo ----------����״̬-----------
set valueList=args sysType sysArch ntVer ntVerNumber errorlevel exitCode
for %%a in (!valueList!) do echo %%a:[!%%a!]
echo ----------����״̬-----------

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

rem ��ȡ gui ����,����;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.*************************************************
echo.*						*
echo.*	p.��װ��ȫ��Ʒ				*
echo.*	d.ж�� ��ȫ��Ʒ				*
echo.*	s.���״̬				*
echo.*	i.ж���������				*
echo.*	v.��ӡ��ǰ�ű��汾			*
echo.*	h.��ʾ�����а���			*
echo.*	kermit.yao@outlook.com			*
echo.*						*
echo.*************************************************
echo.
echo.
set /p input=��ѡ��:(p^|d^|s^|^i^|v^|h):
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
	call :writeLog ERROR getGuiHelp "ѡ�����:[!input!]" True True
	goto getGuiHelp
)
goto :eof

rem �����������; �������: %1 = �����б�����call :getArgs args ; ����ֵ: �޷���ֵ
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

::���ر�����ȡ
:getVar
set %1=!%2!
goto :eof

rem д����־; �������: %1 = ��Ϣ���ͣ� %2 = ����, %3 = ��Ϣ�ı��� %4 = True д���׼��� | False��%5 = True д����־�ļ� | False; ����call :writeLog witeLog ERROR "This is a error message." True False; ����ֵ:�޷���ֵ
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

rem ��ȡUAC״̬; �������: �޲������� ; ����call :getUac ; ����ֵ: returnValue=True | False | Null
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

rem ж�ص�����ɱ�����
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
							echo ������%%b��ж�س���: %%~g
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
				echo ������%%b��ж�س���: msiexec /x {!avCode!}
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


rem �����ļ�; �������: %1 = ��ǰ�ļ�·���� %2 = url, %3 = �����ַ; ����call :downFile "%~f0" "http://192.168.31.99/test.rar" "d:\test.rar"; ����ֵ: returnValue=True | False
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

rem ��������ļ��Ƿ���ȷ,ͨ������ļ���С�ж�; �������: �ļ�·�� ; ��: call :checkFileSize "%temp%\esetInst\eea.msi" ; ����ֵ: returnValue=True | False
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


rem ��ȡϵͳ�汾; �������:���贫�룻����call :getSysVer ; ����ֵ: returnValue = "Windows XP"|"Windows 7"|"Windows 10"|"Windows Server 2008"|"Windows Server 2012"|"Windows Server 2016"|"Windows Server 2019"
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

rem ��ȡϵͳƽ̨; �������:���贫�룻����call :getSysArch ; ����ֵ: returnValue = x86|x64
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

rem ������һ������ʱ,���û�ȡϵͳ��Ϣ�������������Ч��.
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