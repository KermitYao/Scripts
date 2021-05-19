1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem 开启此参数，cmd指定参数和gui选择将会失效;
rem 相当于强制使用命令行参数；
rem 如果不需要保持为空即可
rem 使用方法 ： SET DEFAULT=-o --agent -l --del -, 与正常的cmd参数保持一致
SET DEFAULT_ARGS=

rem 日志等级 DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem 解析参数列表
set argsList=argsHelp argsAll argsHotfix argsProduct argsAgent argsUndoAgent argsUndoProduct argsEntrySafeMode argsExitSafeMode argsStatus argsLog argsDel argsGui 
::----------------------------------

rem ----------- init -----------
rem 设置初始变量
:getPackagePatch

rem 已安装的软件,小于此本版则进行覆盖安装,版本号只计算两位，超过两位数会计算出错。
set version_Agent=8.0
set version_Product_eea=8.0
set version_Product_efsw=7.3
rem -------------------

rem 如果路径为UNC或可访问的绝对路径则不需要下载到本地,将直接调用安装；否则会下载到临时目录在使用绝对路径方式调用
rem 是否为UNC路径或绝对 True|False
set absStatus=True
rem 如果是共享目录可以设置账号密码，来首先建立ipc$连接，然后在使用UNC路径方式调用。如果为空则不进行IPC$连接。
set shareUser="kermit"
set sharePwd="5698"

if %absStatus%==False (

	rem 所有的路径不要携带 “” 引号，后续会自动处理引号问题。
	rem Agent 下载地址
	set path_agent_x86=http://192.168.30.43:8080/_ShareFile/ESET/EEA/agent_x86_v8.0.msi
	set path_agent_x64=http://192.168.30.43:8080/_ShareFile/ESET/EEA/agent_x64_v8.0.msi

	rem Agent 配置文件
	set path_agent_config=http://192.168.30.43:8080/_ShareFile/ESET/EEA/install_config.ini

	rem 追加参数,不需要则保持为空
	::set params_agent=password=eset1234.
	set params_agent=

	rem -------------------

	rem PC Product 下载地址
	set path_eea_v6.5_x86=http://192.168.30.43:8080/_ShareFile/ESET/EEA/eea_nt32_v6.5.msi
	set path_eea_v6.5_x64=http://192.168.30.43:8080/_ShareFile/ESET/EEA/eea_nt64_6.5.msi

	set path_eea_late_x86=http://192.168.30.43:8080/_ShareFile/ESET/EEA/eea_nt32_v8.0.msi
	set path_eea_late_x64=http://192.168.30.43:8080/_ShareFile/ESET/EEA/eea_nt64_v8.0.msi
	rem 追加参数,不需要则保持为空
	::set params_eea=password=eset1234.
	set params_eea=

	rem SERVER Product 下载地址
	set path_efsw_v6.5_x86=
	set path_efsw_v6.5_x64=

	set path_efsw_late_x86=
	set path_efsw_late_x64=http://192.168.30.43:8080/_ShareFile/ESET/EEA/efsw_nt64_v7.3.msi

	rem 追加参数,不需要则保持为空
	::set params_efsw=password=eset1234.
	set params_efsw=
	rem -------------------

	rem 补丁文件 下载地址
	set path_hotfix_kb4474419_x86=http://192.168.30.43:8080/_ShareFile/ESET/Tools/SHA2CAB/Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=http://192.168.30.43:8080/_ShareFile/ESET/Tools/SHA2CAB/Windows6.1-KB4474419-v3-x64.cab

	set path_hotfix_kb4490628_x86=http://192.168.30.43:8080/_ShareFile/ESET/Tools/SHA2CAB/Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=http://192.168.30.43:8080/_ShareFile/ESET/Tools/SHA2CAB/Windows6.1-KB4490628-x64.cab

) else (

	rem 所有的路径不要携带 “” 引号，后续会自动处理引号问题。
	rem Agent 下载地址
	set path_agent_x86=\\192.168.30.43\_ShareFile\ESET\EEA\agent_x86_v8.0.msi
	set path_agent_x64=\\192.168.30.43\_ShareFile\ESET\EEA\agent_x64_v8.0.msi

	rem Agent 配置文件
	set path_agent_config=\\192.168.30.43\_ShareFile\ESET\EEA\install_config.ini

	rem 追加参数,不需要则保持为空
	::set params_agent=password=eset1234.
	set params_agent=

	rem -------------------

	rem PC Product 下载地址
	set path_eea_v6.5_x86=\\192.168.30.43\_ShareFile\ESET\EEA\eea_nt32_v6.5.msi
	set path_eea_v6.5_x64=\\192.168.30.43\_ShareFile\ESET\EEA\eea_nt64_6.5.msi

	set path_eea_late_x86=\\192.168.30.43\_ShareFile\ESET\EEA\eea_nt32_v8.0.msi
	set path_eea_late_x64=\\192.168.30.43\_ShareFile\ESET\EEA\eea_nt64_v8.0.msi
	rem 追加参数,不需要则保持为空
	::set params_eea=password=eset1234.
	set params_eea=

	rem SERVER Product 下载地址
	set path_efsw_v6.5_x86=
	set path_efsw_v6.5_x64=

	set path_efsw_late_x86=
	set path_efsw_late_x64=\\192.168.30.43\_ShareFile\ESET\EEA\efsw_nt64_v7.3.msi

	rem 追加参数,不需要则保持为空
	::set params_efsw=password=eset1234.
	set params_efsw=
	rem -------------------

	rem 补丁文件 下载地址
	set path_hotfix_kb4474419_x86=\\192.168.30.43\_ShareFile\ESET\Tools\SHA2CAB\Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=\\192.168.30.43\_ShareFile\ESET\Tools\SHA2CAB\Windows6.1-KB4474419-v3-x64.cab

	set path_hotfix_kb4490628_x86=\\192.168.30.43\_ShareFile\ESET\Tools\SHA2CAB\Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=\\192.168.30.43\_ShareFile\ESET\Tools\SHA2CAB\Windows6.1-KB4490628-x64.cab

)

