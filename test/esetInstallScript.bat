1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::* 2021-05-25 �ű����
::* 2021-05-27 ����ѡ���������ѡ��������Ӵ�Сд
::* 2021-06-03 ���ӶԷ�sp1 ��win7ϵͳ(nt 6.1.7600)�ļ��;���²�������
::* 2021-08-24 �����ڰ�װServer2008 ϵͳ��ȫ��Ʒʱ�Զ��������ģ�飻�� find �滻Ϊ findstr ���޸�ĳЩ�����,��������⣻ ��ʹ�ñ��ذ�װ�ļ�ʱ,��������ת���ű�����Ŀ¼,��ִ�к���������


@rem version 1.1.1
@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem �����˲�����cmdָ��������guiѡ�񽫻�ʧЧ;
rem �൱��ǿ��ʹ�������в�����
rem �������Ҫ����Ϊ�ռ���
rem ʹ�÷��� �� SET DEFAULT=-o --agent -l --remove -, ��������cmd��������һ��
SET DEFAULT_ARGS=

rem ��־�ȼ� DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

set DEBUG=False
set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem ���������б�
set argsList=argsHelp argsAll argsHotfix argsProduct argsAgent argsUndoAgent argsUndoProduct argsEntrySafeMode argsExitSafeMode argsSysStatus argsLog argsRemove argsGui
::----------------------------------

rem ----------- init -----------
rem ���ó�ʼ����
:getPackagePatch

rem �Ѱ�װ�����,С�ڴ˱�������и��ǰ�װ,�汾��ֻ������λ��������λ����������
set version_Agent=8.1
set version_Product_eea=8.1
set version_Product_efsw=8.0
rem -------------------

rem ���·��ΪUNC��ɷ��ʵľ���·������Ҫ���ص�����,��ֱ�ӵ��ð�װ����������ص���ʱĿ¼��ʹ�þ���·����ʽ����
rem �Ƿ�ΪUNC·������� True|False
set absStatus=False
rem ����ǹ���Ŀ¼���������˺����룬�����Ƚ���ipc$���ӣ�Ȼ����ʹ��UNC·����ʽ���á����Ϊ���򲻽���IPC$���ӡ�
set shareUser="kermit"
set sharePwd="5698"

if %absStatus%==False (

	rem ���е�·����ҪЯ�� ���� ���ţ��������Զ�������������;ͬʱ "%" �ڽű������������壬�����ַ�ڰ����ո���Ҫ�� "%" ����ת��
	rem Agent ���ص�ַ
	set path_agent_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Agent/agent_x86_v8.1.msi
	set path_agent_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Agent/agent_x64_v8.1.msi

	rem Agent �����ļ�
	set path_agent_config=http://192.168.30.43:8080/ESET/CLIENT/Agent/install_config.ini

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_agent=password=eset1234.
	set params_agent=

	rem -------------------

	rem PC Product ���ص�ַ
	set path_eea_v6.5_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/PC/eea_nt32_chs_v6.5.msi
	set path_eea_v6.5_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/PC/eea_nt64_chs_6.5.msi

	set path_eea_late_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/PC/eea_nt32_v8.1.msi
	set path_eea_late_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/PC/eea_nt64_v8.1.msi

	rem SERVER Product ���ص�ַ
	set path_efsw_v6.5_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Server/efsw_nt32_chs_v6.5.msi
	set path_efsw_v6.5_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Server/efsw_nt64_chs_v6.5.msi

	set path_efsw_late_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Server/efsw_nt32_v8.0.msi
	set path_efsw_late_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Server/efsw_nt64_v8.0.msi

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_eea=password=eset1234.
	set params_product=
	rem -------------------

	rem �����ļ� ���ص�ַ
	set path_hotfix_kb4490628_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4490628-x64.cab

	set path_hotfix_kb4474419_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4474419-v3-x64.cab

) else (
	pushd "%~dp0"
	rem ���е�·����ҪЯ�� ���� ���ţ��������Զ������������⡣
	rem ��νunc��ַ�������Ϊ�ļ���·���� ���������·�����߾���·����������ʹ�á�
	rem Agent unc��ַ
	set path_agent_x86=CLIENT\Agent\agent_x86_v8.1.msi
	set path_agent_x64=CLIENT\Agent\agent_x64_v8.1.msi

	rem Agent �����ļ�
	set path_agent_config=CLIENT\Agent\install_config.ini

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_agent=password=eset1234.
	set params_agent=

	rem -------------------

	rem PC Product unc��ַ
	set path_eea_v6.5_x86=CLIENT\PC\eea_nt32_chs_v6.5.msi
	set path_eea_v6.5_x64=CLIENT\PC\eea_nt64_chs_v6.5.msi

	set path_eea_late_x86=CLIENT\PC\eea_nt32_v8.1.msi
	set path_eea_late_x64=CLIENT\PC\eea_nt64_v8.1.msi

	rem SERVER Product unc��ַ
	set path_efsw_v6.5_x86=CLIENT\Server\efsw_nt32_chs_v6.5.msi
	set path_efsw_v6.5_x64=CLIENT\Server\efsw_nt64_chs_v6.5.msi

	set path_efsw_late_x86=
	set path_efsw_late_x64=CLIENT\Server\efsw_nt64_v8.0.msi

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_eea=password=eset1234.
	set params_product=
	rem -------------------

	rem �����ļ� unc��ַ
	set path_hotfix_kb4474419_x86=CLIENT\Tools\sha2cab\Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=CLIENT\Tools\sha2cab\Windows6.1-KB4474419-v3-x64.cab
	set path_hotfix_kb4490628_x86=CLIENT\Tools\sha2cab\Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=CLIENT\Tools\sha2cab\Windows6.1-KB4490628-x64.cab
)

