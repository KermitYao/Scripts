1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem �����˲�����cmdָ��������guiѡ�񽫻�ʧЧ;
rem �൱��ǿ��ʹ�������в�����
rem �������Ҫ����Ϊ�ռ���
rem ʹ�÷��� �� SET DEFAULT=-o --agent -l --del -, ��������cmd��������һ��
SET DEFAULT_ARGS=

rem ��־�ȼ� DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem ���������б�
set argsList=argsHelp argsAll argsHotfix argsProduct argsAgent argsUndoAgent argsUndoProduct argsEntrySafeMode argsExitSafeMode argsStatus argsLog argsDel argsGui 
::----------------------------------

rem ----------- init -----------
rem ���ó�ʼ����
:getPackagePatch

rem �Ѱ�װ�����,С�ڴ˱�������и��ǰ�װ,�汾��ֻ������λ��������λ����������
set version_Agent=8.0
set version_Product_eea=8.0
set version_Product_efsw=7.3
rem -------------------

rem ���·��ΪUNC��ɷ��ʵľ���·������Ҫ���ص�����,��ֱ�ӵ��ð�װ����������ص���ʱĿ¼��ʹ�þ���·����ʽ����
rem �Ƿ�ΪUNC·������� True|False
set absStatus=True
rem ����ǹ���Ŀ¼���������˺����룬�����Ƚ���ipc$���ӣ�Ȼ����ʹ��UNC·����ʽ���á����Ϊ���򲻽���IPC$���ӡ�
set shareUser="kermit"
set sharePwd="5698"

if %absStatus%==False (

	rem ���е�·����ҪЯ�� ���� ���ţ��������Զ������������⡣
	rem Agent ���ص�ַ
	set path_agent_x86=http://192.168.30.43:8080/_ShareFile/ESET/EEA/agent_x86_v8.0.msi
	set path_agent_x64=http://192.168.30.43:8080/_ShareFile/ESET/EEA/agent_x64_v8.0.msi

	rem Agent �����ļ�
	set path_agent_config=http://192.168.30.43:8080/_ShareFile/ESET/EEA/install_config.ini

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_agent=password=eset1234.
	set params_agent=

	rem -------------------

	rem PC Product ���ص�ַ
	set path_eea_v6.5_x86=http://192.168.30.43:8080/_ShareFile/ESET/EEA/eea_nt32_v6.5.msi
	set path_eea_v6.5_x64=http://192.168.30.43:8080/_ShareFile/ESET/EEA/eea_nt64_6.5.msi

	set path_eea_late_x86=http://192.168.30.43:8080/_ShareFile/ESET/EEA/eea_nt32_v8.0.msi
	set path_eea_late_x64=http://192.168.30.43:8080/_ShareFile/ESET/EEA/eea_nt64_v8.0.msi
	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_eea=password=eset1234.
	set params_eea=

	rem SERVER Product ���ص�ַ
	set path_efsw_v6.5_x86=
	set path_efsw_v6.5_x64=

	set path_efsw_late_x86=
	set path_efsw_late_x64=http://192.168.30.43:8080/_ShareFile/ESET/EEA/efsw_nt64_v7.3.msi

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_efsw=password=eset1234.
	set params_efsw=
	rem -------------------

	rem �����ļ� ���ص�ַ
	set path_hotfix_kb4474419_x86=http://192.168.30.43:8080/_ShareFile/ESET/Tools/SHA2CAB/Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=http://192.168.30.43:8080/_ShareFile/ESET/Tools/SHA2CAB/Windows6.1-KB4474419-v3-x64.cab

	set path_hotfix_kb4490628_x86=http://192.168.30.43:8080/_ShareFile/ESET/Tools/SHA2CAB/Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=http://192.168.30.43:8080/_ShareFile/ESET/Tools/SHA2CAB/Windows6.1-KB4490628-x64.cab

) else (

	rem ���е�·����ҪЯ�� ���� ���ţ��������Զ������������⡣
	rem Agent ���ص�ַ
	set path_agent_x86=\\192.168.30.43\_ShareFile\ESET\EEA\agent_x86_v8.0.msi
	set path_agent_x64=\\192.168.30.43\_ShareFile\ESET\EEA\agent_x64_v8.0.msi

	rem Agent �����ļ�
	set path_agent_config=\\192.168.30.43\_ShareFile\ESET\EEA\install_config.ini

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_agent=password=eset1234.
	set params_agent=

	rem -------------------

	rem PC Product ���ص�ַ
	set path_eea_v6.5_x86=\\192.168.30.43\_ShareFile\ESET\EEA\eea_nt32_v6.5.msi
	set path_eea_v6.5_x64=\\192.168.30.43\_ShareFile\ESET\EEA\eea_nt64_6.5.msi

	set path_eea_late_x86=\\192.168.30.43\_ShareFile\ESET\EEA\eea_nt32_v8.0.msi
	set path_eea_late_x64=\\192.168.30.43\_ShareFile\ESET\EEA\eea_nt64_v8.0.msi
	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_eea=password=eset1234.
	set params_eea=

	rem SERVER Product ���ص�ַ
	set path_efsw_v6.5_x86=
	set path_efsw_v6.5_x64=

	set path_efsw_late_x86=
	set path_efsw_late_x64=\\192.168.30.43\_ShareFile\ESET\EEA\efsw_nt64_v7.3.msi

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_efsw=password=eset1234.
	set params_efsw=
	rem -------------------

	rem �����ļ� ���ص�ַ
	set path_hotfix_kb4474419_x86=\\192.168.30.43\_ShareFile\ESET\Tools\SHA2CAB\Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=\\192.168.30.43\_ShareFile\ESET\Tools\SHA2CAB\Windows6.1-KB4474419-v3-x64.cab

	set path_hotfix_kb4490628_x86=\\192.168.30.43\_ShareFile\ESET\Tools\SHA2CAB\Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=\\192.168.30.43\_ShareFile\ESET\Tools\SHA2CAB\Windows6.1-KB4490628-x64.cab

)

