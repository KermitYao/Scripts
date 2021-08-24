1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::* 2021-05-25 脚本完成
::* 2021-05-27 增加选择和命令行选项可以无视大小写
::* 2021-06-03 增加对非sp1 的win7系统(nt 6.1.7600)的检测;更新部分描述
::* 2021-08-24 增加在安装Server2008 系统安全产品时自动添加网络模块；将 find 替换为 findstr 以修复某些情况下,报错的问题； 在使用本地安装文件时,将首先中转到脚本所在目录,再执行后续操作。


@rem version 1.1.1
@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem 开启此参数，cmd指定参数和gui选择将会失效;
rem 相当于强制使用命令行参数；
rem 如果不需要保持为空即可
rem 使用方法 ： SET DEFAULT=-o --agent -l --remove -, 与正常的cmd参数保持一致
SET DEFAULT_ARGS=

rem 日志等级 DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

set DEBUG=False
set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem 解析参数列表
set argsList=argsHelp argsAll argsHotfix argsProduct argsAgent argsUndoAgent argsUndoProduct argsEntrySafeMode argsExitSafeMode argsSysStatus argsLog argsRemove argsGui
::----------------------------------

rem ----------- init -----------
rem 设置初始变量
:getPackagePatch

rem 已安装的软件,小于此本版则进行覆盖安装,版本号只计算两位，超过两位数会计算出错。
set version_Agent=8.1
set version_Product_eea=8.1
set version_Product_efsw=8.0
rem -------------------

rem 如果路径为UNC或可访问的绝对路径则不需要下载到本地,将直接调用安装；否则会下载到临时目录在使用绝对路径方式调用
rem 是否为UNC路径或绝对 True|False
set absStatus=False
rem 如果是共享目录可以设置账号密码，来首先建立ipc$连接，然后在使用UNC路径方式调用。如果为空则不进行IPC$连接。
set shareUser="kermit"
set sharePwd="5698"

if %absStatus%==False (

	rem 所有的路径不要携带 “” 引号，后续会自动处理引号问题;同时 "%" 在脚本里有特殊意义，如果网址内包含空格需要将 "%" 进行转义
	rem Agent 下载地址
	set path_agent_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Agent/agent_x86_v8.1.msi
	set path_agent_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Agent/agent_x64_v8.1.msi

	rem Agent 配置文件
	set path_agent_config=http://192.168.30.43:8080/ESET/CLIENT/Agent/install_config.ini

	rem 追加参数,不需要则保持为空
	::set params_agent=password=eset1234.
	set params_agent=

	rem -------------------

	rem PC Product 下载地址
	set path_eea_v6.5_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/PC/eea_nt32_chs_v6.5.msi
	set path_eea_v6.5_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/PC/eea_nt64_chs_6.5.msi

	set path_eea_late_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/PC/eea_nt32_v8.1.msi
	set path_eea_late_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/PC/eea_nt64_v8.1.msi

	rem SERVER Product 下载地址
	set path_efsw_v6.5_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Server/efsw_nt32_chs_v6.5.msi
	set path_efsw_v6.5_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Server/efsw_nt64_chs_v6.5.msi

	set path_efsw_late_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Server/efsw_nt32_v8.0.msi
	set path_efsw_late_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Server/efsw_nt64_v8.0.msi

	rem 追加参数,不需要则保持为空
	::set params_eea=password=eset1234.
	set params_product=
	rem -------------------

	rem 补丁文件 下载地址
	set path_hotfix_kb4490628_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4490628-x64.cab

	set path_hotfix_kb4474419_x86=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=http://192.168.30.43:8080/esetFiles/esetServerFiles/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4474419-v3-x64.cab

) else (
	pushd "%~dp0"
	rem 所有的路径不要携带 “” 引号，后续会自动处理引号问题。
	rem 所谓unc地址可以理解为文件的路径， 可以是相对路径或者绝对路径，都可以使用。
	rem Agent unc地址
	set path_agent_x86=CLIENT\Agent\agent_x86_v8.1.msi
	set path_agent_x64=CLIENT\Agent\agent_x64_v8.1.msi

	rem Agent 配置文件
	set path_agent_config=CLIENT\Agent\install_config.ini

	rem 追加参数,不需要则保持为空
	::set params_agent=password=eset1234.
	set params_agent=

	rem -------------------

	rem PC Product unc地址
	set path_eea_v6.5_x86=CLIENT\PC\eea_nt32_chs_v6.5.msi
	set path_eea_v6.5_x64=CLIENT\PC\eea_nt64_chs_v6.5.msi

	set path_eea_late_x86=CLIENT\PC\eea_nt32_v8.1.msi
	set path_eea_late_x64=CLIENT\PC\eea_nt64_v8.1.msi

	rem SERVER Product unc地址
	set path_efsw_v6.5_x86=CLIENT\Server\efsw_nt32_chs_v6.5.msi
	set path_efsw_v6.5_x64=CLIENT\Server\efsw_nt64_chs_v6.5.msi

	set path_efsw_late_x86=
	set path_efsw_late_x64=CLIENT\Server\efsw_nt64_v8.0.msi

	rem 追加参数,不需要则保持为空
	::set params_eea=password=eset1234.
	set params_product=
	rem -------------------

	rem 补丁文件 unc地址
	set path_hotfix_kb4474419_x86=CLIENT\Tools\sha2cab\Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=CLIENT\Tools\sha2cab\Windows6.1-KB4474419-v3-x64.cab
	set path_hotfix_kb4490628_x86=CLIENT\Tools\sha2cab\Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=CLIENT\Tools\sha2cab\Windows6.1-KB4490628-x64.cab
)

