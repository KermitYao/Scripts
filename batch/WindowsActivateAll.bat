@echo off
setlocal enabledelayedexpansion


rem --------user value-----------------

set kmsServer=yjyn.top

rem --------user value-----------------

rem --------init value-----------------
set systemActivateOption=False
set officeActivateOption=False
set keyOption=False
set pathOption=False
set keyValue=False
set pathValue=False
set kmsValue=False
set helpValue=False
rem --------init value-----------------

if "#%*"=="#" (
	call :getGuiHelp
) else (
	call :getArgs %*
)
echo.systemActivateOption=!systemActivateOption!
echo.officeActivateOption=!officeActivateOption!
echo.keyOption=!keyOption!
echo.pathOption=!pathOption!
echo.keyValue=!keyValue!
echo.pathValue=!pathValue!
echo.kmsValue=!kmsValue!
echo.helpValue=!helpValue!

exit /b 0

set /p input=(a^|b):
if "%input%"=="a" call :WinSys
if "%input%"=="b" call :WinOffice
pause
exit /b 0
:WinSys
slmgr.vbs /upk
slmgr.vbs /skms %DDNS%
slmgr.vbs /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
slmgr.vbs /ato
slmgr.vbs /xpr
goto :eof



rem 获取UAC状态;return=Null|False|True
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

:getCmdHelp
echo  Usage: %~nx0 [options]
echo\
echo  -h, --help		[optional] Print this help message
echo  -s, --system		[optional] Activate the system of windows
echo  -o, --office		[optional] Activate the office of windows
echo  -k, --key		[optional] Specify a key
echo  -p, --path		[optional] Specify an office path
echo  -kms		[optional] Specify server of kms
echo.
echo		Example:%~nx0 -s -k XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
echo		Example:%~nx0 --office --path "C:\Program Files\Microsoft Office\Office14" --key  XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
echo\
echo              Code by Windows, 2020-03-19 ,kermit.yao@outlook.com
goto :eof


rem 获取 gui 界面,返回;return=Null|True
:getGuiHelp
set getGuiStatus=
echo.
echo.
echo.#################################
echo.#				#
echo.#	s.自动激活Windows系列	#
echo.#				#
echo.#	o.自动激活Office系列	#
echo.#				#
echo.#	h.显示命令行参数	#
echo.#				#
echo.#	kermit.yao@outlook.com	#
echo.#				#
echo.#################################
echo.
echo.
set /p input=请选择:(s^|o^|h):

for %%a in (s o h) do (
	if "#!input!"=="#%%a" (
		call :getArgs -!input!
		set guiStatus=True
	)
)

if "#!guiStatus!"=="#True" (
	set returnValue=!getGuiStatus!
) else (
	call :getErrorMsg "选择错误:[!input!]" ERROR
	goto getGuiHelp
)
goto :eof

rem 显示错误消息,可传入参数 %1 = message
:getErrorMsg
cls
echo ****************%2********************
echo.*%~1
echo ****************%2********************
goto :eof

rem 解析传入参数
:getArgs
echo %*
:loop
if "%1" == "" goto :getArgsBreak
if "%1" == "-h" (
	set helpValue=True
	call :getCmdHelp
) else (
	if "%1" == "--help" (
		set helpValue=True
		call :getCmdHelp
	)
)

if "%1" == "-s" (
	set systemActivateOption=True
) else (
	if "%1" == "--system" (
		set systemActivateOption=True
	)
)

if "%1" == "-o" (
	set officeActivateOption=True
) else (
	if "%1" == "--office" (
		set officeActivateOption=True
	)
)

if "%1" == "-k" (
	shift
	set keyValue=%1
) else (
	if "%1" == "--key" (
		shift
		set keyValue=%1
	)
)

if "%1" == "-p" (
	shift
	set pathValue=%1
) else (
	if "%1" == "--path" (
		shift
		set pathValue=%1
	)
)

if "%1" == "-kms" (
	shift
	set kmsValue=%1
) 

shift
goto :loop
:getArgsBreak
goto :eof