rem -------------------

rem ��ʱ�ļ�����־���·��
set path_Temp=%temp%\ESET_TEMP_INSTALL

rem ��װ cab ��Ĭ�ϲ���
set params_hotfix="/quiet /norestart"

rem ��¼��ʼ�����в���
set srcArgs=%*

if "#%DEFAULT_ARGS%"=="#" (
	set args=%srcArgs%

) else (
	set args=%DEFAULT_ARGS%

)

rem ----------- init -----------

rem ----------- begin start -----------
:begin
if not exist %path_Temp% md %path_Temp%

%bugTest%
echo [%args%]

if "#%args%"=="#" (
	call :getGuiHelp
	if "#%DEFAULT_ARGS%"=="#" (set args=!returnValue!) 
)

call :getArgs %args%

rem �����GUI��������ʾһ�����׵İ�װ���棬����Ĭ��װ
if "#%argsGui%"=="#True" (
	set params_msiexec=/qr /norestart
) else (
	set params_msiexec=/qn /norestart
)

rem ��ӡ�����а���
if "#%argsHelp%"=="#True" (
	call :getCmdHelp
	set exitCode=0
	goto :exitScript
)

echo ���ڴ��������Ϣ...


if "#%argsEntrySafeMode%"=="#True" (
	call :setSafeBoot entry
	if "#!returnValue!"=="#True" (
		call :writeLog INFO entrySafeMode "�Ѿ�����Ϊ��ȫģʽ,�����´�����ʱ���밲ȫģʽ" True True
		set exitCode=0
	) else (
		call :writeLog ERROR entrySafeMode "����Ϊ��ȫģʽʧ��" True True
		set exitCode=9
	)	
)

