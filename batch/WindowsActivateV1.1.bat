@rem Version is v1.1 , The code by kermit.yao to writen in Windows 10 system.
@echo off
setlocal enabledelayedexpansion
title Windows 系列激活.

rem --------user value-----------------
rem 开启调试信息
set debug=True
set kmsServer=yjyn.top

rem --------user value-----------------

rem --------init value-----------------
set systemActivateOption=False
set officeActivateOption=False
set keyValue=False
set pathValue=False
set helpValue=False
set kmsValue=False
set kmsReset=False
set "strlen=set $=^!#1^!#&set ##=&(for %%a in (2048 1024 512 256 128 64 32 16)do if ^!$:~%%a^!. NEQ . set/a##+=%%a&set $=^!$:~%%a^!)&set $=^!$^!fedcba9876543210&set/a##+=0x^!$:~16,1^!"
rem --------init value-----------------
set srcArgs=%*
if "#%~1"=="#" (
	call :getGuiHelp
) else (
	call :getArgs %*
)


if "!helpValue!"=="True" (
	call :getCmdHelp
	set exitCode=0
	goto :exitCode
	
)

if "!kmsReset!"=="True" (
	call :setReset
	set exitCode=0
	goto :exitCode
)

call :getUac
call :getArgsStatus
if not "!returnValue!"=="True" (
	call :getErrorMsg  !returnValue! ERROR
	set exitCode=1
	goto :exitCode
)

if "!systemActivateOption!"=="True" (
	if "!kmsValue!"=="False" (
		set kmsValue=!kmsServer!
	)
	if "!keyValue!"=="False" (
		call :getSysVer
		if "#!debug!"=="#True" echo 系统版本是:[!returnValue!]
		if "!returnValue!"=="Null" (
			call :getErrorMsg  "System version not found." ERROR
			set exitCode=2
			goto :exitCode
		)
		call :getSysKey !returnValue!
		if "!returnValue!"=="Null" (
			call :getErrorMsg  "No suitable activation code found." ERROR
			set exitCode=3
			goto :exitCode
		)
		set keyValue=!returnValue!
	)
	if not "!uacStatus!"=="True" (
		call :getErrorMsg  "You must use an administrator." ERROR
		set exitCode=4
		goto :exitCode
	)
	
	call :setActivationSystem
	if "#!returnValue!"=="#True" (
		echo 激活成功
		call :getActivateEnd
		echo !activateEnd!
		set exitCode=0
		goto :exitCode
	) else (
		echo 激活失败
		set exitCode=5
		goto :exitCode
	)
	set exitCode=99
	goto :exitCode
)

if "!officeActivateOption!"=="True" (
	if "!kmsValue!"=="False" (
		set kmsValue=!kmsServer!
	)
	if "!pathValue!"=="False" (
		call :getOfficePath
		if "!returnValue!"=="Null" (
			call :getErrorMsg  "Office path not found." ERROR
			set exitCode=2
			goto :exitCode
		)
		set pathValue=!returnValue!
	)
	if not "!uacStatus!"=="True" (
		call :getErrorMsg  "You must use an administrator." ERROR
		set exitCode=4
		goto :exitCode
	)

	call :setActivationOffice "!pathValue!\OSPP.VBS"
	set exitCode=0
	goto :exitCode
)

exit /b 7
:exitCode
if "#%guiStatus%"=="#True" (
	echo 按任意键退出
	if "!debug!"=="True" call :debug
	pause>nul
	exit /b !exitCode!
) else (
	if "!debug!"=="True" call :debug
	exit /b !exitCode!
)
goto :eof


rem ---------------------end ------------------------

:debug
echo --------------- debug ---------------
echo exitCode: 正常:0,参数错误:1,无法获取系统版本:2,无法找到合适的key:3,权限不足:4,激活失败:5,未找到office路径:6,未知错误:99
echo.args=!srcArgs!
echo.systemActivateOption=!systemActivateOption!
echo.officeActivateOption=!officeActivateOption!
echo.keyValue=!keyValue!
echo.pathValue=!pathValue!
echo.helpValue=!helpValue!
echo.kmsValue=!kmsValue!
echo.kmsReset=!kmsReset!
call :getActivateEnd
echo.activateEnd=!returnValue!
call :getNetStatus baidu.com
echo netStatus=!returnValue!
echo.kmsValue=!kmsValue!
echo.keyValue=!keyValue!
echo.uacStatus=!uacStatus!
echo sysVersion=!sysVersion!
::call :getWindowsKey
echo --------------- debug ---------------
goto :eof



:getUacMessage
if not "!uacStatus!"==True (
	call :getErrorMsg  "You must use an administrator." ERROR
)
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
echo  -r, --reset		[optional] Reset kms.
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
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.#################################
echo.#				#
echo.#	s.自动激活Windows系列	#
echo.#				#
echo.#	o.自动激活Office系列	#
echo.#				#
echo.#	r.重置kms信息		#
echo.#				#
echo.#	h.显示命令行参数	#
echo.#				#
echo.#	kermit.yao@outlook.com	#
echo.#				#
echo.#################################
echo.
echo.
set /p input=请选择:(s^|o^|h):

for %%a in (s o h r) do (
	if "#!input!"=="#%%a" (
		cls
		echo.
		call :getArgs -!input!
		set guiArgsStatus=True
	)
)

if "!helpValue!"=="True" (
	goto :eof
)


if "#!guiArgsStatus!"=="#True" (
	set returnValue=!guiArgsStatus!
) else (
	call :getErrorMsg "选择错误:[!input!]" ERROR
	goto getGuiHelp
)
goto :eof

