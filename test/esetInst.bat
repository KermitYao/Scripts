1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto :begin

::* ϵͳ֧�� win XP| win7 | win8| win10 | win server 2003 | win server 2008 | win server 2012 | win server|2016 |win server 2019
::* ǰ�õ�������� findstr | wmic | msiexec | dism | reg | powershell (�Ǳ���) 
::* 2021-05-25 �ű����
::* 2021-05-27 1.���� -- GUIѡ���������ѡ��������Ӵ�Сд
::* 2021-06-03 1.���� -- �Է�sp1ϵͳ(nt 6.1.7600)�ļ��;2.���� -- ��������
::* 2021-08-24 1.���� -- �ڰ�װServer2008 ϵͳ��ȫ��Ʒʱ�Զ��������ģ�飻2.���� -- �� find �滻Ϊ findstr ���޸�ĳЩ�����,��������⣻ 3.���� -- ��ʹ�ñ��ذ�װ�ļ�ʱ,��������ת���ű�����Ŀ¼,��ִ�к���������
::* 2021-09-24 1.���� -- eset ��װ�¼���ץȡģ��;2.���� -- ǿ���Թ����ģ��;3.���� -- �����ֶ�ѡ��װ�ϰ汾ģ��;4.���� -- �Զ���װʱ,��װ�겹��δ����ʱ,���ڽ��Թ�������װ;5.�޸� -- �Զ���װ6.5ʧ�ܵ�����;6.�޸� -- guiѡ�����ʱ,������ֱ�����ʾ;7.���� -- ������Ϣ
::* 2021-09-29 1.���� -- ���ڵ�AGENTģ�鰲װ�޷��ҵ������ļ�ʱ����ʾ�û��ֶ������������ַ,��������AGENT��װ���������ص��ļ����С�� 4kb ���ʾ���ص��ļ�������,����ͨ�� errorFileSize=4 �������壩
::* 2021-10-16 1.�޸� -- ����������ģʽ����������δ�ҵ������ļ�ʱ,���ڻḲ�ǰ�װ,������ԭ�е�host ��֤����Ϣ, ���Ǻ�guiģʽһ�������û���������
::* 2021-10-29 1.���� -- �޸Ĳ�������,���������
::* 2021-12-21 1.���� -- ���Ӳ�������; 2.���� -- �����ص�ַ����Ϊ files.yjyn.top:6080 ������ie�ں�ϵͳ����ʧ�ܵ�����
::* 2022-01-13 1.���� -- �޸�x86���԰�װagent�޷���ȡ�������ӵ�bug.
::* 2022-03-31 1.���� -- ��ʹ�� status ������ʱ��,���ڻ�����ip��ַ�б�ͼ�������Ƶ���ʾ
::* 2022-04-04 1.���� -- ״̬��Ϣ���ڻ��г�Զ������,�����ж����ӵķ������Ƿ���ȷ; 2.���� -- �Ż���ȡ Agent ��װ������ٶ�, ��������ű�������Ч��
::* 2022-05-26 1.�޸� -- ��ȡ AGENT ��Ϣʱ,�����޷��ҵ�ע��������
::* 2022-10-21 1.���� -- ���ڿ���ͨ��ָ���������Զ����������������ж�س��򣬽���ж����(--avUninst).
::* 2022-10-28 1.�޸� -- ���ӶԽ�ɽ���Ե�ж��; 2.�Ż��ű��������ٶ�
::* v2.0.0_20230111_alpha
	1.���� win7������װ9.x�汾
	2.���� ���ڿ���ʹ�� -v ����ʾ��ǰ�İ汾��; 
	3.���� �ع����ִ���,��װ�ɺ���,ʵ�ֲ�ͬϵͳ�汾��Ӧ��ͬ����������,���Ч��;
	4.���� �ع��汾�ж��޼�,���ڽ����Ӿ�׼
	5.���� ����ֻ�м�⵽ȷʵ��Ҫ��ȡϵͳ��Ϣʱ�Ż������ع��ܣ���߽ű�����Ч��; 
	6.���� ж�ص�����ģ�����ڿ������msiexec��ʽ��װ������ˣ�ͨ�� ������������Ӵ�����ʵ��: {}
	7.�޸� �޸��˼���ûʲôӰ���bug