rem -------------------

rem 临时文件和日志存放路径
set path_Temp=%temp%\ESET_TEMP_INSTALL

rem 安装 cab 的默认参数
set params_hotfix="/quiet /norestart"

rem 记录初始命令行参数
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

rem 如果是GUI界面则显示一个简易的安装界面，否则静默安装
if "#%argsGui%"=="#True" (
	set params_msiexec=/qr /norestart
) else (
	set params_msiexec=/qn /norestart
)

rem 打印命令行帮助
if "#%argsHelp%"=="#True" (
	call :getCmdHelp
	set exitCode=0
	goto :exitScript
)

echo 正在处理相关信息...


if "#%argsEntrySafeMode%"=="#True" (
	call :setSafeBoot entry
	if "#!returnValue!"=="#True" (
		call :writeLog INFO entrySafeMode "已经配置为安全模式,将在下次启动时进入安全模式" True True
		set exitCode=0
	) else (
		call :writeLog ERROR entrySafeMode "配置为安全模式失败" True True
		set exitCode=9
	)	
)

if "#%argsexitSafeMode%"=="#True" (
	call :setSafeBoot exit
	if "#!returnValue!"=="#True" (
		call :writeLog INFO exitSafeMode "已经配置为正常模式,将在下次启动时进入正常模式" True True
		set exitCode=0
	) else (
		call :writeLog ERROR exitSafeMode "配置为正常模式失败" True True
		set exitCode=10
	)	
)

rem 卸载 Agent
if "#%argsUndoAgent%"=="#True" (
	call :getVersion Agent
	if "#!productCode!"=="#" (
		call :writeLog WARNING uninstallAgent "ESET Management Agent 未安装,无需卸载" True True
	) else (
		call :writeLog INFO uninstallAgent "开始卸载 [!productName!]" True True
		call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
		call :writeLog DEBUG uninstallAgent "[!productName!] 卸载退出码:[!errorlevel!]" False True
		call :writeLog INFO uninstallAgent "[!productName!] 卸载状态是:[!returnValue!]" True True
		if "#!returnValue!"=="#False" (call :writeLog ERROR uninstallAgent "[!productName!] 卸载状态是:[失败],请检查安装状态或联系管理员" True True)
	)
	if "#!returnValue!"=="#False" (set exitCode=7) else (set exitCode=0)
)