if "#%argsexitSafeMode%"=="#True" (
	call :setSafeBoot exit
	if "#!returnValue!"=="#True" (
		call :writeLog INFO exitSafeMode "�Ѿ�����Ϊ����ģʽ,�����´�����ʱ��������ģʽ" True True
		set exitCode=0
	) else (
		call :writeLog ERROR exitSafeMode "����Ϊ����ģʽʧ��" True True
		set exitCode=10
	)	
)

rem ж�� Agent
if "#%argsUndoAgent%"=="#True" (
	call :getVersion Agent
	if "#!productCode!"=="#" (
		call :writeLog WARNING uninstallAgent "ESET Management Agent δ��װ,����ж��" True True
	) else (
		call :writeLog INFO uninstallAgent "��ʼж�� [!productName!]" True True
		call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
		call :writeLog DEBUG uninstallAgent "[!productName!] ж���˳���:[!errorlevel!]" False True
		call :writeLog INFO uninstallAgent "[!productName!] ж��״̬��:[!returnValue!]" True True
		if "#!returnValue!"=="#False" (call :writeLog ERROR uninstallAgent "[!productName!] ж��״̬��:[ʧ��],���鰲װ״̬����ϵ����Ա" True True)
	)
	if "#!returnValue!"=="#False" (set exitCode=7) else (set exitCode=0)
)

rem ж�� Product
if "#%argsUndoProduct%"=="#True" (
	call :getVersion Product
	if "#!productCode!"=="#" (
		call :writeLog WARNING uninstallProduct "ESET Product δ��װ,����ж��" True True
	) else (
		call :writeLog INFO uninstallProduct "��ʼж�� [!productName!]" True True
		call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
		call :writeLog DEBUG uninstallProduct "[!productName!] ж���˳���:[!errorlevel!]" False True
		call :writeLog INFO uninstallProduct "[!productName!] ж��״̬��:[!returnValue!]" True True
		if "#!returnValue!"=="#False" (call :writeLog ERROR uninstallProduct "[!productName!] ж��״̬��:[ʧ��],���鰲װ״̬����ϵ����Ա" True True)
	)
	if "#!returnValue!"=="#False" (set exitCode=8) else (set exitCode=0)
)

rem ��װ����
if "#%argsHotfix%"=="#True" (
	call :writeLog INFO installHotfix "��ʼ������" True True
	call :getSysVer
	if  "#%ntVer:~,3%"=="#6.1#" (
		call :writeLog WARNING installHotfix "��ǰϵͳ�汾��֧�ְ�װ����" True True
		set exitCode=97
		goto :exitScript
	)

	call :getSysArch
	if "#!sysArch%!"=="#x64" (
			set hotfix_kb4490628=%path_hotfix_kb4490628_x64%
			set hotfix_kb4474419=%path_hotfix_kb4474419_x64%
	) else (
			set hotfix_kb4490628=%path_hotfix_kb4490628_x86%
			set hotfix_kb4474419=%path_hotfix_kb4474419_x86%
	)
	
	if "#%absStatus%"=="#True" (
		call :connectShare "!hotfix_kb4490628!" %shareUser% %uncPwd%
		call :writeLog DEBUG shareConnect "���� hotfix_kb4490628 ��������״̬�ǣ� [!returnValue!]" False True 

		call :connectShare "!hotfix_kb4474419!" %shareUser% %sharePwd%
		call :writeLog DEBUG shareConnect "���� hotfix_kb4474419 ��������״̬�ǣ� [!returnValue!]" False True 
	) else (
		call :writeLog INFO hotfixDownload "��ʼ���ز���: [hotfix_kb4490628.cab]" True True
		call :downFile "%~f0" "!hotfix_kb4490628!" "%path_Temp%\hotfix_kb4490628.cab"
		call :writeLog INFO hotfixDownload "���� hotfix_kb4490628 ����״̬��: [!returnValue!]" True True 
		set hotfix_kb4490628="%path_Temp%\hotfix_kb4490628.cab"

		call :writeLog INFO hotfixDownload "��ʼ���ز���: [hotfix_kb4474419.cab]" True True
		call :downFile "%~f0" "!hotfix_kb4474419!" "%path_Temp%\hotfix_kb4474419.cab"
		call :writeLog INFO hotfixDownload "���� hotfix_kb4474419 ����״̬��: [!returnValue!]" True True 
		set hotfix_kb4474419="%path_Temp%\hotfix_kb4474419.cab"
	)

	for %%a in (!hotfix_kb4490628! !hotfix_kb4474419!) do (
		if not exist "%%~a" (
			call :writeLog ERROR hotfixInstall "δ�ҵ���ʹ�õ�·��:[%%~a]" True True
		) else (
			call :writeLog INFO hotfixInstall "��ʼ��װ����: [%%~a]" True True
			call :hotFixInstall "%%~a" "/quiet /norestart"
			call :writeLog DEBUG hotfixInstall "hotfix [%%~a] ��װ�˳���:[!errorlevel!]" False True
			call :writeLog INFO hotfixInstall "������� [%%~a] ��װ״̬��:[!returnValue!]" True True
			if "#!dismExitCode!"=="#3310" (call :writeLog WARNING hotfixInstall "������� [%%~a] ��װ״̬��:[����],����Ҫ�������ܽ��к�����װ" True True)
		)
	)
	
	if "#!returnValue!"=="#False" (set exitCode=5) else (set exitCode=0)
)