rem -------------------

rem 临时文件和日志存放路径
set path_Temp=%temp%\esetInstall

rem 安装 cab 的默认参数
set params_hotfix=/norestart

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

rem 如果系统是 Server 2008 则添加参数,以自动安装网络模块
call :getSysVer
if "#!sysVersion!"=="#WindowsServer2008" set "params_product=%params_product% ADDLOCAL=ALL"

rem 关闭日志打印
if "#%argsLog%"=="#True" (
	set logLevel=False
)

rem 打印命令行帮助
if "#%argsHelp%"=="#True" (
	call :getCmdHelp
	set exitCode=0
	goto :exitScript
)

echo 正在处理相关信息...

call :getUac

rem 进入安全模式
if "#%argsEntrySafeMode%"=="#True" (
	call :writeLog INFO setSafeBoot "开始配置安全模式" True True
	if "#!uacStatus!"=="#True" (
		call :getSysVer
		if not "#!sysVersion!"=="#WindowsXP" (
			call :setSafeBoot entry
			if "#!returnValue!"=="#True" (
				call :writeLog INFO entrySafeMode "已经配置为安全模式,将在下次启动时进入安全模式" True True
				set exitCode=0
			) else (
				call :writeLog ERROR entrySafeMode "配置为安全模式失败" True True
				set exitCode=9
			)
		) else (
			call :writeLog WARNING entrySafeMode "此功能不适用于,Windows XP 系统" True True
		)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)
)

rem 退出安全模式
if "#%argsexitSafeMode%"=="#True" (
	call :writeLog INFO exitSafeMode "开始清除安全模式" True True
	if "#!uacStatus!"=="#True" (
		call :getSysVer
		if not "#!sysVersion!"=="#WindowsXP" (
			call :setSafeBoot exit
			if "#!returnValue!"=="#True" (
				call :writeLog INFO exitSafeMode "已经配置为正常模式,将在下次启动时进入正常模式" True True
				set exitCode=0
			) else (
				call :writeLog ERROR exitSafeMode "配置为正常模式失败" True True
				set exitCode=10
			)
		) else (
			call :writeLog WARNING entrySafeMode "此功能不适用于,Windows XP 系统" True True
		)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)	
)


rem 卸载 Agent
if "#%argsUndoAgent%"=="#True" (
	call :writeLog INFO uninstallAgent "开始处理Agent卸载" True True
	if "#!uacStatus!"=="#True" (
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
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)		
)