rem 卸载 Product
if "#%argsUndoProduct%"=="#True" (
	call :getVersion Product
	if "#!productCode!"=="#" (
		call :writeLog WARNING uninstallProduct "ESET Product 未安装,无需卸载" True True
	) else (
		call :writeLog INFO uninstallProduct "开始卸载 [!productName!]" True True
		call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
		call :writeLog DEBUG uninstallProduct "[!productName!] 卸载退出码:[!errorlevel!]" False True
		call :writeLog INFO uninstallProduct "[!productName!] 卸载状态是:[!returnValue!]" True True
		if "#!returnValue!"=="#False" (call :writeLog ERROR uninstallProduct "[!productName!] 卸载状态是:[失败],请检查安装状态或联系管理员" True True)
	)
	if "#!returnValue!"=="#False" (set exitCode=8) else (set exitCode=0)
)

rem 安装补丁
if "#%argsHotfix%"=="#True" (
	call :writeLog INFO installHotfix "开始处理补丁" True True
	call :getSysVer
	if  "#%ntVer:~,3%"=="#6.1#" (
		call :writeLog WARNING installHotfix "当前系统版本不支持安装补丁" True True
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
		call :writeLog DEBUG shareConnect "补丁 hotfix_kb4490628 共享连接状态是： [!returnValue!]" False True 

		call :connectShare "!hotfix_kb4474419!" %shareUser% %sharePwd%
		call :writeLog DEBUG shareConnect "补丁 hotfix_kb4474419 共享连接状态是： [!returnValue!]" False True 
	) else (
		call :writeLog INFO hotfixDownload "开始下载补丁: [hotfix_kb4490628.cab]" True True
		call :downFile "%~f0" "!hotfix_kb4490628!" "%path_Temp%\hotfix_kb4490628.cab"
		call :writeLog INFO hotfixDownload "补丁 hotfix_kb4490628 下载状态是: [!returnValue!]" True True 
		set hotfix_kb4490628="%path_Temp%\hotfix_kb4490628.cab"

		call :writeLog INFO hotfixDownload "开始下载补丁: [hotfix_kb4474419.cab]" True True
		call :downFile "%~f0" "!hotfix_kb4474419!" "%path_Temp%\hotfix_kb4474419.cab"
		call :writeLog INFO hotfixDownload "补丁 hotfix_kb4474419 下载状态是: [!returnValue!]" True True 
		set hotfix_kb4474419="%path_Temp%\hotfix_kb4474419.cab"
	)

	for %%a in (!hotfix_kb4490628! !hotfix_kb4474419!) do (
		if not exist "%%~a" (
			call :writeLog ERROR hotfixInstall "未找到可使用的路径:[%%~a]" True True
		) else (
			call :writeLog INFO hotfixInstall "开始安装补丁: [%%~a]" True True
			call :hotFixInstall "%%~a" "/quiet /norestart"
			call :writeLog DEBUG hotfixInstall "hotfix [%%~a] 安装退出码:[!errorlevel!]" False True
			call :writeLog INFO hotfixInstall "这个补丁 [%%~a] 安装状态是:[!returnValue!]" True True
			if "#!dismExitCode!"=="#3310" (call :writeLog WARNING hotfixInstall "这个补丁 [%%~a] 安装状态是:[挂起],你需要重启才能进行后续安装" True True)
		)
	)
	
	if "#!returnValue!"=="#False" (set exitCode=5) else (set exitCode=0)
)