rem -------------------

rem ��ʱ�ļ�����־���·��
set path_Temp=%temp%\esetInstall

rem ��װ cab ��Ĭ�ϲ���
set params_hotfix=/norestart

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

rem ���ϵͳ�� Server 2008 ����Ӳ���,���Զ���װ����ģ��
call :getSysVer
if "#!sysVersion!"=="#WindowsServer2008" set "params_product=%params_product% ADDLOCAL=ALL"

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

call :getUac

rem ���밲ȫģʽ
if "#%argsEntrySafeMode%"=="#True" (
	call :writeLog INFO setSafeBoot "��ʼ���ð�ȫģʽ" True True
	if "#!uacStatus!"=="#True" (
		call :getSysVer
		if not "#!sysVersion!"=="#WindowsXP" (
			call :setSafeBoot entry
			if "#!returnValue!"=="#True" (
				call :writeLog INFO entrySafeMode "�Ѿ�����Ϊ��ȫģʽ,�����´�����ʱ���밲ȫģʽ" True True
				set exitCode=0
			) else (
				call :writeLog ERROR entrySafeMode "����Ϊ��ȫģʽʧ��" True True
				set exitCode=9
			)
		) else (
			call :writeLog WARNING entrySafeMode "�˹��ܲ�������,Windows XP ϵͳ" True True
		)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)
)

rem �˳���ȫģʽ
if "#%argsexitSafeMode%"=="#True" (
	call :writeLog INFO exitSafeMode "��ʼ�����ȫģʽ" True True
	if "#!uacStatus!"=="#True" (
		call :getSysVer
		if not "#!sysVersion!"=="#WindowsXP" (
			call :setSafeBoot exit
			if "#!returnValue!"=="#True" (
				call :writeLog INFO exitSafeMode "�Ѿ�����Ϊ����ģʽ,�����´�����ʱ��������ģʽ" True True
				set exitCode=0
			) else (
				call :writeLog ERROR exitSafeMode "����Ϊ����ģʽʧ��" True True
				set exitCode=10
			)
		) else (
			call :writeLog WARNING entrySafeMode "�˹��ܲ�������,Windows XP ϵͳ" True True
		)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)	
)


