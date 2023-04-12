1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto :begin

::* 系统支持 win XP| win7 | win8| win10 | win server 2003 | win server 2008 | win server 2012 | win server|2016 |win server 2019
::* 前置第三方组件 findstr | wmic | msiexec | dism | reg | powershell (非必须) 
::* 2021-05-25 脚本完成
::* 2021-05-27 1.新增 -- GUI选择和命令行选项可以无视大小写
::* 2021-06-03 1.新增 -- 对非sp1系统(nt 6.1.7600)的检测;2.更新 -- 部分描述
::* 2021-08-24 1.新增 -- 在安装Server2008 系统安全产品时自动添加网络模块；2.更新 -- 将 find 替换为 findstr 以修复某些情况下,报错的问题； 3.更新 -- 在使用本地安装文件时,将首先跳转到脚本所在目录,再执行后续操作。
::* 2021-09-24 1.新增 -- eset 安装事件的抓取模块;2.新增 -- 强制略过检查模块;3.新增 -- 可以手动选择安装老版本模块;4.新增 -- 自动安装时,安装完补丁未重启时,现在将略过后续安装;5.修复 -- 自动安装6.5失败的问题;6.修复 -- gui选择错误时,不会出现报错提示;7.新增 -- 描述信息
::* 2021-09-29 1.更新 -- 现在当AGENT模块安装无法找到配置文件时会提示用户手动输入服务器地址,而非跳过AGENT安装（定义下载的文件如果小于 4kb 则表示下载的文件不正常,可以通过 errorFileSize=4 变量定义）
::* 2021-10-16 1.修复 -- 当在命令行模式工作并且在未找到配置文件时,现在会覆盖安装,并保留原有的host 和证书信息, 而非和gui模式一样弹出用户操作界面
::* 2021-10-29 1.更新 -- 修改部分描述,修正错别字
::* 2021-12-21 1.更新 -- 增加部分描述; 2.更新 -- 将下载地址更改为 files.yjyn.top:6080 避免老ie内核系统下载失败的问题
::* 2022-01-13 1.更新 -- 修复x86电脑安装agent无法获取下载链接的bug.
::* 2022-03-31 1.新增 -- 在使用 status 参数的时候,现在会增加ip地址列表和计算机名称的显示
::* 2022-04-04 1.新增 -- 状态信息现在会列出远程主机,用以判断连接的服务器是否正确; 2.更新 -- 优化获取 Agent 安装代码的速度, 提高整个脚本的运行效率
::* 2022-05-26 1.修复 -- 获取 AGENT 信息时,报告无法找到注册表的问题
::* 2022-10-21 1.新增 -- 现在可以通过指定参数来自动搜索第三方软件的卸载程序，进行卸载了(--avUninst).
::* 2022-10-28 1.修复 -- 增加对金山毒霸的卸载; 2.优化脚本的启动速度
::* v2.0.0_20230111_alpha
	1.新增 win7单独安装9.x版本
	2.新增 现在可以使用 -v 来显示当前的版本了; 
	3.更新 重构部分代码,封装成函数,实现不同系统版本对应不同的下载链接,提高效率;
	4.更新 重构版本判断罗辑,现在将更加精准
	5.更新 现在只有检测到确实需要获取系统信息时才会调用相关功能，提高脚本运行效率; 
	6.更新 卸载第三方模块现在可以添加msiexec方式安装的软件了，通过 在名称左右添加大括号实现: {}
	7.修复 修复了几个没什么影响的bug

::* v2.0.0_20230113_beta
	1.修复 处理之前遗留问题,完善版本判断罗辑；功能性测试.

::* v2.0.1_20230208_beta
	1.修复 Server 2008 安装无法获取安全产品下载链接的问题. (待服务器v10版本更新后,修正此处代码)

::* v2.0.2_20230308_beta
	1.修复 某些情况下使用js下载失败,但是未能切换到powershell下载的问题。
	2.修复 下载时未能将下载方式写入日志的问题

::* v2.0.2_20230310_beta
	1.修复 当下载失败时等待时间过长的问题

::* v2.0.3_20230313_beta
	1.修复 -r 参数删除临时文件无效的问题
	2.修复 卸载第三方软件时不在判断路径是否存在(暂定)
	3.修复 卸载msi软件时等待卸载程序结束