rem 安装Agent management
if "#%argsAgent%"=="#True" (
	call :writeLog INFO installAgent "开始处理Agent" True True
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
			call :writeLog DEBUG shareConnect "Agent 共享连接状态是: [!returnValue!]" False True 

			call :connectShare "!agent_config!" %shareUser% %sharePwd%
			call :writeLog DEBUG shareConnect "Agent 配置 共享连接状态是: [!returnValue!]" False True 
		) else (
			call :writeLog INFO agentDownload "开始下载Agent: [agent.msi]" True True
			call :downFile "%~f0" "!agent!" "%path_Temp%\agent.msi"
			call :writeLog INFO agentDownload "Agent.msi 下载状态是: [!returnValue!]" True True 
			set agent="%path_Temp%\agent.msi"

			call :writeLog INFO agentConfigDownload "开始下载Agent config: [install_config.ini]" True True
			call :downFile "%~f0" "!agent_config!" "%path_Temp%\install_config.ini"
			call :writeLog INFO agentConfigDown "install_config.ini 下载状态是: [!returnValue!]" True True 
			set agent_config="%path_Temp%\install_config.ini"
		)

		for %%a in (!agent!) do (
			if not exist "!agent!" (
				call :writeLog ERROR agent "未找到可使用的路径:[%%~a]" True True
			) else (
				if exist !agent_config! (
					call :writeLog INFO agentInstall "开始安装Agent: [%%~a]" True True
					call :msiInstall "%%~a" "%params_msiexec%" "%params_agent%"
					call :writeLog DEBUG agentInstall "Agent [%%~a] 安装退出码:[!errorlevel!]" False True
					call :writeLog INFO agentInstall "Agent [%%~a] 安装状态是:[!returnValue!]" True True
					if "#!returnValue!"=="#False" (call :writeLog ERROR agentInstall "Agent [%%~a] 安装状态是:[失败],请检查网络或联系管理员" True True)
					if "#!returnValue!"=="#False" (set exitCode=6) else (set exitCode=0)
				) else (
					call :writeLog ERROR agentInstall "未找到配置文件 [!agent_config!],将退出本次安装,安装状态是:[失败],请检查网络或联系管理员" True True
					set exitCode=6
				)
			)
		)
	) else (
		call :writeLog INFO agentInstall "Agent 版本 [%version_Agent%] 小于或等于当前已安装的版本,无需再次安装" True True
		set exitCode=0
	)
)

rem 打印系统状态
if "#%argsSysStatus%"=="#True" (
	call :getStatus
	set exitCode=0
)

rem 没有匹配的参数则报错
if not "#%argsStatus%"=="#True" (
	call :writeLog ERROR witeLog "参数解析错误，未找到合适的选项" True True
	set exitCode=98
	goto :exitScript
)


rem exitCode: 正常:0,标准命令行报错:1,系统版本错误:2,系统平台错误:3,无法获取补丁包:4,有补丁安装失败或挂起:5,安装Agent失败:6,卸载agent失败:7,卸载product失败:8,进入安装模式失败:9,退出安装模式失败:10,参数错误:97,无法解析参数:98,未知错误:99
:exitScript
echo Source 退出码:%errorlevel%
echo 退出码:%exitCode%
::call :debug
if "#%argsGui%"=="#True" (
	call :writeLog INFO exit "按任意键结束" True True
	pause >nul
	exit /b %exitCode%
) else (
	exit /b %exitCode%
)

rem ----------- begin end -----------



:debug
echo --------------- debug ---------------
echo exitCode: 
echo ----------参数状态-----------
for %%a in (%argsList%) do (
	call :getVar tmpStatus %%a
	if not "#!tmpStatus!"=="#" echo %%a:!tmpStatus!
)
echo ----------参数状态-----------
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

rem 配置为进入或退出安全模式; 传入参数:%1 = entry | exit |status ;例：call :setSafeBoot entry; 返回值: returnValue = True | False,当传入参数为: status 时以下变量将被赋值:safeModeStatus=False|True
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

rem 获取系统版本; 传入参数:无需传入；例：call :getSysVer ; 返回值: returnValue = "Windows XP"|"Windows 7"|"Windows 10"|"Windows Server 2008"|"Windows Server 2012"|"Windows Server 2016"|"Windows Server 2019"
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

rem 获取系统平台; 传入参数:无需传入；例：call :getSysArch ; 返回值: returnValue = x86|x64
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

rem 获取 gui 界面,返回;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.*************************************************
echo.*						*
echo.*	a.自动检查安装 补丁+代理+安全产品	*
echo.*						*
echo.*	o.安装补丁				*
echo.*						*
echo.*	p.安装安全产品				*
echo.*						*
echo.*	g.安装服务器代理			*
echo.*						*
echo.*	n.卸载 Agent				*
echo.*						*
echo.*	d.卸载 安全产品				*
echo.*						*
echo.*	e.进入安全模式				*
echo.*						*
echo.*	x.退出安全模式				*
echo.*						*
echo.*	s.检查状态				*
echo.*						*
echo.*	h.显示命令行帮助			*
echo.*						*
echo.*	kermit.yao@outlook.com			*
echo.*						*
echo.*************************************************
echo.
echo.
set /p input=请选择:(a^|o^|p^|n^|d^|e^|x^|g^|s^|h):
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
	call :writeLog getGuiHelp ERROR "选择错误:[!input!]" True True
	goto getGuiHelp
)
goto :eof