rem ��װAgent management
if "#%argsAgent%"=="#True" (
	call :writeLog INFO installAgent "��ʼ����Agent" True True
	call :getVersion Agent
	set returnValue=!returnValue:.=!
	set agentCurrentVersion=!returnValue:~,2!
	set agentInstallVersion=%version_Agent:.=%
	set agentInstallVersion=!agentInstallVersion:~,2!
	if !agentCurrentVersion! lss !agentInstallVersion! (
		call :getSysArch
		if "#!sysArch%!"=="#x64" (
			set agent=%path_agent_x64%
		) else (
			set agent=%path_agent_x86%
		)
		set agent_config=%path_agent_config%

		if "#%absStatus%"=="#True" (
			call :connectShare "!agent!" %shareUser% %uncPwd%
			call :writeLog DEBUG shareConnect "Agent ��������״̬��: [!returnValue!]" False True 

			call :connectShare "!agent_config!" %shareUser% %sharePwd%
			call :writeLog DEBUG shareConnect "Agent ���� ��������״̬��: [!returnValue!]" False True 
		) else (
			call :writeLog INFO agentDownload "��ʼ����Agent: [agent.msi]" True True
			call :downFile "%~f0" "!agent!" "%path_Temp%\agent.msi"
			call :writeLog INFO agentDownload "Agent.msi ����״̬��: [!returnValue!]" True True 
			set agent="%path_Temp%\agent.msi"

			call :writeLog INFO agentConfigDownload "��ʼ����Agent config: [install_config.ini]" True True
			call :downFile "%~f0" "!agent_config!" "%path_Temp%\install_config.ini"
			call :writeLog INFO agentConfigDown "install_config.ini ����״̬��: [!returnValue!]" True True 
			set agent_config="%path_Temp%\install_config.ini"
		)

		for %%a in (!agent!) do (
			if not exist "!agent!" (
				call :writeLog ERROR agent "δ�ҵ���ʹ�õ�·��:[%%~a]" True True
			) else (
				if exist !agent_config! (
					call :writeLog INFO agentInstall "��ʼ��װAgent: [%%~a]" True True
					call :msiInstall "%%~a" "%params_msiexec%" "%params_agent%"
					call :writeLog DEBUG agentInstall "Agent [%%~a] ��װ�˳���:[!errorlevel!]" False True
					call :writeLog INFO agentInstall "Agent [%%~a] ��װ״̬��:[!returnValue!]" True True
					if "#!returnValue!"=="#False" (call :writeLog ERROR agentInstall "Agent [%%~a] ��װ״̬��:[ʧ��],�����������ϵ����Ա" True True)
					if "#!returnValue!"=="#False" (set exitCode=6) else (set exitCode=0)
				) else (
					call :writeLog ERROR agentInstall "δ�ҵ������ļ� [!agent_config!],���˳����ΰ�װ,��װ״̬��:[ʧ��],�����������ϵ����Ա" True True
					set exitCode=6
				)
			)
		)
	) else (
		call :writeLog INFO agentInstall "Agent �汾 [%version_Agent%] С�ڻ���ڵ�ǰ�Ѱ�װ�İ汾,�����ٴΰ�װ" True True
		set exitCode=0
	)
)