rem 卸载 Product
if "#%argsUndoProduct%"=="#True" (
	call :writeLog INFO uninstallProduct "开始处理安全产品卸载" True True
	if "#!uacStatus!"=="#True" (
		call :getVersion Product
		if "#!productCode!"=="#" (
			call :writeLog WARNING uninstallProduct "ESET Product 未安装,无需卸载" True True
		) else (
			call :writeLog INFO uninstallProduct "开始卸载 [!productName!]" True True
			call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
			call :writeLog DEBUG uninstallProduct "[!productName!] 卸载退出码:[!errorlevel!]" False True
			call :writeLog INFO uninstallProduct "[!productName!] 卸载状态是:[!returnValue!]" True True
			if "#!msiexecExitCode!"=="#3010" (call :writeLog WARNING uninstallProduct "这个软件 [!productName!] 卸载状态是:[挂起],你需要重启才能进行后续卸载" True True)
		)
		if "#!returnValue!"=="#False" (set exitCode=8) else (set exitCode=0)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)		
)

rem 安装补丁
if "#%argsHotfix%"=="#True" (
	call :writeLog INFO installHotfix "开始处理补丁" True True
	if "#!uacStatus!"=="#True" (
		call :getSysVer
		if not "#!ntVerNumber!"=="#61" (
			call :writeLog WARNING installHotfix "当前系统版本不支持安装补丁" True True
			set exitCode=5
		) else (
			if "#!ntVer!"=="#6.1.7600" (
				call :writeLog WARNING installHotfix "当前系统版本不支持此安装补丁,您需要将系统先升级到 Windowns 7 Service Pack 1 才能继续安装此补丁" True True
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
						call :writeLog INFO installHotfix "补丁 [%%a] 已经存在,无需重复安装" True True
						set exitCode=0
					) else (
						if "#%absStatus%"=="#True" (
							call :connectShare "!hotfix_%%a!" %shareUser% %sharePwd%
							call :writeLog DEBUG connectShare "补丁 %%a 共享连接状态是： [!returnValue!]" False True 
						) else (
							call :writeLog INFO downloadHotfix "开始下载补丁: [!hotfix_%%a!]" True True
							call :downFile "%~f0" "!hotfix_%%a!" "%path_Temp%\hotfix_%%a.cab"
							call :writeLog INFO downloadHotfix "补丁 [[%%a]] 下载状态是: [!returnValue!]" True True 
							set hotfix_%%a="%path_Temp%\hotfix_%%a.cab"
						)
						if not exist "!hotfix_%%a!" (
							call :writeLog ERROR installHotfix "未找到可使用的路径:[!hotfix_%%a!]" True True
						) else (
							call :writeLog INFO installHotfix "开始安装补丁: [%%a]" True True
							call :hotFixInstall "!hotfix_%%a!" "%params_hotfix%"
							call :writeLog DEBUG installHotfix "hotfix [%%a] 安装退出码:[!errorlevel!]" False True
							call :writeLog INFO installHotfix "这个补丁 [%%a] 安装状态是:[!returnValue!]" True True
							if "#!dismExitCode!"=="#3010" (call :writeLog WARNING installHotfix "这个补丁 [%%a] 安装状态是:[挂起],你需要重启才能进行后续安装" True True)
						)
					)
				)
				if "#!returnValue!"=="#False" (set exitCode=5) else (set exitCode=0)
			)
		)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)		
)