rem 获取office安装路径;return=Null|officePath
:getOfficePath
set drive=c d e f g h i j k l m n o p q r s t u v w x y z
set officePath=
for %%a in (%drive%) do (
	if exist %%a:\ (
		for /d %%l in ("%%a:\Program Files*") do (
			for /f "delims=" %%x in ('dir /a-d/b/s  "%%l\OSPP.VBS"2^>nul') do (
				if exist "%%x" (
					set officePath=%%x
					goto :getOfficePathBreak
				)
			)
		)
	)
)
:getOfficePathBreak
if "#"=="#!officePath!" (
	set returnValue=Null
) else (
	set returnValue=!officePath!
)

goto :eof

:getGvlk
goto :eof

rem  获取网络状态;可传入主机地址:[host];%1 = host|www.baidu.com, return = True|False
:getNetStatus
set returnValue=
set netStatus=
ping -n 1 %1 >nul
if !errorlevel! equ 0 (
	set netStatus=True
) else (
	set netStatus=False
)
set returnValue=!netStatus!

goto:eof


rem  获取系统版本,系统版本被转换成一个带有通配符的字符串;return = Null|SysVersion
:getSysVer
set returnValue=
set sysVersion=
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName') do (
	set tmp=%%b
	if "#Windows"=="#!tmp:~0,7!" (
		for %%x in (%%b) do (
			set sysVersion=!sysVersion!%%x.*
		)
	)
)
set tmp=
if "#"=="#!sysVersion!" (
	set returnValue=Null
) else (
	set returnValue=!sysVersion!
)
goto :eof

rem 获取激活到期时间
:getActivateEnd
set returnValue=
for /f "skip=1 delims=" %%a in ('cscript //nologo %windir%\system32\slmgr.vbs -xpr') do set activateEnd=%%a
if "#"=="#!keyList!" (
	set returnValue=Null
) else (
	set returnValue=!activateEnd!
)
goto :eof

:setActivation
goto :eof

rem 清楚kms信息=卸载
:setReset
set returnValue=
slmgr.vbs -ckms
slmgr.vbs -rearm
set returnValue=Null
goto :eof

rem 获取各个版本的key;获得的key被转换成一个列表形式,[keyList];%1 = sysVer, return = keyList
:getSysKey
set sysVer=%1
set keyList=
set returnValue=
for /f " tokens=1* delims=#" %%a in ('findstr /i "^%sysVer%" %~fs0') do (
	set keyList=!keyList! %%b
)
if "#"=="#!keyList!" (
	set keyList=Null
) else (
	set returnValue=!keyList!
)
goto :eof

rem ---------------------------Windows 系统激活序列号-------------------------------
:getWindowsKey
findstr /i "^Windows" %~fs0
goto :eof

