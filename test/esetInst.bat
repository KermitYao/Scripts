1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto :begin

::* ϵͳ֧�� win7 | win8| win10 | win server 2003 | win server 2008 | win server 2012 | win server|2016 |win server 2019
::* ǰ�õ�������� findstr | wmic | msiexec | dism | reg | powershell 
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

::* v2.0.3_20230412_beta
	1.�޸� 2008 �Ѿ��޷�֧�����°汾,ͨ��ָ�� 9.0 �汾�����
	
::* v2.1.0_20240218_alpha
	1.���� ֧��ACS�������Զ��жϺͰ�װ;��sha����������һ��
	2.���� ����֧��ָ����������������Ա����Ȩ����(GUI����Ĭ�Ͽ���,CLI��Ҫ�ֶ�ָ������)
	3.���� �ع����ִ���,���ڿ��Ը���bulidNumber��װ��ͬ������汾,�����ж��߼�,���ٴ�������Ӧ�Ծ����仯�İ汾
	4.���� �Ƴ��˶�xp��6.5�汾��֧��,eset�ٷ��Ѳ��ڶ������֧��
	5.���� ������Դ·�������Զ��ж���http����unc·��,�����ֶ�ָ��(�ж����ַ��Ƿ����http)
	6.�޸� ����Ĭ��ʹ��powershell��������,���������Ƴ�js������֧��

::* v2.1.1_20240220_alpha
	1.�Ż���־���
	2.��������߼�

::* v2.1.2_20240617_beta
	1.�޸�-a����,����δ��װ�������򲹶���������ʱ�����Զ������������ذ�װ������

::* v2.1.3_20240807_beta
	1.���� ���ڲ�����װģ�飬���鲹���İ�װ״̬�Ƿ�ͣ���ڹ����Ա�������Ѱ�װδ�������µ��ظ���װ���⡣
::-----readme-----

����ʹ��:
	�޸�155�п�ʼ,����ÿ���汾�ļ������ص�ַ,Ȼ��˫���򿪽ű����� a ��ʼ�Զ���װ

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
		������ͨ�����ذ�װ�����Ǳ����ļ���װ
	2.����ʹ�ò��� -h | -help ���鿴֧�ֵĲ���
	3.�����Ҫʵ��˫���Զ���װ,�������� DEFAULT_ARGS, ����: DEFAULT_ARGS= -a -s -u , ��ʾ�Զ���װ������agent��ɱ����Ʒ,���һ���ʾ����װ��״̬,Ȼ��ͣ���ȴ�
	4.
		set version_Agent=11
		set version_Product_eea=11
		set version_Product_efsw=11
		��������������ʶ�����µİ汾,һ��汾�źͰ�װ�ļ��İ汾����һ��.
		��������Ѿ�����һ��ɱ�����,����������ϰ汾����Զ�����,���������������װ,��������û�а�װ��ɱ�������Ԥ��汾��Ϊ0
	5.����������İ�װ��ͨ������ msiexec ʵ�ֵ�,����������Զ����������ͨ���˲���ʵ��: set "params_agent= password=eset1234." ,��ָ��һ������,��ȻҲ�����ñ�Ĳ���,����ָ����װʱ�����ԣ�����д�����������Կո��������
	6. ������� set path_agent_config ָ�����ļ�,������gpo�����ļ�,����ļ���agent��װ�������ͬһ��Ŀ¼,��װ��ʱ��Ϳ��Բ����ֶ���д֤�顢�����֮��Ķ���������ͨ��eset����̨����
	7.�ű���������Ҫ����ԱȨ��
	8.�����в��������ִ�Сд
	9.��װ��ʱ��ű����Զ������Ҫ����(%temp%\esetInst)�Ķ�Ӧ�汾,��������ص�,�������û�� xp ϵͳ,��ȫ���Բ���д 6.5 ���ļ����ص�ַ;����������Ӱ��ʹ��
	10.�뵽����д

:begin
::-----readme-----

cls
@set version=v2.1.3_20240807_beta
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
set argsList=argsHelp argsAll argsEarly argsHotfix argsProduct argsAgent argsUndoAgent argsUndoProduct argsEntrySafeMode argsExitSafeMode argsSysStatus argsEsetLog argsForce argsLog argsRemove argsGui argsAvUninst argsVersion argsUac
::----------------------------------

rem ----------- init -----------
rem ���ó�ʼ����
:getPackagePatch