::* v2.0.0_20230113_beta
	1.�޸� ����֮ǰ��������,���ư汾�ж��޼��������Բ���.

::* v2.0.1_20230208_beta
	1.�޸� Server 2008 ��װ�޷���ȡ��ȫ��Ʒ�������ӵ�����. (��������v10�汾���º�,�����˴�����)

::* v2.0.2_20230308_beta
	1.�޸� ĳЩ�����ʹ��js����ʧ��,����δ���л���powershell���ص����⡣
	2.�޸� ����ʱδ�ܽ����ط�ʽд����־������

::* v2.0.2_20230310_beta
	1.�޸� ������ʧ��ʱ�ȴ�ʱ�����������

::* v2.0.3_20230313_beta
	1.�޸� -r ����ɾ����ʱ�ļ���Ч������
	2.�޸� ж�ص��������ʱ�����ж�·���Ƿ����(�ݶ�)
	3.�޸� ж��msi���ʱ�ȴ�ж�س������
:: -------------���Ż�----------
	1.xp�ڵ��� getVersion agent ʱ����
	�ڴ��д�����:for /f "delims=" %%x in ('reg query %%a /v ProductName 2^>nul ^| findstr /c:"ESET Management Agent"') do (
		xpϵͳ��ȡ�����ݵ�һ�л����� "! reg 3.0" ���´���,���޷�ͨ����׼��������,��δ�ҵ��������.

::-----readme-----

����ʹ��:
	�޸�135�п�ʼ,����ÿ���汾�ļ������ص�ַ,Ȼ��˫���򿪽ű����� a ��ʼ�Զ���װ


����:
	�˽ű�Ŀ��Ϊ���û���װʱ�Ĺ���,��ʵ��һ���Զ�����װ������eset��Ʒ,�Լ������Ѿ���װ�ļ�����Զ�����������,ͬʱ������һЩ�Ŵ��õĵĹ���,���ڰ����ͻ����ٷ������������Դ��

����:
	1.�Զ����ݲ�ͬϵͳ,��ͬϵͳƽ̨,��ͬ����汾,����װ������������AGENT��ɱ����Ʒ
	2.�����ֶ�ѡ����Ҫ��װ��ж�صĲ�Ʒ
	3.������˳���ȫģʽ
	4.��ȡeset��Ʒ��װʱ,д��ϵͳ�¼���־,������ְ�װ����ʱ,��λ����
	5.��ȡϵͳ״̬�����ж�����
	6.���Ը��������Զ��������в������ﵽ˫���ű��Զ���װ��Ŀ��,(ͨ�� DEFAULT_ARGS ����ʵ��)
	7.Ĭ��˫���򿪽ű������һ��ѡ����棨�˽���Ĳ�������һ���Ľ���������
	8.֧�������в���,�Ա�Ԥ������ʱ��Ĭ��װ

ʹ�÷�����
	1.��Ҫ��ǰԤ��ÿ���汾�ļ������ص�ַ���߱��ص��ļ�·��(����ʹ�����·��,�������Էŵ�u���ﰲװ)
		������ͨ�����ذ�װ�����Ǳ����ļ���װ������ͨ��һ���������� absStatus=True 
	2.����ʹ�ò��� -h | -help ���鿴֧�ֵĲ���
	3.�����Ҫʵ��˫���Զ���װ,�������� DEFAULT_ARGS, ����: DEFAULT_ARGS= -a -s -u , ��ʾ�Զ���װ������agent��ɱ����Ʒ,���һ���ʾ����װ��״̬,Ȼ��ͣ���ȴ�
	4.
		set version_Agent=10
		set version_Product_eea=10
		set version_Product_efsw=9.0
		��������������ʶ�����µİ汾,һ��汾�źͰ�װ�ļ��İ汾����һ��.
		��������Ѿ�����һ��ɱ�����,����������ϰ汾����Զ�����,���������������װ,��������û�а�װ��ɱ�������Ԥ��汾��Ϊ0
	5.����������İ�װ��ͨ������ msiexec ʵ�ֵ�,����������Զ����������ͨ���˲���ʵ��: set "params_agent= password=eset1234." ,��ָ��һ������,��ȻҲ�����ñ�Ĳ���,����ָ����װʱ�����ԣ�����д�����������Կո��������
	6. ������� set path_agent_config ָ�����ļ�,������gpo�����ļ�,����ļ���agent��װ�������ͬһ��Ŀ¼,��װ��ʱ��Ϳ��Բ����ֶ���д֤�顢�����֮��Ķ���������ͨ��eset����̨����
	7.�ű���������Ҫ����ԱȨ��
	8.�����в��������ִ�Сд
	9.��װ��ʱ��ű����Զ������Ҫ���صĶ�Ӧ�汾,��������ص�,�������û�� xp ϵͳ,��ȫ���Բ���д 6.5 ���ļ����ص�ַ;����������Ӱ��ʹ��
	10.�뵽����д

:begin
::-----readme-----

cls
@set version=v2.0.2_20230308_beta
@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem �����˲�����������ָ��������guiѡ�񽫻�ʧЧ;
rem �൱��ǿ��ʹ�������в�����
rem �������Ҫ����Ϊ�ռ���
rem ʹ�÷��� �� SET DEFAULT=-o --agent -l --remove -, ��������cmd��������һ��
SET DEFAULT_ARGS=

rem ��־�ȼ� DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

set DEBUG=False
set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem ���������б�
set argsList=argsHelp argsAll argsEarly argsHotfix argsProduct argsAgent argsUndoAgent argsUndoProduct argsEntrySafeMode argsExitSafeMode argsSysStatus argsEsetLog argsForce argsLog argsRemove argsGui argsAvUninst argsVersion
::----------------------------------

rem ----------- init -----------
rem ���ó�ʼ����
:getPackagePatch

rem �Ѱ�װ������汾���С�ڴ˱�������и��ǰ�װ,���򲻽��а�װ(����)
rem �汾��ֻ������λ��������λ����������
set version_Agent=10.0
set version_Product_eea=10.0
set version_Product_efsw=9.0
rem -------------------

rem ���·��ΪUNC��ɷ���·������Ҫ���ص�����,��ֱ�ӵ��ð�װ����������ص���ʱĿ¼��ʹ�þ���·����ʽ����
rem �Ƿ�ΪUNC·������Կɷ��ʵ�·��
rem ���ò���: True|False
set absStatus=False
rem ����ǹ���Ŀ¼���������˺����룬�����Ƚ���ipc$���ӣ�Ȼ����ʹ��UNC·����ʽ���á����Ϊ���򲻽���IPC$���ӡ�
set shareUser=
set sharePwd=


rem ��������������ɱ�����ж�س���,����������ע����ֵ,���������Ӧ�ļ�ֵ,������ж�س���
rem �Լ��ķ�ʽ����, "��Ʒ����:ע����ֵ����"
set avList= "360��ȫ��ʿ:360��ȫ��ʿ" "360ɱ��:360SD" "��Ѷ���Թܼ�:QQPCMgr" "���ް�ȫ���:HuorongSysdiag" "���Ű�ȫ:OfficeScanNT" "��ɽ����:Kingsoft Internet Security" "��������:{Symantec Endpoint Protection}"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem �˴��������������ļ��ĵ�ַ
if %absStatus%==False (
	rem --------agent--------
	rem ���е�·����ҪЯ�� ���� ���ţ��������Զ�������������;ͬʱ "%" �ڽű������������壬�����ַ�ڰ����ո���Ҫ�� "%" ����˫дת��
	rem Agent ���ص�ַ

	rem ��ϵͳר��agent,����ʹ�� v8.0
	set path_agent_old_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x86_v8.0.msi
	set path_agent_old_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x64_v8.0.msi

	rem ���°汾agent,����ʹ�����°汾
	set path_agent_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x86_later.msi
	set path_agent_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x64_later.msi

	rem Agent �����ļ�
	set path_agent_config=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/None

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_agent=password=eset1234.
	set params_agent=
	rem --------agent--------

	rem --------PC product--------
	rem PC Product ���ص�ַ

	rem ��ϵͳר��ɱ�����,����ʹ�� v6.5
	set path_pc_old_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_chs_v6.5.msi
	set path_pc_old_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_chs_v6.5.msi

	rem Win7ϵͳר��ɱ�����,�����v10����ʹ�� v9.1
	set path_pc_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_v9.1.msi
	set path_pc_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_v9.1.msi

	rem ����ʹ�����°汾
	set path_pc_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_later.msi
	set path_pc_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_later.msi
	rem --------PC product--------

	rem --------Server product--------
	rem SERVER Product ���ص�ַ
	rem ��ϵͳר��ɱ�����,����ʹ�� v6.5
	set path_server_old_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_chs_v6.5.msi
	set path_server_old_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_chs_v6.5.msi

	rem Server2008ϵͳר��ɱ�����,�����v10����ʹ�� v9.1
	set path_server_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_v9.1.msi
	set path_server_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_v9.1.msi

	rem ����ʹ�����°汾
	set path_server_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_later.msi
	set path_server_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_later.msi
	rem --------Server product--------

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��,PC �� SERVER �汾����ͬһ��׷�Ӳ���
	::set params_eea=password=eset1234.
	set params_product=

	rem --------patch--------
	rem �����ļ� ���ص�ַ
	set path_hotfix_kb4490628_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4490628-x64.cab

	set path_hotfix_kb4474419_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4474419-v3-x64.cab
	rem --------patch--------

) else (
	pushd "%~dp0"
	rem --------agent--------
	rem ���е�·����ҪЯ�� ���� ���ţ��������Զ�������������;ͬʱ "%" �ڽű������������壬�����ַ�ڰ����ո���Ҫ�� "%" ����˫дת��
	rem Agent �ļ�·��

	rem ����ʹ�� v8.0
	set path_agent_old_x86=CLIENT\Agent\agent_x86_v8.0.msi
	set path_agent_old_x64=CLIENT\Agent\agent_x64_v8.0.msi

	rem ����ʹ�����°汾
	set path_agent_late_x86=CLIENT\Agent\agent_x86_v8.1.msi
	set path_agent_late_x64=CLIENT\Agent\agent_x64_v8.1.msi

	rem Agent �����ļ�
	set path_agent_config=CLIENT\Agent\install_config.ini

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
	::set params_agent=password=eset1234.
	set params_agent=
	rem --------agent--------

	rem --------PC product--------
	rem PC Product �ļ�·��
	rem ����ʹ�� v6.5
	set path_pc_old_x86=PC\eea_nt32_chs_v6.5.msi
	set path_pc_old_x64=PC\eea_nt64_chs_v6.5.msi

	rem Win7ϵͳר��ɱ�����,�����v10����ʹ�� v9.1
	set path_pc_nt61_x86=PC\eea_nt32_v9.1.msi
	set path_pc_nt61_x64=PC\eea_nt64_v9.1.msi

	rem ����ʹ�����°汾
	set path_pc_late_x86=PC\eea_nt32_v8.1.msi
	set path_pc_late_x64=PC\eea_nt64_v8.1.msi
	rem --------PC product--------

	rem --------Server product--------
	rem SERVER Product �ļ�·��
	rem ����ʹ�� v6.5
	set path_server_old_x86=Server\efsw_nt32_chs_v6.5.msi
	set path_server_old_x64=Server\efsw_nt64_chs_v6.5.msi

	rem ����ʹ�����°汾
	set path_server_late_x86=Server\efsw_nt32_v8.0.msi
	set path_server_late_x64=Server\efsw_nt64_v8.0.msi
	rem --------Server product--------

	rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��,PC �� SERVER �汾����ͬһ��׷�Ӳ���
	::set params_eea=password=eset1234.
	set params_product=

	rem --------patch--------
	rem �����ļ�·��
	set path_hotfix_kb4490628_x86=Tools\sha2cab\Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=Tools\sha2cab\Windows6.1-KB4490628-x64.cab

	set path_hotfix_kb4474419_x86=Tools\sha2cab\Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=Tools\sha2cab\Windows6.1-KB4474419-v3-x64.cab
	rem --------patch--------

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

rem �����ļ���ֵ,С�ڶ����ж�Ϊ����ʧ��,  ��λkb
set errorFileSize=4

rem ----------- init -----------

rem ----------- begin start -----------
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
rem ���ϵͳ�� Server 2008 ����Ӳ���,���Զ���װ����ģ��
if "#!sysVersion!"=="#WindowsServer2008" set "params_product=%params_product% ADDLOCAL=ALL"

call :getUac
if "#%argsForce%"=="#True" set uacStatus=True
rem ���밲ȫģʽ
if "#%argsEntrySafeMode%"=="#True" (
	call :writeLog INFO setSafeBoot "��ʼ���ð�ȫģʽ" True True
	if "#!uacStatus!"=="#True" (
		if not !ntVerNumber! lss 61 (
			call :setSafeBoot entry
			if "#!returnValue!"=="#True" (
				call :writeLog INFO entrySafeMode "�Ѿ�����Ϊ��ȫģʽ,�����´�����ʱ���밲ȫģʽ" True True
				set exitCode=0
			) else (
				call :writeLog ERROR entrySafeMode "����Ϊ��ȫģʽʧ��" True True
				set exitCode=9
			)
		) else (
			call :writeLog WARNING entrySafeMode "�˹��ܲ�������,Windows XP �� Windows server 2003 ϵͳ" True True
			set exitCode=2
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
		if not !ntVerNumber! lss 61 (
			call :setSafeBoot exit
			if "#!returnValue!"=="#True" (
				call :writeLog INFO exitSafeMode "�Ѿ�����Ϊ����ģʽ,�����´�����ʱ��������ģʽ" True True
				set exitCode=0
			) else (
				call :writeLog ERROR exitSafeMode "����Ϊ����ģʽʧ��" True True
				set exitCode=10
			)
		) else (
			call :writeLog WARNING exitSafeMode "�˹��ܲ�������,Windows XP �� Windows server 2003 ϵͳ" True True
			set exitCode=2
		)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)	
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
			if "#!msiexecExitCode!"=="#3010" (call :writeLog WARNING uninstallProduct "������ [!productName!] ж��״̬��:[����],����Ҫ���������ж��" True True)
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
		if not "#!ntVerNumber!"=="#61" (
			call :writeLog WARNING installHotfix "��ǰϵͳ�汾���밲װ����,ֻ�� Windows 7 �� Windows server 2008 ����Ҫ��װ�����ļ�" True True
			set exitCode=5
		) else (
			if "#!ntVer!"=="#6.1.7600" (
				call :writeLog WARNING installHotfix "��ǰϵͳ�汾��֧�ִ˰�װ����,����Ҫ��ϵͳ�Ȱ�װ Service Pack 1 [KB976932] ���ܼ�����װ�˲���" True True
				set exitCode=5
				goto :esetSkip
			) else (
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
							if "#!dismExitCode!"=="#3010" (
								call :writeLog WARNING installHotfix "������� [%%a] ��װ״̬��:[����],����Ҫ�������ܽ��к�����װ" True True
								goto :esetSkip
							)
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
		call :formatVersion !returnValue!
		set agentCurrentVersionNoDot=!versionNoDot!
		set agentCurrentVersionDot=!versionDot!

		call :formatVersion !version_Agent!
		set agentInstallVersionNoDot=!versionNoDot!
		set agentInstallVersionDot=!versionDot!

		rem ��ǰ�汾С���Ѱ�װ�汾,��ʼ��װ
		if "#%argsForce%"=="#True" set agentInstallVersionNoDot=0
		if !agentCurrentVersionNoDot! lss !agentInstallVersionNoDot! (
			if "#%absStatus%"=="#True" (
				call :connectShare "!path_agent!" %shareUser% %sharePwd%
				call :writeLog DEBUG connectShare "Agent ��������״̬��: [!returnValue!]" False True 

				call :connectShare "!path_agent_config!" %shareUser% %sharePwd%
				call :writeLog DEBUG connectShare "Agent ���� ��������״̬��: [!returnValue!]" False True 
			) else (
				call :writeLog INFO downloadAgent "��ʼ����Agent: [!path_agent!]" True True
				call :downFile "%~f0" "!path_agent!" "%path_Temp%\agent.msi"
				call :writeLog INFO downloadAgent "[!path_agent!] ����״̬��: [!returnValue!]" True True 
				set path_agent=%path_Temp%\agent.msi

				call :writeLog INFO downloadAgentConfig "��ʼ����Agent config: [!path_agent_config!]" True True
				call :downFile "%~f0" "!path_agent_config!" "%path_Temp%\install_config.ini"
				call :writeLog INFO downloadAgentConfig "!path_agent_config! ����״̬��: [!returnValue!]" True True 
				set path_agent_config=%path_Temp%\install_config.ini
			)
			if not exist "!path_agent!" (
				call :writeLog ERROR installAgent "δ�ҵ���ʹ�õ�·��:[!path_agent!]" True True
			) else (
				set tmp_params_msiexec=%params_msiexec%
				if not exist !path_agent_config! (
					if "#%argsGui%"=="#True" (
						call :writeLog ERROR installAgent "δ�ҵ������ļ� [!path_agent_config!],���ֶ������������Ϣ" True True
						set params_msiexec=/norestart
					)
				)
				call :writeLog INFO installAgent "��ʼ��װAgent: [!path_agent!]" True True
				call :msiInstall "!path_agent!" "!params_msiexec!" "%params_agent%"
				call :writeLog DEBUG installAgent "Agent [!path_agent!] ��װ�˳���:[!errorlevel!]" False True
				call :writeLog INFO installAgent "Agent [!path_agent!] ��װ״̬��:[!returnValue!]" True True
				set params_msiexec=!tmp_params_msiexec!
				if "#!returnValue!"=="#False" (call :writeLog ERROR agentInstall "Agent [!path_agent!] ��װ״̬��:[ʧ��],����ϵͳ��������ϵ����Ա" True True)
				if "#!returnValue!"=="#False" (set exitCode=6) else (set exitCode=0)
			)
		) else (
			call :writeLog INFO installAgent "Agent �汾 [!agentCurrentVersionDot!] С�ڻ���ڵ�ǰ�Ѱ�װ�İ汾,�����ٴΰ�װ" True True
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
		call :getVersion Product
		call :formatVersion !returnValue!
		set productCurrentVersionNoDot=!versionNoDot!
		set productCurrentVersionDot=!versionDot!

		call :formatVersion !version_Product!
		set productInstallVersionNoDot=!versionNoDot!
		set productInstallVersionDot=!versionDot!

		if "#%argsForce%"=="#True" set productInstallVersionNoDot=0
		if !productCurrentVersionNoDot! lss !productInstallVersionNoDot! (
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
				if "#!returnValue!"=="#False" (call :writeLog ERROR installProduct "��ȫ��Ʒ [!path_product!] ��װ״̬��:[ʧ��],����ϵͳ��������ϵ����Ա" True True)
				if "#!returnValue!"=="#False" (set exitCode=11) else (set exitCode=0)
			)
		) else (
			call :writeLog INFO installProduct "��ȫ��Ʒ�汾 [!productInstallVersionDot!] С�ڻ���ڵ�ǰ�Ѱ�װ�İ汾,�����ٴΰ�װ" True True
			set exitCode=0
		)
	) else (
		call :writeLog ERROR uacStatus "�����Ҫ�Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)
)

:esetSkip

rem ɾ�������ص���ʱ�ļ�
if "#%argsRemove%"=="#True" (
	call :writeLog INFO delTempFile "��ʼɾ����ʱ�ļ�" True True
	pushd %path_Temp%
	for %%a in (*.msi *.cab) do (
		del /f /q %%a
	)
	popd
)

rem ץȡESET��װ��־
if "#%argsEsetLog%"=="#True" (
	if not !ntVerNumber! lss 61 (
		call :writeLog INFO prinyEsetLog "��ʼ��ӡ ESET ��װ��־" True True
		powershell -c "& {Get-EventLog Application -Message *ESET* -Newest 6|Format-List timegenerated,message}"
	) else (
		call :writeLog WARNING prinyEsetLog "�˹��ܲ�������,Windows XP �� Windows server 2003 ϵͳ" True True
		set exitCode=2
	)
)

rem ��ӡϵͳ״̬
if "#%argsSysStatus%"=="#True" (
	call :writeLog INFO printSysStatus "��ʼ��ӡϵͳ״̬" True True
	call :getStatus
	set exitCode=0
)

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

rem exitCode: ����:0,��׼�����б���:1,ϵͳ�汾����:2,ϵͳƽ̨����:3,�޷���ȡ������:4,�в�����װʧ�ܻ����:5,��װAgentʧ��:6,ж��agentʧ��:7,ж��productʧ��:8,���밲װģʽʧ��:9,�˳���װģʽʧ��:10,��װproductʧ��:11,Win7ϵͳ����sp1:12��Ȩ�޲������:96,��������:97,�޷���������:98,δ֪����:99
:exitScript

rem ���Ժ���,����debugģʽ�˴����뽫��ִ��
 if %DEBUG%==True (
	call :getDownUrl
	call :debug

	set exitCode=999
 )
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
set valueList=path_agent  path_product hotfix_kb4490628 hotfix_kb4474419
for %%a in (!valueList!) do echo %%a:[!%%a!]

echo ----------URL-----------
echo.
echo --------------- debug ---------------
goto :eof

:getCmdHelp
echo  Usage: %~nx0 [options]
echo\
echo  -h,	--help		[optional] Print the help message
echo  -a,	--all		[optional] Install 'Hotfix ^& Product ^& Agent'
echo  -y,	--early		[optional] Install old version (6.5)
echo  -o,	--hotfix	[optional] Install Hotfix
echo  -g,	--agent		[optional] Install Agent
echo  -p,	--product	[optional] Install Product
echo  -n,	--undoAgent	[optional] Uninstall Agent management
echo  -d,	--undoProduct	[optional] Uninstall Product
echo  -e,	--entrySafeMode	[optional] Entry safe mode
echo  -x,	--exitSafeMode	[optional] Exit safe mode
echo  -t,	--esetlog	[optional] Print ESET install log
echo  -s,	--status	[optional] Check status
echo  -f,	--force		[optional] Skip some checks
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
echo.*	a.�Զ���鰲װ ����+Agent+��ȫ��Ʒ	*
echo.*	y.��װ�ɰ汾 (v6.5)			*
echo.*	o.��װ����				*
echo.*	g.��װ Agent				*
echo.*	p.��װ��ȫ��Ʒ				*
echo.*	n.ж�� Agent				*
echo.*	d.ж�� ��ȫ��Ʒ				*
echo.*	e.���밲ȫģʽ				*
echo.*	x.�˳���ȫģʽ				*
echo.*	t.ץȡESET��װ��־			*
echo.*	s.���״̬				*
echo.*	i.ж���������				*
echo.*	v.��ӡ��ǰ�ű��汾			*
echo.*	h.��ʾ�����а���			*
echo.*	kermit.yao@outlook.com			*
echo.*						*
echo.*************************************************
echo.
echo.
set /p input=��ѡ��:(a^|y^|o^|p^|n^|d^|e^|x^|g^|t^|s^|^i^|v^|h):
for %%a in (a y o p g n d e x t s h i v) do (
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

	if /i "#%%a"=="#-y" (
		set argsEarly=True
		set argsProduct=True
		set argsAgent=True
		)

	if /i "#%%a"=="#--early" (
		set argsEarly=True
		set argsProduct=True
		set argsAgent=True
		)

	if /i "#%%a"=="#-o" set argsHotfix=True
	if /i "#%%a"=="#--hotfix" set argsHotfix=True

	if /i "#%%a"=="#-f" set argsForce=True
	if /i "#%%a"=="#--force" set argsForce=True

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

	if /i "#%%a"=="#-t" set argsEsetLog=True
	if /i "#%%a"=="#--esetlog" set argsEsetLog=True

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

rem ��ȡ��ְ汾��; �������:%1 = ��ְ汾��, %2 = ��ֵĶ��ٽ�;����call :getVersionPrefix "10.1.2"; ����ֵ: versionPrefixDot = ��ְ汾,ǰ�����ڵ�, versionPrefix = ��ְ汾���� 10000
:getVersionPrefix
for /f "delims=. tokens=1-2" %%a in ("%~1") do (
	set versionPrefixDot=%%a.%%b
	set /a dotVersion=%%b*10000
	set versionPrefix=%%a!dotVersion!
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
						call :writeLog INFO avUninst "������%%b��ж�س���: !tempMsg!" True True
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
		call :getDownUrl
	)
)
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



rem ��ȡ��ǰϵͳ������������; �������:���贫�룻����call :getDownUrl ; ����ֵ: ��,��Ӧ����������ֵ: path_product, path_agent, hotfix_kb4490628, hotfix_kb4474419
:getDownUrl

rem ��ȡ��������PC����
if "#!sysType!"=="#Server" (
	set version_Product=%version_Product_efsw%

	set path_product_old_x86=%path_server_old_x86%
	set path_product_old_x64=%path_server_old_x64%

	set path_product_nt61_x86=%path_server_nt61_x86%
	set path_product_nt61_x64=%path_server_nt61_x64%

	set path_product_late_x86=%path_server_late_x86%
	set path_product_late_x64=%path_server_late_x64%
) else (
	set version_Product=%version_Product_eea%
	set path_product_old_x86=%path_pc_old_x86%
	set path_product_old_x64=%path_pc_old_x64%

	set path_product_nt61_x86=%path_pc_nt61_x86%
	set path_product_nt61_x64=%path_pc_nt61_x64%

	set path_product_late_x86=%path_pc_late_x86%
	set path_product_late_x64=%path_pc_late_x64%
)

rem ��ȡ64��32ƽ̨����

if "#!sysArch!"=="#x64" (
		set hotfix_kb4490628=%path_hotfix_kb4490628_x64%
		set hotfix_kb4474419=%path_hotfix_kb4474419_x64%

		set path_agent_old=%path_agent_old_x64%
		set path_agent_late=%path_agent_late_x64%

		set path_product_old=!path_product_old_x64!
		set path_product_nt61=!path_product_nt61_x64!
		set path_product_late=!path_product_late_x64!
) else (
		set hotfix_kb4490628=%path_hotfix_kb4490628_x86%
		set hotfix_kb4474419=%path_hotfix_kb4474419_x86%

		set path_agent_old=%path_agent_old_x86%
		set path_agent_late=%path_agent_late_x86%

		set path_product_old=!path_product_old_x86!
		set path_product_nt61=!path_product_nt61_x86!
		set path_product_late=!path_product_late_x86!
)

rem ����ϵͳ�汾�ж���Ӧ����
if "#%argsEarly%"=="#True" set ntVerNumber=51
if !ntVerNumber! lss 100 (

	set path_agent=!path_agent_late!
	set path_product=!path_product_late!

	if !ntVerNumber! equ 61 (
		set version_Product=9.1
		set path_product=!path_product_nt61!
	)

	if !ntVerNumber! lss 61 (
		set version_Agent=8.0
		set version_Product=6.5
		set path_agent=!path_agent_old!
		set path_product=!path_product_old!
	)
) else (
	set path_agent=!path_agent_late!
	set path_product=!path_product_late!
)

goto :eof

rem ��ʽ���汾,���ں�������;�������: % = �汾�ţ�����call :formatVersion 9.12 ; ����ֵ: ����: versionNoDot,versionDot ������ֵ

:formatVersion
for /f "delims=. tokens=1-2" %%a in ("%~1") do (
	if  not "%%a"=="" (
		set intNum=%%a
		set /a intNumX=intNum * 1000

	)
	if  not "%%b"=="" (
		set decNum=%%b
		set /a decNumX=decNum * 1000
		set decNumX=!decNumX:~,3!
		
	)
	set /a versionNoDot=intNumX+decNumX
	set versionDot=!intNum!.!decNum!
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

echo ���������:!computerName!
echo ϵͳ�汾:!sysVersion!
echo NT�ں˰汾:!ntVer!
echo ϵͳ����:!sysType!
echo IP ��ַ�б�:!ipList!
if not "#!sysVersion!"=="#WindowsXP" (
	call :setSafeBoot status
	echo �Ƿ�����Ϊ��ȫģʽ:!safeModeStatus!
)

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
echo Agent Զ������:%remoteHost%
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
	for /f "delims=" %%a in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products 2^>nul') do (
		for /f "delims=" %%x in ('reg query %%a /v ProductName 2^>nul ^| findstr /c:"ESET Management Agent"') do (
			for /f "delims={} tokens=2" %%y in ('reg query %%a /v ProductIcon 2^>nul') do (
				set "productCode={%%y}"
			)
		)
	)
)

for /f "delims=:< tokens=4" %%a in ('findstr /r /c:"<li>Remote host:.*</li>" "C:\ProgramData\ESET\RemoteAdministrator\Agent\EraAgentApplicationData\Logs\status.html" 2^>nul') do set remoteHost=%%a

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