操作系统	#	KMS激活序列号
Windows10Home	#	TX9XD-98N7V-6WMQ6-BX7FG-H8Q99
Windows10HomeN	#	3KHY7-WNT83-DGQKR-F7HPR-844BM
Windows10HomeSingleLanguage	#	7HNRX-D7KGG-3K4RQ-4WPJ4-YTDFH
Windows10HomeCountrySpecific	#	PVMJN-6DFY6-9CCP6-7BKTT-D3WVR
Windows10Professional	#	W269N-WFGWX-YVC9B-4J6C9-T83GX
Windows10ProfessionalN	#	MH37W-N47XK-V7XM9-C7227-GCQG9
Windows10ProfessionalEducation	#	6TP4R-GNPTD-KYYHQ-7B7DP-J447Y
Windows10ProfessionalEducationN	#	YVWGF-BXNMC-HTQYQ-CPQ99-66QFC
Windows10ProfessionalWorkstation	#	NRG8B-VKK3Q-CXVCJ-9G2XF-6Q84J
Windows10ProfessionalWorkstationN	#	9FNHH-K3HBT-3W4TD-6383H-6XYWF
Windows10Education	#	NW6C2-QMPVW-D7KKK-3GKT6-VCFB2
Windows10EducationN	#	2WH4N-8QGBV-H22JP-CT43Q-MDWWJ
Windows10Enterprise	#	NPPR9-FWDCX-D2C8J-H872K-2YT43
Windows10EnterpriseN	#	DPH2V-TTNVB-4X9Q3-TJR4H-KHJW4
Windows10EnterpriseG	#	YYVX9-NTFWV-6MDM3-9PT4T-4M68B
Windows10EnterpriseGN	#	44RPN-FTY23-9VTTB-MP9BX-T84FV
Windows10Enterprise2015LTSB	#	WNMTR-4C88C-JK8YV-HQ7T2-76DF9
Windows10Enterprise2015LTSBN	#	2F77B-TNFGY-69QQF-B8YKP-D69TJ
Windows10Enterprise2016LTSB	#	DCPHK-NFMTC-H88MJ-PFHPY-QJ4BJ
Windows10Enterprise2016LTSBN	#	QFFDN-GRT3P-VKWWX-X7T3R-8B639
Windows10EnterpriseLTSC2018	#	M7XTQ-FN8P6-TTKYV-9D4CC-J462D
Windows10EnterpriseLTSC2018N	#	92NFX-8DJQP-P6BBQ-THF9C-7CG2H
Windows10EnterpriseRemoteServer	#	7NBT4-WGBQX-MP4H7-QXFF8-YP3KX
Windows10EnterpriseforRemoteSessions	#	CPWHC-NT2C7-VYW78-DHDB2-PG3GK
Windows10Lean	#	NBTWJ-3DR69-3C4V8-C26MC-GQ9M6
	#	
WindowsServer2019	#	
	#	
操作系统	#	KMS激活序列号
WindowsServer2019Essentials	#	WVDHN-86M7X-466P6-VHXV7-YY726
WindowsServer2019Standard	#	N69G4-B89J2-4G8F4-WWYCC-J464C
WindowsServer2019Datacenter	#	WMDGN-G9PQG-XVVXX-R3X43-63DFG
WindowsServer2019StandardACor	#	N2KJX-J94YW-TQVFB-DG9YT-724CC
WindowsServer2019DatacenterACor	#	6NMRW-2C8FM-D24W7-TQWMY-CWH2D
WindowsServer2019AzureCore	#	FDNH6-VW9RW-BXPJ7-4XTYG-239TB
WindowsServer2019ARM64	#	GRFBW-QNDC4-6QBHG-CCK3B-2PR88
	#	
WindowsServer2016	#	
	#	
操作系统	#	KMS激活序列号
WindowsServer2016Datacenter	#	CB7KF-BWN84-R7R2Y-793K2-8XDDG
WindowsServer2016Standard	#	WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY
WindowsServer2016Essentials	#	JCKRF-N37P4-C2D82-9YXRT-4M63B
WindowsServer2016StandardACor	#	PTXN8-JFHJM-4WC78-MPCBR-9W4KR
WindowsServer2016DatacenterACor	#	2HXDN-KRXHB-GPYC7-YCKFJ-7FVDG
WindowsServer2016CloudStorage	#	QN4C6-GBJD2-FB422-GHWJK-GJG2R
WindowsServer2016AzureCore	#	VP34G-4NPPG-79JTQ-864T4-R3MQX
WindowsServer2016ARM64	#	K9FYF-G6NCK-73M32-XMVPY-F9DRR
	#	
Windows8.1	#	
	#	