rem 安装Agent
if "#%argsAgent%"=="#True" (
	call :writeLog INFO installAgent "开始处理Agent安装" True True
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
				call :writeLog DEBUG connectShare "Agent 共享连接状态是: [!returnValue!]" False True 

				call :connectShare "!agent_config!" %shareUser% %sharePwd%
				call :writeLog DEBUG connectShare "Agent 配置 共享连接状态是: [!returnValue!]" False True 
			) else (
				call :writeLog INFO downloadAgent "开始下载Agent: [!agent!]" True True
				call :downFile "%~f0" "!agent!" "%path_Temp%\agent.msi"
				call :writeLog INFO downloadAgent "[!agent!] 下载状态是: [!returnValue!]" True True 
				set agent=%path_Temp%\agent.msi

				call :writeLog INFO downloadAgentConfig "开始下载Agent config: [install_config.ini]" True True
				call :downFile "%~f0" "!agent_config!" "%path_Temp%\install_config.ini"
				call :writeLog INFO downloadAgentConfig "install_config.ini 下载状态是: [!returnValue!]" True True 
				set agent_config=%path_Temp%\install_config.ini
			)
			if not exist "!agent!" (
				call :writeLog ERROR installAgent "未找到可使用的路径:[!agent!]" True True
			) else (
				if exist !agent_config! (
					call :writeLog INFO installAgent "开始安装Agent: [!agent!]" True True
					call :msiInstall "!agent!" "%params_msiexec%" "%params_agent%"
					call :writeLog DEBUG installAgent "Agent [!agent!] 安装退出码:[!errorlevel!]" False True
					call :writeLog INFO installAgent "Agent [!agent!] 安装状态是:[!returnValue!]" True True
					if "#!returnValue!"=="#False" (call :writeLog ERROR agentInstall "Agent [!agent!] 安装状态是:[失败],请检查系统环境或联系管理员" True True)
					if "#!returnValue!"=="#False" (set exitCode=6) else (set exitCode=0)
				) else (
					call :writeLog ERROR installAgent "未找到配置文件 [!agent_config!],将退出本次安装,安装状态是:[失败],请检查系统环境或联系管理员" True True
					set exitCode=6
				)
			)
		) else (
			call :writeLog INFO installAgent "Agent 版本 [%version_Agent%] 小于或等于当前已安装的版本,无需再次安装" True True
			set exitCode=0
		)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)		
)

rem 安装Product
if "#%argsProduct%"=="#True" (
	call :writeLog INFO installProduct "开始处理安全产品安装" True True
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
				call :writeLog DEBUG connectShareConnect "Product 共享连接状态是: [!returnValue!]" False True 
			) else (
				call :writeLog INFO downloadProduct "开始下载安全产品: [!path_product!]" True True
				call :downFile "%~f0" "!path_product!" "%path_Temp%\product.msi"
				call :writeLog INFO downloadProduct "Product.msi 下载状态是: [!returnValue!]" True True 
				set path_product=%path_Temp%\product.msi
			)
			if not exist "!path_product!" (
				call :writeLog ERROR installProduct "未找到可使用的路径:[!path_product!],安全产品安装失败" True True
				set exitCode=11
			) else (
				call :writeLog INFO installProduct "开始安装安全产品: [!path_product!]" True True
				call :msiInstall "!path_product!" "%params_msiexec%" "%params_product%"
				call :writeLog DEBUG installProduct "安全产品 [!path_product!] 安装退出码:[!errorlevel!]" False True
				call :writeLog INFO installProduct "安全产品 [!path_product!] 安装状态是:[!returnValue!]" True True
				if "#!returnValue!"=="#False" (call :writeLog ERROR installProduct "安全产品 [!path_product!] 安装状态是:[失败],请检查网络或联系管理员" True True)
				if "#!returnValue!"=="#False" (set exitCode=11) else (set exitCode=0)
			)
		) else (
			call :writeLog INFO installProduct "安全产品版本 [!version_product!] 小于或等于当前已安装的版本,无需再次安装" True True
			set exitCode=0
		)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)		
)


rem 删除已下载的临时文件
if "#%argsDel%"=="#True" (
	call :writeLog INFO delTempFile "开始删除临时文件" True True
	for %%a in (*.msi *.cab) do (
		del /f /q %%a
	)
)

rem 打印系统状态
if "#%argsSysStatus%"=="#True" (
	call :writeLog INFO printSysStatus "开始打印系统状态" True True
	call :getStatus
	set exitCode=0
)

rem 没有匹配的参数则报错
if not "#%argsStatus%"=="#True" (
	call :writeLog ERROR witeLog "参数解析错误，未找到合适的选项" True True
	set exitCode=98
	goto :exitScript
)