rem �Ѱ�װ������汾���С�ڴ˱�������и��ǰ�װ,���򲻽��а�װ(����)
rem �汾��ֻ������λ��������λ����������
set version_Agent=11.0
set version_Product_eea=11.0
set version_Product_efsw=11.0
rem -------------------

rem ���·��ΪUNC��ɷ���·������Ҫ���ص�����,��ֱ�ӵ��ð�װ����������ص���ʱĿ¼��ʹ�þ���·����ʽ����
rem ����ǹ���Ŀ¼���������˺����룬�����Ƚ���ipc$���ӣ�Ȼ����ʹ��UNC·����ʽ���á����Ϊ���򲻽���IPC$���ӡ�
set shareUser=
set sharePwd=

rem ��������������ɱ�����ж�س���,����������ע����ֵ,���������Ӧ�ļ�ֵ,������ж�س���
rem �Լ��ķ�ʽ����, "��Ʒ����:ע����ֵ����"
set avList= "360��ȫ��ʿ:360��ȫ��ʿ" "360ɱ��:360SD" "��Ѷ���Թܼ�:QQPCMgr" "���ް�ȫ���:HuorongSysdiag" "���Ű�ȫ:OfficeScanNT" "��ɽ����:Kingsoft Internet Security" "��������:{Symantec Endpoint Protection}"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem �˴��������������ļ��ĵ�ַ
rem --------AGENT START--------
rem ���е�·����ҪЯ�� "" ���ţ��������Զ�������������;ͬʱ "%" �ڽű������������壬�����ַ�ڰ����ո���Ҫ�� "%" ����˫дת��
rem Agent ���ص�ַ

rem win7ϵͳר��agent,����ʹ����߰汾�� v10.1292
set path_agent_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x86_v10.1.msi
set path_agent_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x64_v10.1.msi

rem ���°汾agent,����ʹ�����°汾
set path_agent_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x86_later.msi
set path_agent_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x64_later.msi

rem Agent �����ļ�
set path_agent_config=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/None

rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��
::set params_agent=password=eset1234.
set params_agent=
rem --------AGENT END--------

rem --------PC product START--------
rem PC Product ���ص�ַ

rem Win7ϵͳר��ɱ�����,֧����߰汾:v9.1
set path_pc_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_v9.1.msi
set path_pc_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_v9.1.msi

rem ����ʹ�����°汾
set path_pc_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_later.msi
set path_pc_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_later.msi
rem --------PC product END--------

rem --------Server product START--------
rem SERVER Product ���ص�ַ

rem Server2008ϵͳר��ɱ�����,ʹ�� v9.0
set path_server_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_v9.0.msi
set path_server_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_v9.0.msi

rem ����ʹ�����°汾
set path_server_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_later.msi
set path_server_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_later.msi
rem --------Server product END--------

rem ׷�Ӳ���,����Ҫ�򱣳�Ϊ��,PC �� SERVER �汾����ͬһ��׷�Ӳ���
::set params_eea=password=eset1234.
set params_product=

rem --------patch START--------
rem �����ļ� ���ص�ַĿ¼
set path_hotfix_url=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/OTHER/hotfix/

rem --------patch END--------

rem -------------------

rem ��ʱ�ļ�����־���·��
set path_Temp=%temp%\esetInstall

rem ��װ cab ��Ĭ�ϲ���
set params_hotfix=/norestart

rem ��¼��ʼ�����в���
set flagArgs=%*
rem �Ƴ�uac������ӵı�־����
if not "%*"=="" (set noFlagArgs=%flagArgs:-runas=%)
set srcArgs=%noFlagArgs%

if "#%DEFAULT_ARGS%"=="#" (
	set args=%srcArgs%
) else (
	set args=%DEFAULT_ARGS%
)

rem �����ļ���ֵ,С�ڶ����ж�Ϊ����ʧ��,  ��λkb
set errorFileSize=4
rem ��ʼ��ϵͳ�汾,����ղ������µ�if �Աȱ���
set ntVerNumber=0
rem ----------- init -----------

rem ----------- begin start -----------
if not exist %path_Temp% md %path_Temp%