操作系统	#	KMS激活序列号
Windows8.1Professional	#	GCRJD-8NW9H-F2CDX-CCM8D-9D6T9
Windows8.1ProfessionalN	#	HMCNV-VVBFX-7HMBH-CTY9B-B4FXY
Windows8.1Enterprise	#	MHF9N-XY6XB-WVXMC-BTDCT-MKKG7
Windows8.1EnterpriseN	#	TT4HM-HN7YT-62K67-RGRQJ-JFFXW
Windows8.1ProfessionalWMC	#	789NJ-TQK6T-6XTH8-J39CJ-J8D3P
Windows8.1Core	#	M9Q9P-WNJJT-6PXPY-DWX8H-6XWKK
Windows8.1CoreN	#	7B9N3-D94CG-YTVHR-QBPX3-RJP64
Windows8.1CoreARM	#	XYTND-K6QKT-K2MRH-66RTM-43JKP
Windows8.1CoreSingleLanguage	#	BB6NG-PQ82V-VRDPW-8XVD2-V8P66
Windows8.1CoreCountrySpecific	#	NCTT7-2RGK8-WMHRF-RY7YQ-JTXG3
Windows8.1EmbeddedIndustry	#	NMMPB-38DD4-R2823-62W8D-VXKJB
Windows8.1EmbeddedIndustryEnterprise	#	FNFKF-PWTVT-9RC8H-32HB2-JB34X
Windows8.1EmbeddedIndustryAutomotive	#	VHXM3-NR6FT-RY6RT-CK882-KW2CJ
Windows8.1CoreConnected(withBing)	#	3PY8R-QHNP9-W7XQD-G6DPH-3J2C9
Windows8.1CoreConnectedN(withBing)	#	Q6HTR-N24GM-PMJFP-69CD8-2GXKR
Windows8.1CoreConnectedSingleLanguage(withBing)	#	KF37N-VDV38-GRRTV-XH8X6-6F3BB
Windows8.1CoreConnectedCountrySpecific(withBing)	#	R962J-37N87-9VVK2-WJ74P-XTMHR
Windows8.1ProfessionalStudent	#	MX3RK-9HNGX-K3QKC-6PJ3F-W8D7B
Windows8.1ProfessionalStudentN	#	TNFGH-2R6PB-8XM3K-QYHX2-J4296
	#	
WindowsServer2012R2	#	
	#	
操作系统	#	KMS激活序列号
WindowsServer2012R2Standard	#	D2N9P-3P6X9-2R39C-7RTCD-MDVJX
WindowsServer2012R2Datacenter	#	W3GGN-FT8W3-Y4M27-J84CP-Q3VJ9
WindowsServer2012R2Essentials	#	KNC87-3J2TX-XB4WP-VCPJV-M4FWM
WindowsServer2012R2CloudStorage	#	3NPTF-33KPT-GGBPR-YX76B-39KDD
	#	
Windows8	#	
	#	
操作系统	#	KMS激活序列号
Windows8Professional	#	NG4HW-VH26C-733KW-K6F98-J8CK4
Windows8ProfessionalN	#	XCVCF-2NXM9-723PB-MHCB7-2RYQQ
Windows8Enterprise	#	32JNW-9KQ84-P47T8-D8GGY-CWCK7
Windows8EnterpriseN	#	JMNMF-RHW7P-DMY6X-RF3DR-X2BQT
Windows8ProfessionalWMC	#	GNBB8-YVD74-QJHX6-27H4K-8QHDG
Windows8Core	#	BN3D2-R7TKB-3YPBD-8DRP2-27GG4
Windows8CoreN	#	8N2M2-HWPGY-7PGT9-HGDD8-GVGGY
Windows8CoreSingleLanguage	#	2WN2H-YGCQR-KFX6K-CD6TF-84YXQ
Windows8CoreCountrySpecific	#	4K36P-JN4VD-GDC6V-KDT89-DYFKP
Windows8CoreARM	#	DXHJF-N9KQX-MFPVR-GHGQK-Y7RKV
Windows8EmbeddedIndustryProfessional	#	RYXVT-BNQG7-VD29F-DBMRY-HT73M
Windows8EmbeddedIndustryEnterprise	#	NKB3R-R2F8T-3XCDP-7Q2KW-XWYQ2
	#	
WindowsServer2012	#	
	#	
操作系统	#	KMS激活序列号
WindowsServer2012Standard	#	XC9B7-NBPP2-83J2H-RHMBY-92BT4
WindowsServer2012Datacenter	#	48HP8-DN98B-MYWDG-T2DCC-8W83P
WindowsServer2012MultiPointStandard	#	HM7DN-YVMH3-46JC3-XYTG7-CYQJJ
WindowsServer2012MultiPointPremium	#	XNH6W-2V9GX-RGJ4K-Y8X6F-QGJ2G
	#	
