1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Net session >nul 2>&1 || (echo Start-Process  -FilePath %~fs0   -verb  runas | powershell - &exit)

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

::* v2.1.1_20230515_beta
	1.���� ���ڿ��Ը��ݲ�ͨ�Ŀͻ���ip��ַ�Զ�ѡ��ͬ������������,���ڶ���������صĳ���
	2.�޸� ж������ʾδ��װʵ���Ѱ�װ������
:begin

cls
@set version=v2.1.1_20230515_beta
@echo off
title 360Inst tool.
setlocal enabledelayedexpansion

::-----------user var-----------

rem ����360���ܰ�װ�����ص�ַ,��ð�ŷָ��ֶ�, ��һ���ֶ�Ϊƥ���ip����,���ip�ÿո�ָ�,�ڶ����ֶ�Ϊ��������;������۱���ip��ʲô��������������һ���ֶ�д "." һ���㼴��,���ʾƥ����������
rem �� 192.168.1.��192.168.2. ��ͷ��ip,ʹ��sdUrl_1 ������������: sdUrl_1=192.168.1. 192.168.2.:http://yjyn.top:8081/online/Ent_360EPP1383860355[360epp.yjyn.top-8084]-W.exe
rem ������д���������,ƥ����Ӿ�׼.������д20��, sdUrl_1 - sdUrl_20
set sdUrl_1=10.152. 10.153. 10.154. 172.22. 172.23. 172.24.:http://10.152.9.185:8081/online/Ent_360EPP689218535[10.152.9.185-8080]-W.exe
set sdUrl_2=10.155. 10.156. 10.157. 172.25. 172.26. 172.27.:http://10.152.9.220:8081/online/Ent_360EPP689218535[10.152.9.220-8080]-W.exe
set sdUrl_3=10.158. 10.159. 172.28. 172.29.:http://10.152.10.97:8081/online/Ent_360EPP689218535[10.152.10.97-8080]-W.exe

rem �����˲�����������ָ��������guiѡ�񽫻�ʧЧ;
rem �൱��ǿ��ʹ�������в�����
rem �������Ҫ����Ϊ�ռ���
rem ʹ�÷��� �� SET DEFAULT=-o --agent -l --remove -, ��������cmd��������һ��
SET DEFAULT_ARGS=-i -p -s -u
::-----------user var-----------

rem ----------- init -----------
rem ��־�ȼ� DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

rem ���Կ���
set DEBUG=False
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
set initProductName=360�ն˰�ȫ����ϵͳ
rem �����ļ���ֵ,С�ڶ����ж�Ϊ����ʧ��,  ��λkb
set errorFileSize=4

if not exist %path_Temp% md %path_Temp%

if "#%args%"=="#" (
	call :getGuiHelp
	if "#%DEFAULT_ARGS%"=="#" (set args=!returnValue!) 
)
call :getArgs %args%

rem ��������������ɱ�����ж�س���,����������ע����ֵ,���������Ӧ�ļ�ֵ,������ж�س���
rem �Լ��ķ�ʽ����, "��Ʒ����:ע����ֵ����", �����msi�లװ������ʹ�� {����װ���������},�ű����Զ����� wimc product ����ƥ��
set avList= "360��ȫ��ʿ:360��ȫ��ʿ" "360ɱ��:360SD" "��Ѷ���Թܼ�:QQPCMgr" "���ް�ȫ���:HuorongSysdiag" "���Ű�ȫ:OfficeScanNT" "��ɽ����:Kingsoft Internet Security" "��������:{Symantec Endpoint Protection}" "ESET����:{ESET Management Agent}" "ESET ɱ��:{ESET Endpoint Antivirus}"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem �����ļ���ֵ,С�ڶ����ж�Ϊ����ʧ��,  ��λkb
set errorFileSize=4

rem ----------- init -----------

rem �ر���־��ӡ
if "#%argsLog%"=="#True" (
	set logLevel=False
)

rem ��ӡ�����а���
if "#%argsHelp%"=="#True" (
	call :getCmdHelp
	set exitCode=0
	goto :exitScript
)

echo ���ڴ��������Ϣ...
call :getSysInfo
call :getUac

rem ��ӡ��ǰ�汾
if "#%argsVersion%"=="#True" (
	call :writeLog DEBUG printVersion "Current version: %version%" False True
	echo Current version: %version%
	set exitCode=0
)