if "#%args%"=="#" (
	call :getAdmin
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

if "%argsUac%"=="True" (
	if not "!isGetAdmin!"=="True" (
		call :getAdmin %*
	)
)

if "#%argsForce%"=="#True" set uacStatus=True
rem ���밲ȫģʽ
if "#%argsEntrySafeMode%"=="#True" (
	call :writeLog INFO setSafeBoot "��ʼ���ð�ȫģʽ" True True
	if "#!uacStatus!"=="#True" (
		if not %ntVerNumber% lss 7600 (
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
		call :writeLog ERROR uacStatus "������Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)
)

rem �˳���ȫģʽ
if "#%argsexitSafeMode%"=="#True" (
	call :writeLog INFO exitSafeMode "��ʼ�����ȫģʽ" True True
	if "#!uacStatus!"=="#True" (
		if not %ntVerNumber% lss 7600 (
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
		call :writeLog ERROR uacStatus "������Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)	
)

rem ж�ص�������ȫ���
if "#%argsAvUninst%"=="#True" (
	call :writeLog INFO removeAV "��ʼ�����������ȫ���ж��" True True
	if "#!uacStatus!"=="#True" (
		call :writeLog DEBUG removeAV "��ʼɨ���������ȫ���..." True True
		call :avUninst
		if "!avUninstFlag!"=="" (
			call :writeLog INFO removeAV "δɨ�赽������ȫ���." True True
		) else (
			call :writeLog INFO removeAV "����е���ж�ش���,���ֶ����ж�س���ѡ�����ж��." True True
			if "#%argsGui%"=="#True" (
				call :writeLog INFO removeAV "�������������һ������." True True
				pause >nul
			) 
		)
	) else (
		call :writeLog ERROR uacStatus "������Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)

rem ж�� Agent
if "#%argsUndoAgent%"=="#True" (
	call :writeLog INFO removeAgent "��ʼ����Agentж��" True True
	if "#!uacStatus!"=="#True" (
		call :getVersion Agent
		if "#!productCode!"=="#" (
			call :writeLog INFO removeAgent "ESET Management Agent δ��װ,����ж��" True True
		) else (
			call :writeLog INFO removeAgent "��ʼж�� [!productName!]" True True
			call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
			call :writeLog DEBUG removeAgent "[!productName!] ж���˳���:[!errorlevel!]" False True
			call :writeLog INFO removeAgent "[!productName!] ж��״̬:[!returnValue!]" True True
			if "#!returnValue!"=="#False" (call :writeLog ERROR removeAgent "[!productName!] ж��״̬:[ʧ��],���鰲װ״̬����ϵ����Ա" True True)
		)
		if "#!returnValue!"=="#False" (set exitCode=7) else (set exitCode=0)
	) else (
		call :writeLog ERROR uacStatus "������Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)

rem ж�� Product
if "#%argsUndoProduct%"=="#True" (
	call :writeLog INFO removeProduct "��ʼ����ȫ��Ʒж��" True True
	if "#!uacStatus!"=="#True" (
		call :getVersion Product
		if "#!productCode!"=="#" (
			call :writeLog WARNING removeProduct "ESET Product δ��װ,����ж��" True True
		) else (
			call :writeLog INFO removeProduct "��ʼж�� [!productName!]" True True
			call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
			call :writeLog DEBUG removeProduct "[!productName!] ж���˳���:[!errorlevel!]" False True
			call :writeLog INFO removeProduct "[!productName!] ж��״̬:[!returnValue!]" True True
			if "#!msiexecExitCode!"=="#3010" (call :writeLog WARNING removeProduct " [!productName!] ж��״̬:[����],����Ҫ���������ж��" True True)
		)
		if "#!returnValue!"=="#False" (set exitCode=8) else (set exitCode=0)
	) else (
		call :writeLog ERROR uacStatus "������Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)		
)

rem ��װ����
if "#%argsHotfix%"=="#True" (
	set hotFixFlag=False
	call :writeLog INFO instHotfix "��ʼ������" True True
	if "#!uacStatus!"=="#True" (
		call :hotfixKey
		if %ntVerNumber% lss 7601 (
			call :writeLog WARNING instHotfix "�汾С��:win7sp1/7601 ���޷���װSHA-2����,��������ϵͳ������" True True
			goto :esetSkip
		)
		if %ntVerNumber% geq 19044 (
			call :writeLog INFO instHotfix "�汾����:21H2/19044 ���谲װACS����" True True
			goto :hotfixSkip 
		)

		for %%a in (!hotfixKey!) do (
			for /f "delims=: tokens=1-3" %%x in ("%%a") do (
				rem echo - %%x - %%y - %%z -
				if "#%%y"=="#full" (
					set keyFlag=True
					call :hotfixInst
				)
				if "#%%y"=="#%ntVerNumber%" (
					set keyFlag=True
					call :hotfixInst "%%~x" "%%~y" "%%~z"
					if "#!dismExitCode!"=="#3010" (
						call :writeLog INFO instHotfix "������װ���,���������Ժ������������." True True
						rem �����Ҫ����,���в�����װʧ��,����������־						
						set hotFixFlag=True
					)
				if "#!returnValue!"=="#False" (
					call :writeLog ERROR instHotfix "������װʧ��,����ϵ����Ա����." True True
					rem �����Ҫ����,���в�����װʧ��,������������־
					set hotFixFlag=True
					)
				)
			)
		)
		if "#!hotFixFlag!"=="#True" (
			rem �����Ҫ����,���в�����װʧ��,������agent��product�İ�װ����
			goto :esetSkip
			)
		if not "!keyFlag!"=="True" (
			call :writeLog WARNING instHotfix "�����������,δ��ƥ�䵱ǰϵͳ�汾,����ϵ�����Ա����" True True
			goto :esetSkip
		)
	) else (
		call :writeLog ERROR uacStatus "������Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
		set exitCode=96
	)
)
:hotfixSkip

rem ��װAgent
if "#%argsAgent%"=="#True" (
	call :writeLog INFO instAgent "��ʼ����Agent��װ" True True
	if not %ntVerNumber% LSS 7601 (
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
				call :getLinkType "!%path_agent%!"
				if not "!linkType!"=="url" (
					call :connectShare "!%path_agent%!" %shareUser% %sharePwd%
					call :writeLog INFO connectShare "Agent ��������״̬��: [!returnValue!]" False True 
					set path_agent=!%path_agent%!
				) else (
					call :writeLog INFO downloadAgent "��ʼ����Agent: [!%path_agent%!]" True True
					call :downFile "%~f0" "!%path_agent%!" "%path_Temp%\agent.msi"
					call :writeLog INFO downloadAgent "[!%path_agent%!] ����״̬��: [!returnValue!]" True True 
					set path_agent=%path_Temp%\agent.msi
				)

				call :getLinkType "!path_agent_config!"
				if not "!linkType!"=="url" (
					call :connectShare "!path_agent_config!" %shareUser% %sharePwd%
					call :writeLog DEBUG connectShare "Agent ���� ��������״̬��: [!returnValue!]" False True
					set path_agent_config=!path_agent_config!
				) else (
					call :writeLog INFO downloadAgentConfig "��ʼ����Agent config: [%path_agent_config%]" True True
					call :downFile "%~f0" "%path_agent_config%" "%path_Temp%\install_config.ini"
					call :writeLog INFO downloadAgentConfig "%path_agent_config% ����״̬��: [!returnValue!]" True True 
					set path_agent_config=%path_Temp%\install_config.ini
				)

				if not exist "!path_agent!" (
					call :writeLog ERROR instAgent "δ�ҵ���ʹ�õ�·��:[!path_agent!]" True True
				) else (
					set tmp_params_msiexec=%params_msiexec%
					if not exist !path_agent_config! (
						if "#%argsGui%"=="#True" (
							call :writeLog ERROR instAgent "δ�ҵ������ļ� [!path_agent_config!],���ֶ������������Ϣ" True True
							set params_msiexec=/norestart
						)
					)
					call :writeLog INFO instAgent "��ʼ��װAgent: [!path_agent!]" True True
					call :msiInstall "!path_agent!" "!params_msiexec!" "%params_agent%"
					call :writeLog DEBUG instAgent "Agent [!path_agent!] ��װ�˳���:[!errorlevel!]" False True
					call :writeLog INFO instAgent "Agent [!path_agent!] ��װ״̬��:[!returnValue!]" True True
					set params_msiexec=!tmp_params_msiexec!
					if "#!returnValue!"=="#False" (call :writeLog ERROR instAgent "Agent [!path_agent!] ��װ״̬��:[ʧ��],����ϵͳ��������ϵ����Ա" True True)
					if "#!returnValue!"=="#False" (set exitCode=6) else (set exitCode=0)
				)
			) else (
				call :writeLog INFO instAgent "Agent �汾 [!agentCurrentVersionDot!] ��������" True True
				set exitCode=0
			)
		) else (
			call :writeLog ERROR uacStatus "������Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
			set exitCode=96
		)
	) else (
		call :writeLog ERROR instAgent "AGENT ����֧�ֵ�ǰϵͳ�汾!" True True
		set exitCode=101
	) 
)

rem ��װProduct
if "#%argsProduct%"=="#True" (
	call :writeLog INFO instProduct "��ʼ����ȫ��Ʒ��װ" True True
	if not %ntVerNumber% LSS 7601 (
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
				call :getLinkType "!%path_product%!"
				if not "!linkType!"=="url" (
					call :connectShare ""!%path_product%!"" %shareUser% %sharePwd%
					call :writeLog DEBUG connectShareConnect "Product ��������״̬��: [!returnValue!]" False True 
				) else (
					call :writeLog INFO downloadProduct "��ʼ���ذ�ȫ��Ʒ: [!%path_product%!]" True True
					call :downFile "%~f0" "!%path_product%!" "%path_Temp%\product.msi"
					call :writeLog INFO downloadProduct "��ȫ��Ʒ����״̬��: [!returnValue!]" True True 
					set path_product=%path_Temp%\product.msi
				)
				if not exist "!path_product!" (
					call :writeLog ERROR instProduct "δ�ҵ���ʹ�õ�·��:[!path_product!],��ȫ��Ʒ��װʧ��" True True
					set exitCode=11
				) else (
					call :writeLog INFO instProduct "��ʼ��װ��ȫ��Ʒ: [!path_product!]" True True
					call :msiInstall "!path_product!" "%params_msiexec%" "%params_product%"
					call :writeLog DEBUG instProduct "��ȫ��Ʒ [!path_product!] ��װ�˳���:[!errorlevel!]" False True
					call :writeLog INFO instProduct "��ȫ��Ʒ [!path_product!] ��װ״̬��:[!returnValue!]" True True
					if "#!returnValue!"=="#False" (call :writeLog ERROR instProduct "��ȫ��Ʒ [!path_product!] ��װ״̬��:[ʧ��],����ϵͳ��������ϵ����Ա" True True)
					if "#!returnValue!"=="#False" (set exitCode=11) else (set exitCode=0)
				)
			) else (
				call :writeLog INFO instProduct "��ȫ��Ʒ�汾 [!productInstallVersionDot!] ��������" True True
				set exitCode=0
			)
		) else (
			call :writeLog ERROR uacStatus "������Թ���Ա������д˽ű�,��������ʹ����Щ����" True True
			set exitCode=96
		)
	) else (
		call :writeLog ERROR instAgent "��ȫ��Ʒ ����֧�ֵ�ǰϵͳ�汾!" True True
		set exitCode=101
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
	if not %ntVerNumber% lss 7600 (
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
	call :getSysInfo
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
call :getDownUrl

set valueList=!path_agent! !path_product! version_Agent version_Product_eea version_Product_efsw
for %%a in (!valueList!) do echo %%a:[!%%a!]

echo ----------URL-----------
echo.
echo --------------- debug ---------------
goto :eof

:getCmdHelp
echo  Usage: %~nx0 [options]
echo\
echo  -h,	--help		[optional] ��ӡ�����а���
echo  -a,	--all		[optional] �Զ���鰲װ ����+Agent+��ȫ��Ʒ
echo  -y,	--early		[optional] ��װ�ɰ汾 (v9.x)	
echo  -o,	--hotfix	[optional] ��װ����
echo  -g,	--agent		[optional] ��װ Agent
echo  -p,	--product	[optional] ��װ��ȫ��Ʒ
echo  -n,	--undoAgent	[optional] ж�� Agent
echo  -d,	--undoProduct	[optional] ж�� ��ȫ��Ʒ	
echo  -e,	--entrySafeMode	[optional] ���밲ȫģʽ
echo  -x,	--exitSafeMode	[optional] �˳���ȫģʽ
echo  -t,	--esetlog	[optional] ץȡESET��װ��־	
echo  -s,	--status	[optional] ״̬���
echo  -f,	--force		[optional] ǿ���Թ����ģ��
echo  -c,	--uac		[optional] �Թ���Ա������нű�
echo  -l,	--log		[optional] �ر���־
echo  -r,	--remove	[optional] �Ƴ���ʱ�ļ�
echo  -i,    --avUninst	[optional] �Ƴ�������ȫ���
echo  -u,	--gui		[optional] �ű�ִ����ɺ�ͣ��
echo  -v,	--version	[optional] ��ӡ��ǰ�ű��汾
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
echo.*	y.��װ�ɰ汾 (v9.x)			*
echo.*	o.��װ����				*
echo.*	g.��װ Agent				*
echo.*	p.��װ��ȫ��Ʒ				*
echo.*	n.ж�� Agent				*
echo.*	d.ж�� ��ȫ��Ʒ				*
echo.*	e.���밲ȫģʽ				*
echo.*	x.�˳���ȫģʽ				*
echo.*	t.ץȡESET��װ��־			*
echo.*	s.״̬���				*
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
		set guiArgsStatus=-%%a -u -c
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

	if /i "#%%a"=="#-c" set argsUac=True
	if /i "#%%a"=="#--uac" set argsUac=True

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
		goto :nextA
	)
)
:nextA

set tmpArgsList_getSysArch=argsAll argsHotfix argsProduct argsAgent argsSysStatus DEBUG
for %%a in (%tmpArgsList_getSysArch%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		call :getSysArch
		goto :nextB
	)
)
:nextB

set tmpArgsList_getDownUrl=argsAll argsHotfix argsProduct argsAgent DEBUG
for %%a in (%tmpArgsList_getDownUrl%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		call :getDownUrl
		goto :nextC
	)
)
:nextC

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

set path_product=
set path_agent=
set path_agent_config=%path_agent_config%

rem ��ȡagent��Դ��ַ
if %ntVerNumber% LSS 7601 (set path_agent=)
if %ntVerNumber% EQU 7601 (
	set path_agent=path_agent_nt61
	set version_Agent=10.1
)

if %ntVerNumber% GTR 7601 (
	if "%argsEarly%"=="True" (
		set path_agent=path_agent_nt61
		set version_Agent=%10.1
	) else (
		set path_agent=path_agent_late
		set version_Agent=%version_Agent%
	)
)
set path_agent=%path_agent%_%sysArch%

rem ��ȡproduct��Դ��ַ
if %ntVerNumber% LSS 7601 (set path_product=)
if %ntVerNumber% EQU 7601 (
	set path_product=path_%sysType%_nt61
	if "!sysType!"=="pc" (set version_Product=9.1)
	if "!sysType!"=="server" (set version_Product=9.0)
)
if %ntVerNumber% GTR 7601 (
	if "%argsEarly%"=="True" (
		set path_product=path_%sysType%_nt61
		if "!sysType!"=="pc" (set version_Product=9.1)
		if "!sysType!"=="server" (set version_Product=9.0)
	) else (
		set path_product=path_%sysType%_late
		if "!sysType!"=="pc" (set version_Product=%version_Product_eea%)
		if "!sysType!"=="server" (set version_Product=%version_Product_efsw%)
	)
)
set path_product=%path_product%_%sysArch%

goto :eof

rem ��ȡ��Դ����, �����������; �������: %1 = ��Դ���ӣ�����call :getLinkType %path_agent_old_x64% ; ����ֵ: url|null
:getLinkType
set tmpLink=%~1
set tmpLink=%tmpLink: =%
for /f "delims=:" %%a in ("%tmpLink%") do (
	if "%%a"=="http" set linkType=url
	if "%%a"=="https" set linkType=url
)
set returnValue = %linkType%
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
set  sysType=pc
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') do (
	for %%x in (%sysVer%) do (
		set tm=%%~x
		echo %%b|findstr /i /c:%%x >nul&&set  sysVersion=!tm: =!
		echo %%b|findstr /i /c:"Server" >nul&&set sysType=server
	)
)

for /f "delims== tokens=2" %%a in ('wmic os get version /value') do set ntVer=%%a
for /f "delims== tokens=2" %%a in ('wmic os get BuildNumber /value') do set ntVerNumber=%%a

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

rem �ж��Ƿ�װ����; �������: �������б� = "������ ������"������call :getHotfixStatus "KB4474419 KB4490628" ; ����ֵ:�޷���ֵ������������ҵ���Ӧ�Ĳ����Ŵ�������Ĳ�����ᱻ��ֵΪ����״̬: InstallPending|Installed|False���� KB4474419=True
:getHotfixStatus
set currentHotfixList=

for %%a in (%~1) do set %%a=False

for /f "delims=_~| tokens=3,7" %%a in ('dism /online /english /format:table /get-packages^|findstr "for_KB[0-9]*.*"') do (
	set tmpHotfixStatus=%%a:%%b
	set tmpHotfixStatus=!tmpHotfixStatus: =!
	set currentHotfixList=!currentHotfixList! !tmpHotfixStatus!
)
for %%a in (!currentHotfixList!) do (
	for %%x in (%~1) do (
		for /f "delims=: tokens=1,2" %%l in ("%%a") do (
			if /i "#%%l"=="#%%x" (
				set %%x=%%m
			)
		)	
	)

)

goto :eof

rem ��ȡϵͳ�汾�Ͳ�����Ӧ��ֵ
:hotfixKey
set hotfixKey=win7sp1/2008r2:7601:kb4490628_kb4474419  #  win8.1/ws2012:9200:kb5001401_kb5006732  #  win8.1/ws2012r2:9600:kb5006729  #  1507:none:none  #  1511:10586:none  #  1607:14393:none  #  1703:15063:none  #  1709:16299:none  #  1803:17134:none  #  1809/ws2019:17763:kb5005112_kb5005625  #  1903:10.0.18362:none  #  1909:18363:kb5004748_kb5005624  #  2004/20H1:19041:kb5005260_kb5005611  #  20H2/2009:19042:kb5005260_kb5005611  #  21H1:19043:kb5005260_kb5005611 # SERVER2022/21H2:20348:kb5005619
set hotfixKey=%hotfixKey: =%
set hotfixKey=%hotfixKey:#= %

::win7sp1/2008r2:7601:kb4490628_kb4474419_kb4575903_kb4570673_kb5006728 
goto :eof

rem ������װ����
:hotfixInst
call :writeLog INFO instHotfix "��ʼ��������װ����..." True True
set hotfixList=%~3
set hotfixList=%hotfixList:_= %
call :writeLog INFO instHotfix "ϵͳ����: %~1, bulidNumber:%~2, ������װ�б�: %hotfixList%" True True
if "#%hotfixList%"=="#none" (
    call :writeLog WARNING instHotfix "δ��ȡ����Ҫ��װ�Ĳ����б�,�ݲ�֧�ִ�ϵͳ,�������������߰汾" True True
    set returnValue=False
    goto :eof
)
call :writeLog INFO instHotfix "����ɨ��ϵͳ����..." True True

call :getHotfixStatus "%hotfixList%"

for %%a in (%hotfixList%) do (
    if "#!%%a!"=="#Installed" (
        call :writeLog INFO instHotfix "���� [%%a] �Ѿ�����,�����ظ���װ" True True
        set exitCode=0
		)

    if "#!%%a!"=="#InstallPending" (
        call :writeLog INFO instHotfix "���� [%%a] �Ѱ�װ,������[����]״̬,���������Ժ�������е�ǰ�ű�." True True
		set hotFixFlag=True
		set returnValue=True
        set exitCode=0
		)

    if "#!%%a!"=="#False" (
		call :getLinkType "%path_hotfix_url%"
		if not "!linkType!"=="url" (
			call :connectShare "%path_hotfix_url%" %shareUser% %sharePwd%
			call :writeLog DEBUG connectShare "���� %%a ��������״̬�ǣ� [!returnValue!]" False True 
			set hotfix_%%a="%path_hotfix_url%hotfix_%%a_%sysArch%.cab"
		) else (
			call :writeLog INFO downloadHotfix "��ʼ���ز���: [%%a]" True True
			call :downFile "%~f0" "%path_hotfix_url%hotfix_%%a_%sysArch%.cab" "%path_Temp%\hotfix_%%a_%sysArch%.cab"
			call :writeLog INFO downloadHotfix "���� [[%%a]] ����״̬��: [!returnValue!]" True True 
			set hotfix_%%a="%path_Temp%\hotfix_%%a_%sysArch%.cab"
		)

        if not exist "!hotfix_%%a!" (
            call :writeLog ERROR instHotfix "δ�ҵ���ʹ�õ�·��:[!hotfix_%%a!],��ֹ��װ" True True
            set returnValue=False
            goto :eof
        ) else (
            call :writeLog INFO instHotfix "��ʼ��װ����: [%%a]" True True
            call :hotFixInstall "!hotfix_%%a!" "%params_hotfix%"
            call :writeLog DEBUG instHotfix "hotfix [%%a] ��װ�˳���:[!errorlevel!]" False True
            call :writeLog INFO instHotfix "������� [%%a] ��װ״̬��:[!returnValue!]" True True
            if "#!dismExitCode!"=="#3010" (
                call :writeLog WARNING instHotfix "������� [%%a] ��װ״̬��:[����],����Ҫ�������ܽ��к�����װ" True True
		set returnValue=True
                goto :eof
            )
        )
    )
)

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

echo ����״̬�б�:

call :hotfixKey
set keyFlag=False
for %%a in (!hotfixKey!) do (
	for /f "delims=: tokens=1-3" %%x in ("%%a") do (
		if "#%%y"=="#%ntVerNumber%" (
			set keyFlag=True
			set hotfixList=%%~z
		)
	)
)

if not "!keyFlag!"=="True" (
	echo   ��ǰϵͳ�޲�����Ҫ��װ���ݲ�֧��
) else (
	if "#!hotfixList!"=="#none" (
    	echo   �ݲ�֧�ִ�ϵͳ,�������������߰汾
	) else (
		set hotfixList=!hotfixList:_= !
		call :getHotfixStatus "!hotfixList!"
		for %%a in (!hotfixList!) do (
			if "#!%%a!"=="#Installed" (
			    echo   %%a �Ѱ�װ
			)
			if "#!%%a!"=="#InstallPending" (
			    echo   %%a �ѹ���^(������^)
			)
			if "#!%%a!"=="#False" (
			    echo   %%a δ��װ
			)
		)
	)
)

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
if "#!downStatus!"=="#False" (
	for  /f %%a in  ('cscript /nologo /e:jscript "%~f1" /downUrl:%~2 /savePath:%3') do (
		call :writeLog INFO fileDownload "The file [%~2] was download by jscript" False True
		if "#%%a"=="#True" (
			call :checkFileSize "%~3"
			if "#!returnValue!"=="#True" (
				set downStatus=True
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
set uacStatus=True
set returnValue=
Net session >nul 2>&1 ||set uacStatus=False

if "#"=="#!uacStatus!" (
	set returnValue=Null
) else (
	set returnValue=!uacStatus!
)
goto :eof

:getAdmin
call :getUac
if not "!uacStatus!"=="True" (
	rem �ж��Ƿ��Ѵ���Ȩ������
	set isGetAdmin=True
	for %%a in (%*) do set runasflag=%%a
	if not "!runasflag!"=="-runas" (
		call :writeLog INFO getAdmin "�������ԱȨ��" True True
		call :runAsAdmin %*
		if "!runAsAdminFlag!"=="True" (
			call :writeLog DEBUG getAdmin "Ȩ�޻�ȡ�ɹ�" True True
			exit
		) else (
			call :writeLog WARNING getAdmin "����Ȩ��ʧ��,������ͨȨ������." True True
			call :getUac
		)
	)
)
goto :eof

rem ʹ�ù���Ա������е�ǰ�ű�,���Դ��ݲ���,���������ܰ���"˫���ţ������ʹ��runas�������ʹ��˫���� ['a b c  "a b c"'];����ֵ: returnValue=True|False
rem ���õ�ʱ����Ҫ����%*,�������в������ݸ�����
:runAsAdmin
set runAsAdminFlag=False
if %uacStatus%==True (goto :eof)
for %%a in (%*) do set flag=%%a
if "%flag%"=="-runas" (
	goto :eof
) else (
	echo Start-Process  -FilePath %~fs0 -ArgumentList '%* -runas' -verb  runas | powershell - >nul&&set runAsAdminFlag=True
)
:goto eof

rem д����־; �������: %1 = ��Ϣ���ͣ� %2 = ����, %3 = ��Ϣ�ı��� %4 = True д���׼��� | False��%5 = True д����־�ļ� | False; ����call :writeLog witeLog ERROR "This is a error message." True False; ����ֵ:�޷���ֵ
:writeLog

if "%logLevel%"=="DEBUG" (set logLevelList=DEBUG INFO WARNING ERROR)
if "%logLevel%"=="INFO" (set logLevelList=INFO WARNING ERROR)
if "%logLevel%"=="WARNING" (set logLevelList=WARNING ERROR)
if "%logLevel%"=="ERROR" (set logLevelList=ERROR)
call :getFormatTime
for %%a in (%logLevelList%) do (
	if "%%a"=="%~1" (
		if "%4"=="True" (
			echo.*!dt! - %1 - %2 - %3
		)
		
		if "%5"=="True" (
			(
			echo.*!dt! - %1 - %2 - %3
			)>>"%path_Temp%\%~nx0.log"
		)
	)
)

goto :eof

rem ��ȡ��ʽ��ʱ�� YYYY/MM/DD HH:MM, ���贫����������ú� dt�ᱻ��ֵ
:getFormatTime
set formatTime=
for /f "delims==. tokens=2" %%a in ('wmic os get localdatetime /value')  do set dt=%%a
set dt=!dt:~0,4!/!dt:~4,2!/!dt:~6,2! !dt:~8,2!:!dt:~12,2!
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