rem ��ӡϵͳ״̬
if "#%argsSysStatus%"=="#True" (
	call :getStatus
	set exitCode=0
)

rem û��ƥ��Ĳ����򱨴�
if not "#%argsStatus%"=="#True" (
	call :writeLog ERROR witeLog "������������δ�ҵ����ʵ�ѡ��" True True
	set exitCode=98
	goto :exitScript
)


rem exitCode: ����:0,��׼�����б���:1,ϵͳ�汾����:2,ϵͳƽ̨����:3,�޷���ȡ������:4,�в�����װʧ�ܻ����:5,��װAgentʧ��:6,ж��agentʧ��:7,ж��productʧ��:8,���밲װģʽʧ��:9,�˳���װģʽʧ��:10,��������:97,�޷���������:98,δ֪����:99
:exitScript
echo Source �˳���:%errorlevel%
echo �˳���:%exitCode%
::call :debug
if "#%argsGui%"=="#True" (
	call :writeLog INFO exit "�����������" True True
	pause >nul
	exit /b %exitCode%
) else (
	exit /b %exitCode%
)

rem ----------- begin end -----------



:debug
echo --------------- debug ---------------
echo exitCode: 
echo ----------����״̬-----------
for %%a in (%argsList%) do (
	call :getVar tmpStatus %%a
	if not "#!tmpStatus!"=="#" echo %%a:!tmpStatus!
)
echo ----------����״̬-----------
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

rem ����Ϊ������˳���ȫģʽ; �������:%1 = entry | exit |status ;����call :setSafeBoot entry; ����ֵ: returnValue = True | False,���������Ϊ: status ʱ���±���������ֵ:safeModeStatus=False|True
:setSafeBoot
set safeBoot=
set returnValue=
set safeModeStatus=False
if "#%~1"=="#entry" (
	bcdedit /set {default} safeboot "network" >nul 2>&1
) 

if "#%~1"=="#exit" (
	bcdedit|find "safeboot" >nul && set tmpStatus=True
	if "#!tmpStatus!"=="#True" (
		bcdedit /deletevalue {default} safeboot >nul
	) else (
		bcdedit >nul
	)
)

if "#%~1"=="#status" (
	bcdedit|find "safeboot" >nul && set safeModeStatus=True
)

if !errorlevel! equ 0 (
	set returnValue=True
) else (
	set returnValue=False
)

goto :eof

rem ��ȡϵͳ�汾; �������:���贫�룻����call :getSysVer ; ����ֵ: returnValue = "Windows XP"|"Windows 7"|"Windows 10"|"Windows Server 2008"|"Windows Server 2012"|"Windows Server 2016"|"Windows Server 2019"
:getSysVer
set sysVer="Windows XP" "Windows 7" "Windows 10" "Windows Server 2008" "Windows Server 2012" "Windows Server 2016" "Windows Server 2019"
set returnValue=
set sysVersion=
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') do (
	for %%x in (%sysVer%) do (
		set tm=%%x
		echo %%b|find /i %%x>nul&&set  sysVersion=!tm: =!
	)
)