rem û��ƥ��Ĳ����򱨴�
if not "#%argsStatus%"=="#True" (
	call :writeLog ERROR witeLog "������������δ�ҵ����ʵ�ѡ��" True True
	set exitCode=98
	goto :exitScript
)

rem ж�ص�������ȫ���
if "#%argsAvUninst%"=="#True" (
	call :writeLog INFO avUninstl "��ʼ���������ɱ�����ж��..." True True
	if "#!uacStatus!"=="#True" (
		call :writeLog INFO avUninst "��ʼɨ���������ȫ���..." True True
		call :avUninst
		if "!avUninstFlag!"=="" (
			call :writeLog INFO avUninst "δɨ�赽������ȫ���." True True
		) else (
			call :writeLog INFO avUninst "����е���ж�ش���,�����ֶ����ж�س���ѡ�����ж��..." True True
			if "#%argsGui%"=="#True" (
				call :writeLog INFO avUninst "�������������һ������." True True
				pause >nul
			) 
		)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)

rem ж�� Product
if "#%argsUndoProduct%"=="#True" (
	call :writeLog INFO uninstallProduct "��ʼ����ȫ��Ʒж��" True True
	if "#!uacStatus!"=="#True" (
		if "#!productName!"=="#" (
			call :writeLog WARNING uninstallProduct "��%initProductName%�� δ��װ,����ж��" True True
		) else (
			call :writeLog INFO uninstallProduct "��ʼж�� [!productName!]" True True

			set tempAvList=%avList%
			set avList="%initProductName%:360EPPX"
			call :avUninst
			set avList=%tempAvList%
			call :writeLog INFO uninstallProduct "����е���ж�ش���,�����ֶ����ж�س���ѡ�����ж��..." True True
		)
		if "#!returnValue!"=="#False" (set exitCode=8) else (set exitCode=0)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)

rem ��װProduct

if "#%argsProduct%"=="#True" (
	call :getUrl "!ipList!"
	set sdUrl=!returnValue!
	for /f "delims=/ tokens=4" %%a in ("!sdUrl!") do (
		echo %%a|findstr "^Ent_360EPP[0-9]*\[.*\]-W.exe" >nul
		if !errorlevel! equ 0 set name_360=%%a
	)
	call :writeLog INFO installProduct "��ʼ����ȫ��Ʒ��װ" True True
	if "#!uacStatus!"=="#True" (
		if "#%regStatus%+%processStatus%"=="#True+True" (
			call :writeLog INFO installProduct "��ȫ��Ʒ�汾 [%initProductName%] �Ѱ�װ,�����ٴΰ�װ" True True
			set exitCode=0
		) else (
			if "!name_360!"=="" (
				call :writeLog INFO installProduct "�������Ӵ����޷���ȷ����: [%initProductName%] ��ֹ��װ" True True
			) else (
				call :writeLog INFO downloadProduct "��ʼ���ذ�ȫ��Ʒ: [!sdUrl!]" True True
				call :downFile "%~f0" "!sdUrl!" "%path_Temp%\!name_360!"
				call :writeLog INFO downloadProduct "Product.msi ����״̬��: [!returnValue!]" True True 
				set path_product=%path_Temp%\!name_360!
			)
		)
		if not exist "!path_product!" (
			call :writeLog ERROR installProduct "δ�ҵ���ʹ�õ�·��:[!path_product!],��ȫ��Ʒ��װʧ��" True True
			set exitCode=11
		) else (
			call :writeLog INFO installProduct "��ʼ��װ��ȫ��Ʒ: [!path_product!]" True True

			if "#%argsGui%"=="#True" (
				start /b "360Install" "!path_product!"
			) else (
				start /b "360Install" "!path_product!" /s
				
			)
			echo\
			echo ������̿�����Ҫ10�������ҵ�ʱ��,���Ժ�...
			echo\
			call :checkInstStatus 600
			if "!instStatus!"=="2" (
				call :writeLog ERROR installProduct "��ȫ��Ʒ [!path_product!] ��װ״̬��:[ʧ��],����ϵͳ��������ϵ����Ա" True True
				set exitCode=11
			) else if "!instStatus!"=="1" (
				call :writeLog ERROR installProduct "��ȫ��Ʒ [!path_product!] ��װ״̬��:[��ʱ],����ϵͳ��������ϵ����Ա" True True
				set exitCode=11
			) else if "!instStatus!"=="0" (
				call :writeLog ERROR installProduct "��ȫ��Ʒ [!path_product!] ��װ״̬��:[�ɹ�]" True True
				echo\
				echo ����ͻ���δ����������,���������Ժ󼴿���������.
				echo\
				set exitCode=0
			) else (
				call :writeLog ERROR installProduct "��ȫ��Ʒ [!path_product!] ��װ״̬��:[δ֪],����ϵͳ��������ϵ����Ա" True True
				set exitCode=11
			)
		)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)
)

rem ɾ�������ص���ʱ�ļ�
if "#%argsRemove%"=="#True" (
	call :writeLog INFO delTempFile "��ʼɾ����ʱ�ļ�" True True
	pushd %path_Temp%
	for %%a in (*.exe *.error) do (
		del /f /q %%a
	)
	popd
)

rem ��ӡϵͳ״̬
if "#%argsSysStatus%"=="#True" (
	call :writeLog INFO printSysStatus "��ʼ��ӡϵͳ״̬" True True
	call :getStatus
	set exitCode=0
)
goto :exitScript
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
echo  -h,	--help		��ӡ�����а���
echo  -p,	--product	��װ��%initProductName%��
echo  -d,	--undoProduct	ж�ء�%initProductName%��
echo  -s,	--status	���״̬
echo  -l,	--log		�ر���־��ӡ
echo  -r,	--remove	ɾ����ʱ�ļ�
echo  -i,    --avUninst	�Ƴ�����ɱ�����
echo  -u,	--gui		������������
echo  -v,	--version	��ӡ��ǰ�汾
echo.
echo		Example:%~nx0 -o --agent -l --remove
echo\
echo              Code by Kermit Yao @ Windows 11, 2023-03-8 ,jianyu.yao@ych-sh.com
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
echo.*	jianyu.yao@ych-sh.com			*
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
	rem echo error
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

rem ƥ��ip��ʽ;�������: %1 = ip; ��: call :matchIp 10.1.1.5; ����ֵ: returnValue=True | False
:matchIp
set flag=False
if not "%~1"=="" (
	echo "%~1" | findstr "^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$">nul&&echo flag=True
)
set returnValue=%flag%
set flag=
goto :eof

rem ���ݲ�ͨip��ȡɱ����������;�������: %1 = ipList; ��: call :getUrl 10.1.1.5,10.1.1.6; ����ֵ: returnValue=��������
:getUrl
set flag=False
set returnValue=
for /l %%a in (1 1 20) do (
	if not "!sdUrl_%%a!"=="" (
		for /f "delims=: tokens=1*" %%x in ("!sdUrl_%%a!") do (
			echo "%~1"|findstr "%%x" >nul && set flag=True
			if "!flag!"=="True" (
				set returnValue=%%y
				goto :eof
			)
		)
	)
)
if "!flag!"=="False" (
	for /f "delims=: tokens=1*" %%x in ("!sdUrl_1!") do set returnValue=%%y
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
						set avUninstFlag=True
						set tempMsg=%%g
						set tempMsg=!tempMsg:"=!
						call :writeLog INFO avUninst "������%%~b��ж�س���: !tempMsg!" True True
						start /b "avUninst" "%%~g"
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
				call :writeLog INFO avUninst "������%%b��ж�س���: msiexec /x {!avCode!}" True True
				echo\
				echo	�ȴ�ж�����...
				echo\
				if not "#%argsGui%"=="#True" (
					start /b /wait "avUninst" msiexec /qn /norestart /x {!avCode!}
				) else (
					start /b /wait "avUninst" msiexec /qb /norestart /x {!avCode!}
				)
			)
		)
	)
)
goto :eof