rem ж�� Agent
if "#%argsUndoAgent%"=="#True" (
	call :writeLog INFO uninstallAgent "��ʼ����Agentж��" True True
	if "#!uacStatus!"=="#True" (
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
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)


rem ж�� Product
if "#%argsUndoProduct%"=="#True" (
	call :writeLog INFO uninstallProduct "��ʼ����ȫ��Ʒж��" True True
	if "#!uacStatus!"=="#True" (
		call :getVersion Product
		if "#!productCode!"=="#" (
			call :writeLog WARNING uninstallProduct "ESET Product δ��װ,����ж��" True True
		) else (
			call :writeLog INFO uninstallProduct "��ʼж�� [!productName!]" True True
			call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
			call :writeLog DEBUG uninstallProduct "[!productName!] ж���˳���:[!errorlevel!]" False True
			call :writeLog INFO uninstallProduct "[!productName!] ж��״̬��:[!returnValue!]" True True
			if "#!msiexecExitCode!"=="#3010" (call :writeLog WARNING uninstallProduct "������ [!productName!] ж��״̬��:[����],����Ҫ�������ܽ��к���ж��" True True)
		)
		if "#!returnValue!"=="#False" (set exitCode=8) else (set exitCode=0)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)

rem ��װ����
if "#%argsHotfix%"=="#True" (
	call :writeLog INFO installHotfix "��ʼ������" True True
	if "#!uacStatus!"=="#True" (
		call :getSysVer
		if not "#!ntVerNumber!"=="#61" (
			call :writeLog WARNING installHotfix "��ǰϵͳ�汾��֧�ְ�װ����" True True
			set exitCode=5
		) else (
			if "#!ntVer!"=="#6.1.7600" (
				call :writeLog WARNING installHotfix "��ǰϵͳ�汾��֧�ִ˰�װ����,����Ҫ��ϵͳ�������� Windowns 7 Service Pack 1 ���ܼ�����װ�˲���" True True
				set exitCode=5
			) else (
				call :getSysArch
				if "#!sysArch%!"=="#x64" (
						set hotfix_kb4490628=%path_hotfix_kb4490628_x64%
						set hotfix_kb4474419=%path_hotfix_kb4474419_x64%
				) else (
						set hotfix_kb4490628=%path_hotfix_kb4490628_x86%
						set hotfix_kb4474419=%path_hotfix_kb4474419_x86%
				)

				call :getHotfixStatus kb4490628 kb4474419
				for %%a in (kb4490628 kb4474419) do (
					if "#!%%a!"=="#True" (
						call :writeLog INFO installHotfix "���� [%%a] �Ѿ�����,�����ظ���װ" True True
						set exitCode=0
					) else (
						if "#%absStatus%"=="#True" (
							call :connectShare "!hotfix_%%a!" %shareUser% %sharePwd%
							call :writeLog DEBUG connectShare "���� %%a ��������״̬�ǣ� [!returnValue!]" False True 
						) else (
							call :writeLog INFO downloadHotfix "��ʼ���ز���: [!hotfix_%%a!]" True True
							call :downFile "%~f0" "!hotfix_%%a!" "%path_Temp%\hotfix_%%a.cab"
							call :writeLog INFO downloadHotfix "���� [[%%a]] ����״̬��: [!returnValue!]" True True 
							set hotfix_%%a="%path_Temp%\hotfix_%%a.cab"
						)
						if not exist "!hotfix_%%a!" (
							call :writeLog ERROR installHotfix "δ�ҵ���ʹ�õ�·��:[!hotfix_%%a!]" True True
						) else (
							call :writeLog INFO installHotfix "��ʼ��װ����: [%%a]" True True
							call :hotFixInstall "!hotfix_%%a!" "%params_hotfix%"
							call :writeLog DEBUG installHotfix "hotfix [%%a] ��װ�˳���:[!errorlevel!]" False True
							call :writeLog INFO installHotfix "������� [%%a] ��װ״̬��:[!returnValue!]" True True
							if "#!dismExitCode!"=="#3010" (call :writeLog WARNING installHotfix "������� [%%a] ��װ״̬��:[����],����Ҫ�������ܽ��к�����װ" True True)
						)
					)
				)
				if "#!returnValue!"=="#False" (set exitCode=5) else (set exitCode=0)
			)
		)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)


rem ��װAgent
if "#%argsAgent%"=="#True" (
	call :writeLog INFO installAgent "��ʼ����Agent��װ" True True
	if "#!uacStatus!"=="#True" (
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
				call :connectShare "!agent!" %shareUser% %sharePwd%
				call :writeLog DEBUG connectShare "Agent ��������״̬��: [!returnValue!]" False True 

				call :connectShare "!agent_config!" %shareUser% %sharePwd%
				call :writeLog DEBUG connectShare "Agent ���� ��������״̬��: [!returnValue!]" False True 
			) else (
				call :writeLog INFO downloadAgent "��ʼ����Agent: [!agent!]" True True
				call :downFile "%~f0" "!agent!" "%path_Temp%\agent.msi"
				call :writeLog INFO downloadAgent "[!agent!] ����״̬��: [!returnValue!]" True True 
				set agent=%path_Temp%\agent.msi

				call :writeLog INFO downloadAgentConfig "��ʼ����Agent config: [install_config.ini]" True True
				call :downFile "%~f0" "!agent_config!" "%path_Temp%\install_config.ini"
				call :writeLog INFO downloadAgentConfig "install_config.ini ����״̬��: [!returnValue!]" True True 
				set agent_config=%path_Temp%\install_config.ini
			)
			if not exist "!agent!" (
				call :writeLog ERROR installAgent "δ�ҵ���ʹ�õ�·��:[!agent!]" True True
			) else (
				if exist !agent_config! (
					call :writeLog INFO installAgent "��ʼ��װAgent: [!agent!]" True True
					call :msiInstall "!agent!" "%params_msiexec%" "%params_agent%"
					call :writeLog DEBUG installAgent "Agent [!agent!] ��װ�˳���:[!errorlevel!]" False True
					call :writeLog INFO installAgent "Agent [!agent!] ��װ״̬��:[!returnValue!]" True True
					if "#!returnValue!"=="#False" (call :writeLog ERROR agentInstall "Agent [!agent!] ��װ״̬��:[ʧ��],����ϵͳ��������ϵ����Ա" True True)
					if "#!returnValue!"=="#False" (set exitCode=6) else (set exitCode=0)
				) else (
					call :writeLog ERROR installAgent "δ�ҵ������ļ� [!agent_config!],���˳����ΰ�װ,��װ״̬��:[ʧ��],����ϵͳ��������ϵ����Ա" True True
					set exitCode=6
				)
			)
		) else (
			call :writeLog INFO installAgent "Agent �汾 [%version_Agent%] С�ڻ���ڵ�ǰ�Ѱ�װ�İ汾,�����ٴΰ�װ" True True
			set exitCode=0
		)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)

rem ��װProduct
if "#%argsProduct%"=="#True" (
	call :writeLog INFO installProduct "��ʼ����ȫ��Ʒ��װ" True True
	if "#!uacStatus!"=="#True" (
		call :getSysVer
		if "#!sysType!"=="#Server" (
			set version_Product=%version_Product_efsw%
			set path_product_v6.5_x86=%path_efsw_v6.5_x86%
			set path_product_v6.5_x64=%path_efsw_v6.5_x64%
			set path_product_late_x86=%path_efsw_late_x86%
			set path_product_late_x64=%path_efsw_late_x64%
		) else (
			set version_Product=%version_Product_eea%
			set path_product_v6.5_x86=%path_eea_v6.5_x86%
			set path_product_v6.5_x64=%path_eea_v6.5_x64%
			set path_product_late_x86=%path_eea_late_x86%
			set path_product_late_x64=%path_eea_late_x64%
		)
		call :getVersion Product
		set returnValue=!returnValue:.=!
		set productCurrentVersion=!returnValue:~,2!
		set productInstallVersion=!version_Product:.=!
		set productInstallVersion=!productInstallVersion:~,2!
		if !productCurrentVersion! lss !productInstallVersion! (
			call :getSysArch
			if "#!sysArch%!"=="#x64" (
				set agent=%path_agent_x64%
				set path_product_v6.5=!path_product_v6.5_x64!
				set path_product_late=!path_product_late_x64!
			) else (
				set path_product_v6.5=!path_product_v6.5_x86!
				set path_product_late=!path_product_late_x86!
			)
			if !ntVerNumber! lss 61 (
				set path_product=!path_product_v6.5!
			) else (
				set path_product=!path_product_late!
			)
			if "#%absStatus%"=="#True" (
				call :connectShare "!path_product!" %shareUser% %sharePwd%
				call :writeLog DEBUG connectShareConnect "Product ��������״̬��: [!returnValue!]" False True 
			) else (
				call :writeLog INFO downloadProduct "��ʼ���ذ�ȫ��Ʒ: [!path_product!]" True True
				call :downFile "%~f0" "!path_product!" "%path_Temp%\product.msi"
				call :writeLog INFO downloadProduct "Product.msi ����״̬��: [!returnValue!]" True True 
				set path_product=%path_Temp%\product.msi
			)
			if not exist "!path_product!" (
				call :writeLog ERROR installProduct "δ�ҵ���ʹ�õ�·��:[!path_product!],��ȫ��Ʒ��װʧ��" True True
				set exitCode=11
			) else (
				call :writeLog INFO installProduct "��ʼ��װ��ȫ��Ʒ: [!path_product!]" True True
				call :msiInstall "!path_product!" "%params_msiexec%" "%params_product%"
				call :writeLog DEBUG installProduct "��ȫ��Ʒ [!path_product!] ��װ�˳���:[!errorlevel!]" False True
				call :writeLog INFO installProduct "��ȫ��Ʒ [!path_product!] ��װ״̬��:[!returnValue!]" True True
				if "#!returnValue!"=="#False" (call :writeLog ERROR installProduct "��ȫ��Ʒ [!path_product!] ��װ״̬��:[ʧ��],�����������ϵ����Ա" True True)
				if "#!returnValue!"=="#False" (set exitCode=11) else (set exitCode=0)
			)
		) else (
			call :writeLog INFO installProduct "��ȫ��Ʒ�汾 [!version_product!] С�ڻ���ڵ�ǰ�Ѱ�װ�İ汾,�����ٴΰ�װ" True True
			set exitCode=0
		)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)


rem ɾ�������ص���ʱ�ļ�
if "#%argsDel%"=="#True" (
	call :writeLog INFO delTempFile "��ʼɾ����ʱ�ļ�" True True
	for %%a in (*.msi *.cab) do (
		del /f /q %%a
	)
)

rem ��ӡϵͳ״̬
if "#%argsSysStatus%"=="#True" (
	call :writeLog INFO printSysStatus "��ʼ��ӡϵͳ״̬" True True
	call :getStatus
	set exitCode=0
)

rem û��ƥ��Ĳ����򱨴�
if not "#%argsStatus%"=="#True" (
	call :writeLog ERROR witeLog "������������δ�ҵ����ʵ�ѡ��" True True
	set exitCode=98
	goto :exitScript
)


rem exitCode: ����:0,��׼�����б���:1,ϵͳ�汾����:2,ϵͳƽ̨����:3,�޷���ȡ������:4,�в�����װʧ�ܻ����:5,��װAgentʧ��:6,ж��agentʧ��:7,ж��productʧ��:8,���밲װģʽʧ��:9,�˳���װģʽʧ��:10,��װproductʧ��:11,Win7ϵͳ����sp1:12��Ȩ�޲������:96,��������:97,�޷���������:98,δ֪����:99
:exitScript
 if %DEBUG%==True call :debug

if "#%argsGui%"=="#True" (
	call :writeLog INFO argsList "argsList:[!args!]" False True
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
	echo %%a:!tmpStatus!
	rem if not "#!tmpStatus!"=="#" echo %%a:!tmpStatus!
)
echo ----------����״̬-----------

echo ----------����״̬-----------
set valueList=args sysType sysArch ntVer ntVerNumber errorlevel exitCode
for %%a in (!valueList!) do echo %%a:[!%%a!]
echo ----------����״̬-----------
echo.
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
	bcdedit|findstr /i /c:"safeboot" >nul && set tmpStatus=True
	if "#!tmpStatus!"=="#True" (
		bcdedit /deletevalue {default} safeboot >nul
	) else (
		bcdedit >nul
	)
)

if "#%~1"=="#status" (
	bcdedit|findstr /i /c:"safeboot" >nul && set safeModeStatus=True
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
echo  -g,	--agent		[optional] Install Agent
echo  -p,	--product	[optional] Install Product
echo  -n	--undoAgent	[optional] Uninstall Agent management
echo  -d	--undoProduct	[optional] Uninstall Product
echo  -e	--entrySafeMode	[optional] Entry safe mode
echo  -x	--exitSafeMode	[optional] Exit safe mode
echo  -s,	--status	[optional] Check status
echo  -l,	--log		[optional] Disable log
echo  -r,	--remove	[optional] Remove downloaded files
echo  -u,	--gui		[optional] Like GUI show
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
echo.*	a.�Զ���鰲װ ����+Agent+��ȫ��Ʒ	*
echo.*						*
echo.*	o.��װ����				*
echo.*						*
echo.*	g.��װ Agent				*
echo.*						*
echo.*	p.��װ��ȫ��Ʒ				*
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

	if /i "#%%a"=="#-r" set argsRemove=True
	if /i "#%%a"=="#--remove" set argsRemove=True

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

rem �ж��Ƿ�װ����; �������: %1-%9 = �����ţ�����call :getHotfixStatus KB4474419 KB4490628 ; ����ֵ:�޷���ֵ������������ҵ���Ӧ�Ĳ����Ŵ�������Ĳ�����ᱻ��ֵΪ True���� KB4474419=True
:getHotfixStatus
set currentHotfixList=

for /f %%a in ('wmic qfe get hotfixid') do set currentHotfixList=!currentHotfixList! %%a
for %%a in (!currentHotfixList!) do (
	for %%x in (%~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9) do (
		if /i "#%%a"=="#%%x" (
			set %%x=True
		)
	)

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
if "#!errorlevel!"=="#3010" set returnValue=True
set msiexecExitCode=!errorlevel!
goto :eof

rem ��װcab�ļ�; �������: %1 = �ļ�·����%2 = ����������call :hotFixInstall "%temp%\ESET_INSTALL\Windows-KB4474419.CAB" "/quiet /norestart" ; ����ֵ: returnValue=True | False
:hotFixInstall
set hotFixInstallStatus=False
set returnValue=False

if "#!argsGui!"=="#True" (
	start /b /wait dism /online /add-package /packagePath:"%~1" %~2
) else (
	start /b /wait dism /online /add-package /packagePath:"%~1" %~2 >>"%path_Temp%\%~nx0.log" 2>&1
)

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
echo ϵͳ����:!sysType!
if not "#!sysVersion!"=="#WindowsXP" (
	call :setSafeBoot status
	echo �Ƿ�����Ϊ��ȫģʽ:!safeModeStatus!
)

call :getSysArch
echo ϵͳƽ̨����:!sysArch!

call :getHotfixStatus KB4474419 KB4490628
echo KB4474419 ������װ״̬:!KB4474419!
echo KB4490628 ������װ״̬:!KB4490628!

call :getVersion Product
echo ��Ʒ��װ����:!productName!
echo ��Ʒ��װ�汾:!productVersion!
echo ��Ʒ��װ·��:!productDir!
echo ��Ʒ��װ����:!productCode!
if not "#!productCode!"=="#" set productInstallStatus=True

call :getVersion Agent
echo Agent ��װ����:!productName!
echo Agent ��װ�汾:!productVersion!
echo Agent ��װ·��:!productDir!
echo Agent ��װ����:!productCode!
if not "#!productCode!"=="#" set agentInstallStatus=True

if "#!productInstallStatus!+!agentInstallStatus!"=="#True+True" (
	echo ***************** ESET NOD32 ɱ�������װ���� *****************
) else (
	echo ***************** ESET NOD32 ɱ�������װ�쳣 *****************
)

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
set shareHost=!tmpValue:~,-1!
for /f "delims=" %%a in ('net use "!shareHost!" !cmd_user_param! "%~3" 2^>nul ^&^& echo statusTrue') do (
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
	call :writeLog witeLog INFO "The file [%~2] was download by "jscript"" False True 
)

if "#!downStatus!"=="#False" (
	if not "#%sysVersion%"=="#WindowsXp" (
		for  /f "delims=" %%a in  ('powershell -Command "& {(New-Object Net.WebClient).DownloadFile('%~2', '%~3');($?)}" 2^>nul') do (
				if "#%%a"=="#True" set downStatus=True
				call :writeLog witeLog INFO "The file [%~2] was download by "powershell"" False True 
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

rem ��ȡ����汾; �������: %1 =Product | Agent ; ����call :getVersion Product; ����ֵ:returnValue=�汾�� | Null,�����Ʒ���������±����ᱻ��ֵ��productCode,productName,productVersion,productDir
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
	for /f "delims={} tokens=2" %%a in ('wmic product list 2^>nul^| findstr /i /c:"ESET Management Agent"') do (
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