rem exitCode: 正常:0,标准命令行报错:1,系统版本错误:2,系统平台错误:3,无法获取补丁包:4,有补丁安装失败或挂起:5,安装Agent失败:6,卸载agent失败:7,卸载product失败:8,进入安装模式失败:9,退出安装模式失败:10,安装product失败:11,Win7系统不是sp1:12，权限不足错误:96,参数错误:97,无法解析参数:98,未知错误:99
:exitScript
 if %DEBUG%==True call :debug

if "#%argsGui%"=="#True" (
	call :writeLog INFO argsList "argsList:[!args!]" False True
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
	echo %%a:!tmpStatus!
	rem if not "#!tmpStatus!"=="#" echo %%a:!tmpStatus!
)
echo ----------参数状态-----------

echo ----------变量状态-----------
set valueList=args sysType sysArch ntVer ntVerNumber errorlevel exitCode
for %%a in (!valueList!) do echo %%a:[!%%a!]
echo ----------变量状态-----------
echo.
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

rem 获取系统版本; 传入参数:无需传入；例：call :getSysVer ; 返回值: returnValue = "Windows XP"|"Windows 7"|"Windows 10"|"Windows Server 2008"|"Windows Server 2012"|"Windows Server 2016"|"Windows Server 2019"
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

rem 获取 gui 界面,返回;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.*************************************************
echo.*						*
echo.*	a.自动检查安装 补丁+Agent+安全产品	*
echo.*						*
echo.*	o.安装补丁				*
echo.*						*
echo.*	g.安装 Agent				*
echo.*						*
echo.*	p.安装安全产品				*
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

::多重变量获取
:getVar
set %1=!%2!
goto :eof

rem 判断是否安装补丁; 传入参数: %1-%9 = 补丁号；例：call :getHotfixStatus KB4474419 KB4490628 ; 返回值:无返回值，但是如果查找到对应的补丁号存在则传入的补丁后会被赋值为 True，如 KB4474419=True
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
if "#!errorlevel!"=="#3010" set returnValue=True
set msiexecExitCode=!errorlevel!
goto :eof

rem 安装cab文件; 传入参数: %1 = 文件路径，%2 = 参数；例：call :hotFixInstall "%temp%\ESET_INSTALL\Windows-KB4474419.CAB" "/quiet /norestart" ; 返回值: returnValue=True | False
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
echo 命令参数:%args%

call :getUac
echo UAC权限:!uacStatus!

call :getSysVer
echo 系统版本:!sysVersion!
echo NT内核版本:!ntVer!
echo 系统类型:!sysType!
if not "#!sysVersion!"=="#WindowsXP" (
	call :setSafeBoot status
	echo 是否配置为安全模式:!safeModeStatus!
)

call :getSysArch
echo 系统平台类型:!sysArch!

call :getHotfixStatus KB4474419 KB4490628
echo KB4474419 补丁安装状态:!KB4474419!
echo KB4490628 补丁安装状态:!KB4490628!

call :getVersion Product
echo 产品安装名称:!productName!
echo 产品安装版本:!productVersion!
echo 产品安装路径:!productDir!
echo 产品安装代码:!productCode!
if not "#!productCode!"=="#" set productInstallStatus=True

call :getVersion Agent
echo Agent 安装名称:!productName!
echo Agent 安装版本:!productVersion!
echo Agent 安装路径:!productDir!
echo Agent 安装代码:!productCode!
if not "#!productCode!"=="#" set agentInstallStatus=True

if "#!productInstallStatus!+!agentInstallStatus!"=="#True+True" (
	echo ***************** ESET NOD32 杀毒软件安装正常 *****************
) else (
	echo ***************** ESET NOD32 杀毒软件安装异常 *****************
)

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
set shareHost=!tmpValue:~,-1!
for /f "delims=" %%a in ('net use "!shareHost!" !cmd_user_param! "%~3" 2^>nul ^&^& echo statusTrue') do (
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

rem 获取软件版本; 传入参数: %1 =Product | Agent ; 例：call :getVersion Product; 返回值:returnValue=版本号 | Null,如果产品存在则以下变量会被赋值：productCode,productName,productVersion,productDir
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