rem 判断参数是否冲突；返回 return = True|Error message
:getArgsStatus
set returnValue=
if "!systemActivateOption!"=="True" (
	if "!officeActivateOption!"=="True" (
		set returnValue="Error,System and Office cannot same time activate."
		goto :eof	
	)
)

if not "!systemActivateOption!"=="True" (
	if not "!officeActivateOption!"=="True" (
		set returnValue="Error,System and Office must select one activate."
		goto :eof	
	)
)

if not "!keyValue!"=="False" (
	set #1=!keyValue!
	(%strlen%)
	if not "!##!"=="29" (
		set returnValue="Error,The key is not valid."
		goto :eof	
	)
)
if not "!pathValue!"=="False" (
	if not exist "!pathValue!\OSPP.VBS" (
		set returnValue="Error,Office installation path not found."
		goto :eof
	)
)
set returnValue=True
goto :eof

rem 显示错误消息,可传入参数 %1 = message
:getErrorMsg
::cls
echo ****************%2********************
echo.*%~1
echo ****************%2********************
goto :eof

rem 解析传入参数
:getArgs
:loop
set returnValue=
if "%~1" == "" goto :getArgsBreak
if "%~1" == "-h" (
	set helpValue=True
	rem call :getCmdHelp
) else (
	if "%~1" == "--help" (
		set helpValue=True
		rem call :getCmdHelp
	)
)

if "%~1" == "-s" (
	set systemActivateOption=True
) else (
	if "%~1" == "--system" (
		set systemActivateOption=True
	)
)

if "%~1" == "-o" (
	set officeActivateOption=True
) else (
	if "%~1" == "--office" (
		set officeActivateOption=True
	)
)

if "%~1" == "-r" (
	set kmsReset=True
) else (
	if "%~1" == "--reset" (
		set kmsReset=True
	)
)

if "%~1" == "-k" (
	call :getShiftValue %1 %2
	set keyValue=!returnValue!
) else (
	if "%~1" == "--key" (
		call :getShiftValue %1 %2
		set keyValue=!returnValue!
	)
)

if "%~1" == "-p" (
	call :getShiftValue %1 %2
	set pathValue=!returnValue!
) else (
	if "%~1" == "--path" (
		call :getShiftValue %1 %2
		set pathValue=!returnValue!
	)
)

if "%~1" == "-kms" (
	call :getShiftValue %1 %2
	set kmsValue=!returnValue!
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
					set officePath=%%~dpx
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
ping -n 2 %1 >nul
if !errorlevel! equ 0 (
	set netStatus=True
) else (
	set netStatus=False
)
set returnValue=!netStatus!

goto:eof


rem 获取传入参数shift后的值;传入参数:%1=%* 返回 return=%1 +1
:getShiftValue
set returnValue=
shift
set returnValue=%~1
goto :eof

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

if "#"=="#!activateEnd!" (
	set returnValue=Null
) else (
	set returnValue=!activateEnd!
)
goto :eof

:setActivationSystem
set returnValue=
set keyActivate=False
set activateStatus=False
set tmpStatus=False
echo 正在设置KMS服务器: [!kmsValue!]
for /f "delims=" %%a in ('cscript //nologo %windir%\system32\slmgr.vbs -skms !kmsValue! ^>nul ^&^& echo statusTrue') do (
	set tmp=%%a
	if "#!tmp:~,10!"=="#statusTrue" (
		set tmpStatus=True
	) else (
		echo 设置kms信息:!tmp!
	)
	if "!tmpStatus!"=="True" (
		goto :kmsIsOk
	)
)
call :getErrorMsg "KMS 服务器设置有误" ERROR
goto :eof

:kmsIsOk
set tmpStatus=False
echo 正在设置密钥: [!keyValue!]
for %%a in (!keyValue!) do (
	if "#!debug!"=="#True" echo 当前KEY:%%a
	for /f "delims=" %%b in ('cscript //nologo %windir%\system32\slmgr.vbs -ipk %%a ^>nul ^&^& echo statusTrue') do (
		set tmp=%%b
		if "#!tmp:~,10!"=="#statusTrue" (
			set tmpStatus=True
		) 

		if "!tmpStatus!"=="True" (
			goto :keyIsOk
		)
	)
)
call :getErrorMsg "无可用的Key" ERROR
goto :eof

:keyIsOk
set tmpStatus=False
echo 正在激活密钥: [!keyValue!]
for /f "delims=" %%a in ('cscript //nologo %windir%\system32\slmgr.vbs -ato ^&^& echo statusTrue') do (
	set tmp=%%a
	if "#!tmp:~,10!"=="#statusTrue" (
		set tmpStatus=True
	)
)

if "!tmpStatus!"=="True" (
	set returnValue=!tmpStatus!
)

goto :eof

rem 激活office 接受参数office安装路径;%1=officePath
:setActivationOffice
set returnValue=
for %%a in (/setprt:1688 /sethst:%kmsServer% /act) do (
	for /f "delims=" %%b in ('cscript //nologo "%~1" %%a') do if "%%a"=="setprt:1688" (echo 设置端口:%%b) else (echo 设置kms信息:%%b)
)
set returnValue=Null
goto :eof

rem 清除kms信息=卸载
:setReset
set returnValue=
for %%a in (-ckms -rearm -upk) do (
	for /f "delims=" %%b in ('cscript //nologo %windir%\system32\slmgr.vbs %%a') do if %%a==-ckms (echo 清除kms信息:%%b) else (echo 重置计算机授权状态:%%b)
)
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
	set returnValue=Null
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