for /f "tokens=4" %%a in ('ver') do (
	set ntVer=%%a
	set ntVer=!ntVer:~,-1!
)

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

:getCmdHelp
echo  Usage: %~nx0 [options]
echo\
echo  -h,	--help		[optional] Print the help message
echo  -a,	--all		[optional] Install 'Hotfix ^& Product ^& Agent'
echo  -o,	--hotfix	[optional] Install Hotfix
echo  -p,	--product	[optional] Install Product
echo  -g,	--agent		[optional] Install Agent
echo  -n	--undoAgent	[optional] Uninstall Agent management
echo  -d	--undoProduct	[optional] Uninstall Product
echo  -e	--entrySafeMode	[optional] Entry safe mode
echo  -x	--exitSafeMode	[optional] Exit safe mode
echo  -s,	--status	[optional] Check status
echo  -l,	--log		[optional] Enable log
echo  -d,	--del		[optional] Delete downloaded files
echo  -u,	--gui		[optional] Like GUI show
echo.
echo		Example:%~nx0 -o --agent -l --del
echo\
echo              Code by Windows, 2021-04-5 ,kermit.yao@outlook.com
goto :eof

rem ��ȡ gui ����,����;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.*************************************************
echo.*						*
echo.*	a.�Զ���鰲װ ����+����+��ȫ��Ʒ	*
echo.*						*
echo.*	o.��װ����				*
echo.*						*
echo.*	p.��װ��ȫ��Ʒ				*
echo.*						*
echo.*	g.��װ����������			*
echo.*						*
echo.*	n.ж�� Agent				*
echo.*						*
echo.*	d.ж�� ��ȫ��Ʒ				*
echo.*						*
echo.*	e.���밲ȫģʽ				*
echo.*						*
echo.*	x.�˳���ȫģʽ				*
echo.*						*
echo.*	s.���״̬				*
echo.*						*
echo.*	h.��ʾ�����а���			*
echo.*						*
echo.*	kermit.yao@outlook.com			*
echo.*						*
echo.*************************************************
echo.
echo.
set /p input=��ѡ��:(a^|o^|p^|n^|d^|e^|x^|g^|s^|h):
for %%a in (a o p g n d e x s h) do (
	if "#!input!"=="#%%a" (
		cls
		echo.
		set guiArgsStatus=-%%a -u -l
	)
)

if "!helpValue!"=="True" (
	goto :eof
)


if not "#!guiArgsStatus!"=="#" (
	set returnValue=!guiArgsStatus!
) else (
	cls
	call :writeLog getGuiHelp ERROR "ѡ�����:[!input!]" True True
	goto getGuiHelp
)
goto :eof

rem �����������; �������: %1 = �����б�����call :getArgs args ; ����ֵ: �޷���ֵ
:getArgs

for %%a in (%*) do (
	if /i "#%%a"=="#-h" set argsHelp=True
	if /i "#%%a"=="#--help" set argsHelp=True

	if /i "#%%a"=="#/h" set argsHelp=True

	if /i "#%%a"=="#-a" (
		set argsAll=True
		set argsHotfix=True
		set argsProduct=True
		set argsAgent=True
		)

	if /i "#%%a"=="#--all" (
		set argsAll=True
		set argsHotfix=True
		set argsProduct=True
		set argsAgent=True
		)

	if /i "#%%a"=="#-o" set argsHotfix=True
	if /i "#%%a"=="#--hotfix" set argsHotfix=True

	if /i "#%%a"=="#-p" set argsProduct=True
	if /i "#%%a"=="#--product" set argsProduct=True

	if /i "#%%a"=="#-g" set argsAgent=True
	if /i "#%%a"=="#--agent" set argsAgent=True

	if /i "#%%a"=="#-n" set argsUndoAgent=True
	if /i "#%%a"=="#--undoAgent" set argsUndoAgent=True

	if /i "#%%a"=="#-d" set argsUndoProduct=True
	if /i "#%%a"=="#--undoProduct" set argsUndoProduct=True

	if /i "#%%a"=="#-e" set argsEntrySafeMode=True
	if /i "#%%a"=="#--entrySafeMode" set argsEntrySafeMode=True

	if /i "#%%a"=="#-x" set argsExitSafeMode=True
	if /i "#%%a"=="#--exitSafeMode" set argsExitSafeMode=True

	if /i "#%%a"=="#-s" set argsSysStatus=True
	if /i "#%%a"=="#--status" set argsSysStatus=True

	if /i "#%%a"=="#-l" set argsLog=True
	if /i "#%%a"=="#--log" set argsLog=True

	if /i "#%%a"=="#-d" set argsDel=True
	if /i "#%%a"=="#--del" set argsDel=True

	if /i "#%%a"=="#-u" set argsGui=True
	if /i "#%%a"=="#--gui" set argsGui=True
	)
)
for %%a in (%argsList%) do (
	if "#!%%a!"=="#True" set argsStatus=True
)
goto :eof