rem 解析传入参数; 传入参数: %1 = 参数列表；例：call :getArgs args ; 返回值: 无返回值
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

::多重变量获取
:getVar
set %1=!%2!
goto :eof


rem 判断是否安装补丁; 传入参数: %1 = 补丁号；例：call :getHotfixStatus KB4474419 ; 返回值: returnValue=True | False | Null
:getHotfixStatus
set hotfixStatus=False
wmic qfe get hotfixid|find /i "%1" >nul&&set hotfixStatus=True

if "#"=="#!hotfixStatus!" (
	set returnValue=Null
) else (
	set returnValue=!hotfixStatus!
)
goto :eof

rem 安装msi文件; 传入参数: %1 = 文件路径，%2 = 参数；%3 = 追加参数，例：call :msiInstall "%temp%\ESET_INSTALL\eea_v8.0.msi" "/qn" "password=eset1234."; 返回值: returnValue=True | False
:msiInstall
set returnValue=False
start /wait  msiexec %~2 /i "%~1" %~3
if "#%errorlevel%"=="#0" set returnValue=True
goto :eof

rem 卸载软件; 传入参数: %1 = 产品代码，%2 = 参数；%3 = 追加参数，例：call :uninstallProduct  "{76DA17F9-BC39-4412-88F0-F173806999E7}" "/qn" "password=eset1234."; 返回值: returnValue = True|False. 
:uninstallProduct
set returnValue=False
start /wait  msiexec %~2 /x "%~1" %~3
if "#%errorlevel%"=="#0" set returnValue=True
goto :eof

rem 安装cab文件; 传入参数: %1 = 文件路径，%2 = 参数；例：call :hotFixInstall "%temp%\ESET_INSTALL\Windows-KB4474419.CAB" "/quiet /norestart" ; 返回值: returnValue=True | False
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
echo 命令参数:%args%

call :getUac
echo UAC权限:!uacStatus!

call :getSysVer
echo 系统版本:!sysVersion!
echo NT内核版本:!ntVer!

call :getSysArch
echo 系统平台类型:!sysArch!

call :getHotfixStatus KB4474419
echo KB4474419 补丁安装状态:!returnValue!

call :getHotfixStatus KB4490628
echo KB4490628 补丁安装状态:!returnValue!

call :getVersion Product
echo 产品安装名称:!productName!
echo 产品安装版本:!productVersion!
echo 产品安装路径:!productDir!
echo 产品安装代码:!productCode!


call :getVersion Agent
echo Agent 安装名称:!productName!
echo Agent 安装版本:!productVersion!
echo Agent 安装路径:!productDir!
echo Agent 安装代码:!productCode!

call :setSafeBoot status
echo 是否配置为安全模式:!safeModeStatus!
goto :eof

rem 连接共享主机; 传入参数: %1 = 主机， %2 = 用户名, %3 = 密码; 例：call :connectShare "\\127.0.0.1" "kermit" "5698" ; 返回值: returnValue=True | False
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

rem 下载文件; 传入参数: %1 = 当前文件路径， %2 = url, %3 = 保存地址; 例：call :downFile "%~f0" "http://192.168.31.99/test.rar" "d:\test.rar"; 返回值: returnValue=True | False
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

rem 获取UAC状态; 传入参数: 无参数传入 ; 例：call :getUac ; 返回值: returnValue=True | False | Null
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

rem 写入日志; 传入参数: %1 = 消息类型， %2 = 标题, %3 = 消息文本， %4 = True 写入标准输出 | False，%5 = True 写入日志文件 | False; 例：call :writeLog witeLog ERROR "This is a error message." True False; 返回值:无返回值
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

rem 获取软件版本; 传入参数: %1 =Product | Agent ; 例：call :getVersion Product; 返回值:returnValue=版本号 | Null,如果产品存在以下变量会被赋值：productCode,productName,productVersion,productDir
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
	echo 按任意键退出
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