Windows7	#	
	#	
操作系统	#	KMS激活序列号
Windows7Professional	#	FJ82H-XT6CR-J8D7P-XQJJ2-GPDD4
Windows7ProfessionalN	#	MRPKT-YTG23-K7D7T-X2JMM-QY7MG
Windows7ProfessionalE	#	W82YF-2Q76Y-63HXB-FGJG9-GF7QX
Windows7Enterprise	#	33PXH-7Y6KF-2VJC9-XBBR8-HVTHH
Windows7EnterpriseN	#	YDRBP-3D83W-TY26F-D46B2-XCKRJ
Windows7EnterpriseE	#	C29WB-22CC8-VJ326-GHFJW-H9DH4
Windows7EmbeddedPOSReady	#	YBYF6-BHCR3-JPKRB-CDW7B-F9BK4
Windows7EmbeddedThinPC	#	73KQT-CD9G6-K7TQG-66MRP-CQ22C
Windows7EmbeddedStandard	#	XGY72-BRBBT-FF8MH-2GG8H-W7KCW
			#	KH2J9-PC326-T44D4-39H6V-TVPBY 
	#	
WindowsServer2008R2	#	
	#	
操作系统	#	KMS激活序列号
WindowsServer2008R2Web	#	6TPJF-RBVHG-WBW2R-86QPH-6RTM4
WindowsServer2008R2HPCedition	#	TT8MH-CG224-D3D7Q-498W2-9QCTX
WindowsServer2008R2Standard	#	YC6KT-GKW9T-YTKYR-T4X34-R7VHC
WindowsServer2008R2Enterprise	#	489J6-VHDMP-X63PK-3K798-CPX3Y
WindowsServer2008R2Datacenter	#	74YFP-3QFB3-KQT8W-PMXWJ-7M648
WindowsServer2008R2forItanium-basedSystems	#	GT63C-RJFQ3-4GMB6-BRFB9-CB83V
WindowsMultiPointServer2010	#	736RG-XDKJK-V34PF-BHK87-J6X3K
	#	
WindowsVista	#	
	#	
操作系统	#	KMS激活序列号
WindowsVistaBusiness	#	YFKBB-PQJJV-G996G-VWGXY-2V3X8
WindowsVistaBusinessN	#	HMBQG-8H2RH-C77VX-27R82-VMQBT
WindowsVistaEnterprise	#	VKK3X-68KWM-X2YGT-QR4M6-4BWMV
WindowsVistaEnterpriseN	#	VTC42-BM838-43QHV-84HX6-XJXKV
	#	
WindowsServer2008	#	
	#	
操作系统	#	KMS激活序列号
WindowsServer2008Web	#	WYR28-R7TFJ-3X2YQ-YCY4H-M249D
WindowsServer2008Standard	#	TM24T-X9RMF-VWXK6-X8JC9-BFGM2
WindowsServer2008StandardwithoutHyper-V	#	W7VD6-7JFBR-RX26B-YKQ3Y-6FFFJ
WindowsServer2008Enterprise	#	YQGMW-MPWTJ-34KDK-48M3W-X4Q6V
WindowsServer2008EnterprisewithoutHyper-V	#	39BXF-X8Q23-P2WWT-38T2F-G3FPG
WindowsServer2008HPC	#	RCTX3-KWVHP-BR6TB-RB6DM-6X7HP
WindowsServer2008Datacenter	#	7M67G-PC374-GR742-YH8V4-TCBY3
WindowsServer2008DatacenterwithoutHyper-V	#	22XQ2-VRXRG-P8D42-K34TD-G3QQC
WindowsServer2008forItanium-BasedSystems	#	4DWFP-JF3DJ-B7DTH-78FJB-PDRHK
rem ---------------------------Windows 系统激活序列号-------------------------------