::���ر�����ȡ
:getVar
set %1=!%2!
goto :eof


rem �ж��Ƿ�װ����; �������: %1 = �����ţ�����call :getHotfixStatus KB4474419 ; ����ֵ: returnValue=True | False | Null
:getHotfixStatus
set hotfixStatus=False
wmic qfe get hotfixid|find /i "%1" >nul&&set hotfixStatus=True

if "#"=="#!hotfixStatus!" (
	set returnValue=Null
) else (
	set returnValue=!hotfixStatus!
)
goto :eof

rem ��װmsi�ļ�; �������: %1 = �ļ�·����%2 = ������%3 = ׷�Ӳ���������call :msiInstall "%temp%\ESET_INSTALL\eea_v8.0.msi" "/qn" "password=eset1234."; ����ֵ: returnValue=True | False
:msiInstall
set returnValue=False
start /wait  msiexec %~2 /i "%~1" %~3
if "#%errorlevel%"=="#0" set returnValue=True
goto :eof

rem ж�����; �������: %1 = ��Ʒ���룬%2 = ������%3 = ׷�Ӳ���������call :uninstallProduct  "{76DA17F9-BC39-4412-88F0-F173806999E7}" "/qn" "password=eset1234."; ����ֵ: returnValue = True|False. 
:uninstallProduct
set returnValue=False
start /wait  msiexec %~2 /x "%~1" %~3
if "#%errorlevel%"=="#0" set returnValue=True
goto :eof

rem ��װcab�ļ�; �������: %1 = �ļ�·����%2 = ����������call :hotFixInstall "%temp%\ESET_INSTALL\Windows-KB4474419.CAB" "/quiet /norestart" ; ����ֵ: returnValue=True | False
:hotFixInstall
set hotFixInstallStatus=False
set returnValue=False
start /b /wait dism /online /add-package /packagePath:"%~1" %~2 >nul 2>&1

if "#!errorlevel!"=="#0" set returnValue=True
if "#!errorlevel!"=="#3010" set returnValue=True
set dismExitCode=!errorlevel!
::dism /online /get-packages | findstr "%~3" >nul && set hotFixInstallStatus=True

goto :eof



:getStatus
echo �������:%args%

call :getUac
echo UACȨ��:!uacStatus!

call :getSysVer
echo ϵͳ�汾:!sysVersion!
echo NT�ں˰汾:!ntVer!

call :getSysArch
echo ϵͳƽ̨����:!sysArch!

call :getHotfixStatus KB4474419
echo KB4474419 ������װ״̬:!returnValue!

call :getHotfixStatus KB4490628
echo KB4490628 ������װ״̬:!returnValue!

call :getVersion Product
echo ��Ʒ��װ����:!productName!
echo ��Ʒ��װ�汾:!productVersion!
echo ��Ʒ��װ·��:!productDir!
echo ��Ʒ��װ����:!productCode!