:getStatus
set regStatus=False
set processStatus=False
echo �������:%args%

call :getUac
call :getProductInfo

echo UACȨ��:%uacStatus%
echo ���������:%computerName%
echo ϵͳ�汾:%sysVersion%
echo NT�ں˰汾:%ntVer%
echo ϵͳ����:%sysType%
echo IP ��ַ�б�:%ipList%
echo ϵͳƽ̨����:%sysArch%

echo ��Ʒ����:%productName%
echo ��װ·��:%productPath%
echo ��װʱ��:%productInstTime%
echo ���ĵ�ַ:%productConnectAddress%
echo ��Ȩ  ID:%productEppID%
echo �ϴ�ͨѶ:%productLastConnectTime%

if "#%regStatus%+%processStatus%"=="#True+True" (
	echo ***************** ��%initProductName%����װ���� *****************
) else (
	echo ***************** ��%initProductName%����װ�쳣 *****************
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

rem ѭ����鰲װ�Ƿ����; ��������� %1 ��ʱʱ�䣻 ���� call :checkInstStatus 600; ����ֵ: instStatus = True | False
:checkInstStatus
set loopTimes=%1
set loopInit=1
set instStatus=3
:checkInstStatusLoop
set instProcessStatus=False
call :getProductInfo
tasklist /FO CSV /FI "IMAGENAME eq !name_360!" 2>nul|findstr /c:"!name_360!" >nul&& set instProcessStatus=True
if "%instProcessStatus%"=="True" (
	if "#%regStatus%+%processStatus%"=="#True+True" (
		set instStatus=0
		goto :checkInstStatusBreak
	) else (
		set /a loopInit+=1
		ping /n 2 127.0.0.1 >nul
	)
) else (
	if "#%regStatus%+%processStatus%"=="#True+True" (
		set instStatus=0
		goto :checkInstStatusBreak
	) else (
		set instStatus=2
		goto :checkInstStatusBreak
	)
)

if %loopInit% GEQ %loopTimes% (
	set instStatus=1
	goto :checkInstStatusBreak
)

goto :checkInstStatusLoop
:checkInstStatusBreak
goto :eof

rem ��ȡ����汾; �������: %1 =Product | Agent ; ����call :getVersion Product; ����ֵ:returnValue=�汾�� | Null,�����Ʒ���������±����ᱻ��ֵ��productCode,productName,productVersion,productDir
:getProductInfo
set productName=
set productPath=
set productInstTime=
set productConnectAddress=
set productEppID=
set productLastConnectTime=
set processStatus=False
set regStatus=False
tasklist /FI "IMAGENAME eq 360epp.exe" 2>nul|findstr "360epp.exe" >nul&& set processStatus=True
if "%sysArch%"=="x64" (
	set regPath="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\360Safe\360EntSecurity"
) else (
	set regPath="HKEY_LOCAL_MACHINE\SOFTWARE\360Safe\360EntSecurity"
)
reg query %regPath% /v MsgSrvIP >nul 2>&1
if %errorlevel% equ 1 goto :eof
for /f "tokens=1,2*" %%a in ('reg query %regPath% 2^>nul') do (
	if "%%a"=="ProductName" (set productName=%%c)
	if "%%a"=="InstPath" (set productPath=%%c)
	if "%%a"=="InstTime" (set productInstTime=%%c)
	if "%%a"=="MsgSrvIP" (set productConnectAddress=%%c)
	if "%%a"=="Partner" (set productEppID=%%c)
	if "%%a"=="SYSTEMConnectedTime" (set productLastConnectTime=%%c)
)
if not "#%productConnectAddress%"=="#" set regStatus=True
goto :eof

rem ������һ������ʱ,���û�ȡϵͳ��Ϣ�������������Ч��.
:getSysInfo
set tmpArgsList_getSysVer=argsProduct argsSysStatus DEBUG 
for %%a in (%tmpArgsList_getSysVer%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		call :getSysVer
		goto :endGetSysVer
	)
)
:endGetSysVer

set tmpArgsList_getSysArch=argsProduct argsSysStatus argsUndoProduct DEBUG
for %%a in (%tmpArgsList_getSysArch%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		call :getSysArch
		goto :endGetSysArch
	)
)
:endGetSysArch

set tmpArgsList_getProductInfo=argsUndoProduct argsProduct
for %%a in (%tmpArgsList_getProductInfo%) do (
	if "#!%%a!"=="#True" (
		call :getProductInfo
		goto :endGetProductInfo
	)
)
:endGetProductInfo

set tmpArgsList_getDownUrl=argsProduct DEBUG
for %%a in (%tmpArgsList_getDownUrl%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		goto :eof
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