:: -------------待优化----------
	1.xp在调用 getVersion agent 时报错
	在此行代码中:for /f "delims=" %%x in ('reg query %%a /v ProductName 2^>nul ^| findstr /c:"ESET Management Agent"') do (
		xp系统获取的内容第一行会增加 "! reg 3.0" 导致错误,但无法通过标准错误屏蔽,暂未找到解决方案.

::-----readme-----

快速使用:
	修改135行开始,设置每个版本文件的下载地址,然后双击打开脚本输入 a 开始自动安装


概述:
	此脚本目的为简化用户安装时的过程,能实现一件自动化安装补丁和eset产品,以及对于已经安装的计算机自动升级或跳过,同时增加了一些排错常用的的功能,用于帮助客户快速方便的诊断问题根源。

功能:
	1.自动根据不同系统,不同系统平台,不同软件版本,来安装和升级补丁、AGENT、杀毒产品
	2.可以手动选择需要安装和卸载的产品
	3.进入和退出安全模式
	4.读取eset产品安装时,写入系统事件日志,方便出现安装错误时,定位问题
	5.读取系统状态用于判断问题
	6.可以根据需求自定义命令行参数，达到双击脚本自动安装的目的,(通过 DEFAULT_ARGS 参数实现)
	7.默认双击打开脚本会出现一个选择界面（此界面的操作会有一定的交互能力）
	8.支持命令行参数,以便预控推送时静默安装

使用方法：
	1.需要提前预设每个版本文件的下载地址或者本地的文件路径(可以使用相对路径,这样可以放到u盘里安装)
		具体是通过下载安装，或是本地文件安装，可以通过一个参数控制 absStatus=True 
	2.可以使用参数 -h | -help 来查看支持的参数
	3.如果需要实现双击自动安装,可以设置 DEFAULT_ARGS, 例如: DEFAULT_ARGS= -a -s -u , 表示自动安装补丁、agent、杀毒产品,并且会显示出安装的状态,然后停留等待
	4.
		set version_Agent=10
		set version_Product_eea=10
		set version_Product_efsw=9.0
		以上三个参数标识了最新的版本,一般版本号和安装文件的版本保持一致.
		当计算机已经存在一个杀毒软件,如果低于以上版本则会自动升级,如果高于则跳过安装,如果计算机没有安装过杀毒软件则预设版本号为0
	5.本质上软件的安装是通过调用 msiexec 实现的,所以如果想自定义参数可以通过此参数实现: set "params_agent= password=eset1234." ,会指定一个密码,当然也可以用别的参数,比如指定安装时的语言，可以写入多个参数，以空格隔开即可
	6. 这个参数 set path_agent_config 指定的文件,来自于gpo配置文件,这个文件和agent安装程序放在同一个目录,安装的时候就可以不用手动填写证书、密码等之类的东西，可以通过eset控制台生成
	7.脚本的运行需要管理员权限
	8.命令行参数不区分大小写
	9.安装的时候脚本会自动检测需要下载的对应版本,不会多下载的,所以如果没有 xp 系统,完全可以不填写 6.5 的文件下载地址;这样并不会影响使用
	10.想到了再写

:begin
::-----readme-----

cls
@set version=v2.0.2_20230308_beta
@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem 开启此参数，命令行指定参数和gui选择将会失效;
rem 相当于强制使用命令行参数；
rem 如果不需要保持为空即可
rem 使用方法 ： SET DEFAULT=-o --agent -l --remove -, 与正常的cmd参数保持一致
SET DEFAULT_ARGS=

rem 日志等级 DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

set DEBUG=False
set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem 解析参数列表
set argsList=argsHelp argsAll argsEarly argsHotfix argsProduct argsAgent argsUndoAgent argsUndoProduct argsEntrySafeMode argsExitSafeMode argsSysStatus argsEsetLog argsForce argsLog argsRemove argsGui argsAvUninst argsVersion
::----------------------------------

rem ----------- init -----------
rem 设置初始变量
:getPackagePatch

rem 已安装的软件版本如果小于此本版则进行覆盖安装,否则不进行安装(升级)
rem 版本号只计算两位，超过两位数会计算出错。
set version_Agent=10.0
set version_Product_eea=10.0
set version_Product_efsw=9.0
rem -------------------

rem 如果路径为UNC或可访问路径则不需要下载到本地,将直接调用安装；否则会下载到临时目录在使用绝对路径方式调用
rem 是否为UNC路径或绝对可访问的路径
rem 可用参数: True|False
set absStatus=False
rem 如果是共享目录可以设置账号密码，来首先建立ipc$连接，然后在使用UNC路径方式调用。如果为空则不进行IPC$连接。
set shareUser=
set sharePwd=


rem 用于启动第三方杀毒软件卸载程序,本质是搜索注册表键值,如果存在相应的键值,则启动卸载程序
rem 以键的方式配置, "产品名称:注册表键值名称"
set avList= "360安全卫士:360安全卫士" "360杀毒:360SD" "腾讯电脑管家:QQPCMgr" "火绒安全软件:HuorongSysdiag" "亚信安全:OfficeScanNT" "金山毒霸:Kingsoft Internet Security" "赛门铁克:{Symantec Endpoint Protection}"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem 此处设置用于下载文件的地址
if %absStatus%==False (
	rem --------agent--------
	rem 所有的路径不要携带 “” 引号，后续会自动处理引号问题;同时 "%" 在脚本里有特殊意义，如果网址内包含空格需要将 "%" 进行双写转义
	rem Agent 下载地址

	rem 老系统专用agent,建议使用 v8.0
	set path_agent_old_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x86_v8.0.msi
	set path_agent_old_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x64_v8.0.msi

	rem 最新版本agent,建议使用最新版本
	set path_agent_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x86_later.msi
	set path_agent_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x64_later.msi

	rem Agent 配置文件
	set path_agent_config=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/None

	rem 追加参数,不需要则保持为空
	::set params_agent=password=eset1234.
	set params_agent=
	rem --------agent--------

	rem --------PC product--------
	rem PC Product 下载地址

	rem 老系统专用杀毒软件,建议使用 v6.5
	set path_pc_old_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_chs_v6.5.msi
	set path_pc_old_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_chs_v6.5.msi

	rem Win7系统专用杀毒软件,需低于v10建议使用 v9.1
	set path_pc_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_v9.1.msi
	set path_pc_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_v9.1.msi

	rem 建议使用最新版本
	set path_pc_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_later.msi
	set path_pc_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_later.msi
	rem --------PC product--------

	rem --------Server product--------
	rem SERVER Product 下载地址
	rem 老系统专用杀毒软件,建议使用 v6.5
	set path_server_old_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_chs_v6.5.msi
	set path_server_old_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_chs_v6.5.msi

	rem Server2008系统专用杀毒软件,需低于v10建议使用 v9.1
	set path_server_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_v9.1.msi
	set path_server_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_v9.1.msi

	rem 建议使用最新版本
	set path_server_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_later.msi
	set path_server_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_later.msi
	rem --------Server product--------

	rem 追加参数,不需要则保持为空,PC 和 SERVER 版本共用同一个追加参数
	::set params_eea=password=eset1234.
	set params_product=

	rem --------patch--------
	rem 补丁文件 下载地址
	set path_hotfix_kb4490628_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4490628-x64.cab

	set path_hotfix_kb4474419_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Tools/sha2cab/Windows6.1-KB4474419-v3-x64.cab
	rem --------patch--------

) else (
	pushd "%~dp0"
	rem --------agent--------
	rem 所有的路径不要携带 “” 引号，后续会自动处理引号问题;同时 "%" 在脚本里有特殊意义，如果网址内包含空格需要将 "%" 进行双写转义
	rem Agent 文件路径

	rem 建议使用 v8.0
	set path_agent_old_x86=CLIENT\Agent\agent_x86_v8.0.msi
	set path_agent_old_x64=CLIENT\Agent\agent_x64_v8.0.msi

	rem 建议使用最新版本
	set path_agent_late_x86=CLIENT\Agent\agent_x86_v8.1.msi
	set path_agent_late_x64=CLIENT\Agent\agent_x64_v8.1.msi

	rem Agent 配置文件
	set path_agent_config=CLIENT\Agent\install_config.ini

	rem 追加参数,不需要则保持为空
	::set params_agent=password=eset1234.
	set params_agent=
	rem --------agent--------

	rem --------PC product--------
	rem PC Product 文件路径
	rem 建议使用 v6.5
	set path_pc_old_x86=PC\eea_nt32_chs_v6.5.msi
	set path_pc_old_x64=PC\eea_nt64_chs_v6.5.msi

	rem Win7系统专用杀毒软件,需低于v10建议使用 v9.1
	set path_pc_nt61_x86=PC\eea_nt32_v9.1.msi
	set path_pc_nt61_x64=PC\eea_nt64_v9.1.msi

	rem 建议使用最新版本
	set path_pc_late_x86=PC\eea_nt32_v8.1.msi
	set path_pc_late_x64=PC\eea_nt64_v8.1.msi
	rem --------PC product--------

	rem --------Server product--------
	rem SERVER Product 文件路径
	rem 建议使用 v6.5
	set path_server_old_x86=Server\efsw_nt32_chs_v6.5.msi
	set path_server_old_x64=Server\efsw_nt64_chs_v6.5.msi

	rem 建议使用最新版本
	set path_server_late_x86=Server\efsw_nt32_v8.0.msi
	set path_server_late_x64=Server\efsw_nt64_v8.0.msi
	rem --------Server product--------

	rem 追加参数,不需要则保持为空,PC 和 SERVER 版本共用同一个追加参数
	::set params_eea=password=eset1234.
	set params_product=

	rem --------patch--------
	rem 补丁文件路径
	set path_hotfix_kb4490628_x86=Tools\sha2cab\Windows6.1-KB4490628-x86.cab
	set path_hotfix_kb4490628_x64=Tools\sha2cab\Windows6.1-KB4490628-x64.cab

	set path_hotfix_kb4474419_x86=Tools\sha2cab\Windows6.1-KB4474419-v3-x86.cab
	set path_hotfix_kb4474419_x64=Tools\sha2cab\Windows6.1-KB4474419-v3-x64.cab
	rem --------patch--------

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

rem 下载文件阈值,小于多少判定为下载失败,  单位kb
set errorFileSize=4

rem ----------- init -----------

rem ----------- begin start -----------
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
call :getSysInfo
rem 如果系统是 Server 2008 则添加参数,以自动安装网络模块
if "#!sysVersion!"=="#WindowsServer2008" set "params_product=%params_product% ADDLOCAL=ALL"

call :getUac
if "#%argsForce%"=="#True" set uacStatus=True
rem 进入安全模式
if "#%argsEntrySafeMode%"=="#True" (
	call :writeLog INFO setSafeBoot "开始配置安全模式" True True
	if "#!uacStatus!"=="#True" (
		if not !ntVerNumber! lss 61 (
			call :setSafeBoot entry
			if "#!returnValue!"=="#True" (
				call :writeLog INFO entrySafeMode "已经配置为安全模式,将在下次启动时进入安全模式" True True
				set exitCode=0
			) else (
				call :writeLog ERROR entrySafeMode "配置为安全模式失败" True True
				set exitCode=9
			)
		) else (
			call :writeLog WARNING entrySafeMode "此功能不适用于,Windows XP 和 Windows server 2003 系统" True True
			set exitCode=2
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
		if not !ntVerNumber! lss 61 (
			call :setSafeBoot exit
			if "#!returnValue!"=="#True" (
				call :writeLog INFO exitSafeMode "已经配置为正常模式,将在下次启动时进入正常模式" True True
				set exitCode=0
			) else (
				call :writeLog ERROR exitSafeMode "配置为正常模式失败" True True
				set exitCode=10
			)
		) else (
			call :writeLog WARNING exitSafeMode "此功能不适用于,Windows XP 和 Windows server 2003 系统" True True
			set exitCode=2
		)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)	
)


rem 卸载第三方安全软件
if "#%argsAvUninst%"=="#True" (
	call :writeLog INFO avUninstl "开始处理第三方杀毒软件卸载..." True True
	if "#!uacStatus!"=="#True" (
		call :writeLog INFO avUninst "开始扫描第三方安全软件..." True True
		call :avUninst
		if "!avUninstFlag!"=="" (
			call :writeLog INFO avUninst "未扫描到其他安全软件." True True
		) else (
			call :writeLog INFO avUninst "如果有弹出卸载窗口,请请手动点击卸载程序选项进行卸载..." True True
			if "#%argsGui%"=="#True" (
				call :writeLog INFO avUninst "按任意键进行下一步操作." True True
				pause >nul
			) 
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
			if "#!msiexecExitCode!"=="#3010" (call :writeLog WARNING uninstallProduct "这个软件 [!productName!] 卸载状态是:[挂起],你需要重启以完成卸载" True True)
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
		if not "#!ntVerNumber!"=="#61" (
			call :writeLog WARNING installHotfix "当前系统版本无须安装补丁,只有 Windows 7 和 Windows server 2008 才需要安装补丁文件" True True
			set exitCode=5
		) else (
			if "#!ntVer!"=="#6.1.7600" (
				call :writeLog WARNING installHotfix "当前系统版本不支持此安装补丁,您需要将系统先安装 Service Pack 1 [KB976932] 才能继续安装此补丁" True True
				set exitCode=5
				goto :esetSkip
			) else (
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
							if "#!dismExitCode!"=="#3010" (
								call :writeLog WARNING installHotfix "这个补丁 [%%a] 安装状态是:[挂起],你需要重启才能进行后续安装" True True
								goto :esetSkip
							)
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
		call :formatVersion !returnValue!
		set agentCurrentVersionNoDot=!versionNoDot!
		set agentCurrentVersionDot=!versionDot!

		call :formatVersion !version_Agent!
		set agentInstallVersionNoDot=!versionNoDot!
		set agentInstallVersionDot=!versionDot!

		rem 当前版本小于已安装版本,则开始安装
		if "#%argsForce%"=="#True" set agentInstallVersionNoDot=0
		if !agentCurrentVersionNoDot! lss !agentInstallVersionNoDot! (
			if "#%absStatus%"=="#True" (
				call :connectShare "!path_agent!" %shareUser% %sharePwd%
				call :writeLog DEBUG connectShare "Agent 共享连接状态是: [!returnValue!]" False True 

				call :connectShare "!path_agent_config!" %shareUser% %sharePwd%
				call :writeLog DEBUG connectShare "Agent 配置 共享连接状态是: [!returnValue!]" False True 
			) else (
				call :writeLog INFO downloadAgent "开始下载Agent: [!path_agent!]" True True
				call :downFile "%~f0" "!path_agent!" "%path_Temp%\agent.msi"
				call :writeLog INFO downloadAgent "[!path_agent!] 下载状态是: [!returnValue!]" True True 
				set path_agent=%path_Temp%\agent.msi

				call :writeLog INFO downloadAgentConfig "开始下载Agent config: [!path_agent_config!]" True True
				call :downFile "%~f0" "!path_agent_config!" "%path_Temp%\install_config.ini"
				call :writeLog INFO downloadAgentConfig "!path_agent_config! 下载状态是: [!returnValue!]" True True 
				set path_agent_config=%path_Temp%\install_config.ini
			)
			if not exist "!path_agent!" (
				call :writeLog ERROR installAgent "未找到可使用的路径:[!path_agent!]" True True
			) else (
				set tmp_params_msiexec=%params_msiexec%
				if not exist !path_agent_config! (
					if "#%argsGui%"=="#True" (
						call :writeLog ERROR installAgent "未找到配置文件 [!path_agent_config!],请手动输入服务器信息" True True
						set params_msiexec=/norestart
					)
				)
				call :writeLog INFO installAgent "开始安装Agent: [!path_agent!]" True True
				call :msiInstall "!path_agent!" "!params_msiexec!" "%params_agent%"
				call :writeLog DEBUG installAgent "Agent [!path_agent!] 安装退出码:[!errorlevel!]" False True
				call :writeLog INFO installAgent "Agent [!path_agent!] 安装状态是:[!returnValue!]" True True
				set params_msiexec=!tmp_params_msiexec!
				if "#!returnValue!"=="#False" (call :writeLog ERROR agentInstall "Agent [!path_agent!] 安装状态是:[失败],请检查系统环境或联系管理员" True True)
				if "#!returnValue!"=="#False" (set exitCode=6) else (set exitCode=0)
			)
		) else (
			call :writeLog INFO installAgent "Agent 版本 [!agentCurrentVersionDot!] 小于或等于当前已安装的版本,无需再次安装" True True
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
				if "#!returnValue!"=="#False" (call :writeLog ERROR installProduct "安全产品 [!path_product!] 安装状态是:[失败],请检查系统环境或联系管理员" True True)
				if "#!returnValue!"=="#False" (set exitCode=11) else (set exitCode=0)
			)
		) else (
			call :writeLog INFO installProduct "安全产品版本 [!productInstallVersionDot!] 小于或等于当前已安装的版本,无需再次安装" True True
			set exitCode=0
		)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)
)

:esetSkip

rem 删除已下载的临时文件
if "#%argsRemove%"=="#True" (
	call :writeLog INFO delTempFile "开始删除临时文件" True True
	pushd %path_Temp%
	for %%a in (*.msi *.cab) do (
		del /f /q %%a
	)
	popd
)

rem 抓取ESET安装日志
if "#%argsEsetLog%"=="#True" (
	if not !ntVerNumber! lss 61 (
		call :writeLog INFO prinyEsetLog "开始打印 ESET 安装日志" True True
		powershell -c "& {Get-EventLog Application -Message *ESET* -Newest 6|Format-List timegenerated,message}"
	) else (
		call :writeLog WARNING prinyEsetLog "此功能不适用于,Windows XP 和 Windows server 2003 系统" True True
		set exitCode=2
	)
)

rem 打印系统状态
if "#%argsSysStatus%"=="#True" (
	call :writeLog INFO printSysStatus "开始打印系统状态" True True
	call :getStatus
	set exitCode=0
)

rem 打印当前版本
if "#%argsVersion%"=="#True" (
	call :writeLog DEBUG printVersion "Current version: %version%" False True
	echo Current version: %version%
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

rem 测试函数,开启debug模式此处代码将被执行
 if %DEBUG%==True (
	call :getDownUrl
	call :debug

	set exitCode=999
 )
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

rem 获取 gui 界面,返回;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.*************************************************
echo.*						*
echo.*	a.自动检查安装 补丁+Agent+安全产品	*
echo.*	y.安装旧版本 (v6.5)			*
echo.*	o.安装补丁				*
echo.*	g.安装 Agent				*
echo.*	p.安装安全产品				*
echo.*	n.卸载 Agent				*
echo.*	d.卸载 安全产品				*
echo.*	e.进入安全模式				*
echo.*	x.退出安全模式				*
echo.*	t.抓取ESET安装日志			*
echo.*	s.检查状态				*
echo.*	i.卸载其他软件				*
echo.*	v.打印当前脚本版本			*
echo.*	h.显示命令行帮助			*
echo.*	kermit.yao@outlook.com			*
echo.*						*
echo.*************************************************
echo.
echo.
set /p input=请选择:(a^|y^|o^|p^|n^|d^|e^|x^|g^|t^|s^|^i^|v^|h):
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
	call :writeLog ERROR getGuiHelp "选择错误:[!input!]" True True
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

::多重变量获取
:getVar
set %1=!%2!
goto :eof

rem 获取点分版本号; 传入参数:%1 = 点分版本号, %2 = 点分的多少节;例：call :getVersionPrefix "10.1.2"; 返回值: versionPrefixDot = 点分版本,前两个节点, versionPrefix = 点分版本乘以 10000
:getVersionPrefix
for /f "delims=. tokens=1-2" %%a in ("%~1") do (
	set versionPrefixDot=%%a.%%b
	set /a dotVersion=%%b*10000
	set versionPrefix=%%a!dotVersion!
)

goto :eof

rem 卸载第三方杀毒软件
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
						call :writeLog INFO avUninst "启动【%%b】卸载程序: !tempMsg!" True True
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
				call :writeLog INFO avUninst "启动【%%b】卸载程序: msiexec /x {!avCode!}" True True
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

rem 当满足一定条件时,调用获取系统信息函数以提高运行效率.
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



rem 获取当前系统所需下载链接; 传入参数:无需传入；例：call :getDownUrl ; 返回值: 无,相应含量将被赋值: path_product, path_agent, hotfix_kb4490628, hotfix_kb4474419
:getDownUrl

rem 获取服务器或PC链接
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

rem 获取64或32平台链接

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

rem 根据系统版本判断相应链接
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

rem 格式化版本,便于后续计算;传入参数: % = 版本号；例：call :formatVersion 9.12 ; 返回值: 变量: versionNoDot,versionDot 将被赋值

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

echo 计算机名称:!computerName!
echo 系统版本:!sysVersion!
echo NT内核版本:!ntVer!
echo 系统类型:!sysType!
echo IP 地址列表:!ipList!
if not "#!sysVersion!"=="#WindowsXP" (
	call :setSafeBoot status
	echo 是否配置为安全模式:!safeModeStatus!
)

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
echo Agent 远程主机:%remoteHost%
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

rem 检查下载文件是否正确,通过检测文件大小判断; 传入参数: 文件路径 ; 例: call :checkFileSize "%temp%\esetInst\eea.msi" ; 返回值: returnValue=True | False
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