call :getVersion Agent
echo Agent ��װ����:!productName!
echo Agent ��װ�汾:!productVersion!
echo Agent ��װ·��:!productDir!
echo Agent ��װ����:!productCode!

call :setSafeBoot status
echo �Ƿ�����Ϊ��ȫģʽ:!safeModeStatus!
goto :eof

rem ���ӹ�������; �������: %1 = ������ %2 = �û���, %3 = ����; ����call :connectShare "\\127.0.0.1" "kermit" "5698" ; ����ֵ: returnValue=True | False
:connectShare
set tmpStatus=False
if "#%~1" == "#" (
	set returnValue=!tmpStatus!
	goto :eof
)
set cmd_user_param=/user:"%~2"
set tmpValue=%~dp1
set shareHost=%tmpValue:~,-1%
for /f "delims=" %%a in ('net use "%shareHost%" %cmd_user_param% "%~3" 2^>nul ^&^& echo statusTrue') do (
	set tm=%%a
	if "#!tm:~,10!"=="#statusTrue" (
		set tmpStatus=True
	)
)
set returnValue=!tmpStatus!

goto :eof

rem �����ļ�; �������: %1 = ��ǰ�ļ�·���� %2 = url, %3 = �����ַ; ����call :downFile "%~f0" "http://192.168.31.99/test.rar" "d:\test.rar"; ����ֵ: returnValue=True | False
:downFile
set downStatus=False

for  /f %%a in  ('cscript /nologo /e:jscript "%~f1" /downUrl:%2 /savePath:%3') do (
	if "#%%a"=="#True" set downStatus=True
	call :writeLog witeLog INFO "The file [%2] was download by "jscript"" False True 
)

if "#!downStatus!"=="#False" (
	if not "#%sysVersion%"=="#WindowsXp" (
		for  /f "delims=" %%a in  ('powershell -Command "& {(New-Object Net.WebClient).DownloadFile('%~2', '%~3');($?)}" 2^>nul') do (
				if "#%%a"=="#True" set downStatus=True
				call :writeLog witeLog INFO "The file [%2] was download by "powershell"" False True 
		)
	)
)
set returnValue=!downStatus!
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

rem ��ȡ����汾; �������: %1 =Product | Agent ; ����call :getVersion Product; ����ֵ:returnValue=�汾�� | Null,�����Ʒ�������±����ᱻ��ֵ��productCode,productName,productVersion,productDir
:getVersion
set productVersion=
set productName=
set productDir=
set productCode=

if /i "#%~1"=="#Product" (
	set keyValue="HKEY_LOCAL_MACHINE\SOFTWARE\ESET\ESET Security\CurrentVersion\Info"
	for /f "tokens=2*" %%a in ('reg query !keyValue! /v ProductCode 2^>nul') do (
		set "productCode=%%b"
	)
) else (
	set keyValue="HKEY_LOCAL_MACHINE\SOFTWARE\ESET\RemoteAdministrator\Agent\CurrentVersion\Info"
	for /f "delims={} tokens=2" %%a in ('wmic product list ^| find /i "ESET Management Agent"') do (
		set "productCode={%%a}"
	)
)

for /f "tokens=2*" %%a in ('reg query %keyValue% /v ProductName 2^>nul') do (
	set "productName=%%b"
)

for /f "skip=2 tokens=3" %%a in ('reg query %keyValue% /v ProductVersion 2^>nul') do (
	set "productVersion=%%a"
)

for /f "skip=2 tokens=2*" %%a in ('reg query %keyValue% /v InstallDir 2^>nul') do (
	set "productDir=%%b"
)

if "#"=="#%productVersion%" (
	set returnValue=0
) else (
	set returnValue=%productVersion%
)
goto :eof

:exitCode
if "#%guiStatus%"=="#True" (
	echo ��������˳�
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

