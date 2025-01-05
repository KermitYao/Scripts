1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

goto :begin

::* 系统支持 win7 | win8| win10 | win server 2003 | win server 2008 | win server 2012 | win server|2016 |win server 2019
::* 前置第三方组件 findstr | wmic | msiexec | dism | reg | powershell 
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

::* v2.0.3_20230412_beta
	1.修复 2008 已经无法支持最新版本,通过指定 9.0 版本解决。
	
::* v2.1.0_20240218_alpha
	1.新增 支持ACS补丁的自动判断和安装;与sha补丁集成在一起
	2.新增 现在支持指定参数来开启管理员请求权限了(GUI界面默认开启,CLI需要手动指定参数)
	3.更新 重构部分代码,现在可以根据bulidNumber安装不同的软件版本,修正判断逻辑,减少代码量。应对经常变化的版本
	4.更新 移除了对xp等6.5版本的支持,eset官方已不在对其进行支持
	5.更新 现在资源路径可以自动判断是http或者unc路径,无需手动指定(判断首字符是否包含http)
	6.修改 现在默认使用powershell进行下载,后续考虑移除js的下载支持

::* v2.1.1_20240220_alpha
	1.优化日志输出
	2.梳理代码逻辑

::* v2.1.2_20240617_beta
	1.修复-a参数,如有未安装补丁、或补丁需用重启时不会自动跳过后续下载安装的问题

::* v2.1.3_20240807_beta
	1.更新 现在补丁安装模块，会检查补丁的安装状态是否停留在挂起，以避免出现已安装未重启导致的重复安装问题。
::-----readme-----

快速使用:
	修改155行开始,设置每个版本文件的下载地址,然后双击打开脚本输入 a 开始自动安装

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
		具体是通过下载安装，或是本地文件安装
	2.可以使用参数 -h | -help 来查看支持的参数
	3.如果需要实现双击自动安装,可以设置 DEFAULT_ARGS, 例如: DEFAULT_ARGS= -a -s -u , 表示自动安装补丁、agent、杀毒产品,并且会显示出安装的状态,然后停留等待
	4.
		set version_Agent=11
		set version_Product_eea=11
		set version_Product_efsw=11
		以上三个参数标识了最新的版本,一般版本号和安装文件的版本保持一致.
		当计算机已经存在一个杀毒软件,如果低于以上版本则会自动升级,如果高于则跳过安装,如果计算机没有安装过杀毒软件则预设版本号为0
	5.本质上软件的安装是通过调用 msiexec 实现的,所以如果想自定义参数可以通过此参数实现: set "params_agent= password=eset1234." ,会指定一个密码,当然也可以用别的参数,比如指定安装时的语言，可以写入多个参数，以空格隔开即可
	6. 这个参数 set path_agent_config 指定的文件,来自于gpo配置文件,这个文件和agent安装程序放在同一个目录,安装的时候就可以不用手动填写证书、密码等之类的东西，可以通过eset控制台生成
	7.脚本的运行需要管理员权限
	8.命令行参数不区分大小写
	9.安装的时候脚本会自动检测需要下载(%temp%\esetInst)的对应版本,不会多下载的,所以如果没有 xp 系统,完全可以不填写 6.5 的文件下载地址;这样并不会影响使用
	10.想到了再写

:begin
::-----readme-----

cls
@set version=v2.1.3_20240807_beta
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
set argsList=argsHelp argsAll argsEarly argsHotfix argsProduct argsAgent argsUndoAgent argsUndoProduct argsEntrySafeMode argsExitSafeMode argsSysStatus argsEsetLog argsForce argsLog argsRemove argsGui argsAvUninst argsVersion argsUac
::----------------------------------

rem ----------- init -----------
rem 设置初始变量
:getPackagePatch

rem 已安装的软件版本如果小于此本版则进行覆盖安装,否则不进行安装(升级)
rem 版本号只计算两位，超过两位数会计算出错。
set version_Agent=11.0
set version_Product_eea=11.0
set version_Product_efsw=11.0
rem -------------------

rem 如果路径为UNC或可访问路径则不需要下载到本地,将直接调用安装；否则会下载到临时目录在使用绝对路径方式调用
rem 如果是共享目录可以设置账号密码，来首先建立ipc$连接，然后在使用UNC路径方式调用。如果为空则不进行IPC$连接。
set shareUser=
set sharePwd=

rem 用于启动第三方杀毒软件卸载程序,本质是搜索注册表键值,如果存在相应的键值,则启动卸载程序
rem 以键的方式配置, "产品名称:注册表键值名称"
set avList= "360安全卫士:360安全卫士" "360杀毒:360SD" "腾讯电脑管家:QQPCMgr" "火绒安全软件:HuorongSysdiag" "亚信安全:OfficeScanNT" "金山毒霸:Kingsoft Internet Security" "赛门铁克:{Symantec Endpoint Protection}"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem 此处设置用于下载文件的地址
rem --------AGENT START--------
rem 所有的路径不要携带 "" 引号，后续会自动处理引号问题;同时 "%" 在脚本里有特殊意义，如果网址内包含空格需要将 "%" 进行双写转义
rem Agent 下载地址

rem win7系统专用agent,建议使用最高版本： v10.1292
set path_agent_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x86_v10.1.msi
set path_agent_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x64_v10.1.msi

rem 最新版本agent,建议使用最新版本
set path_agent_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x86_later.msi
set path_agent_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/agent_x64_later.msi

rem Agent 配置文件
set path_agent_config=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Agent/None

rem 追加参数,不需要则保持为空
::set params_agent=password=eset1234.
set params_agent=
rem --------AGENT END--------

rem --------PC product START--------
rem PC Product 下载地址

rem Win7系统专用杀毒软件,支持最高版本:v9.1
set path_pc_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_v9.1.msi
set path_pc_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_v9.1.msi

rem 建议使用最新版本
set path_pc_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt32_later.msi
set path_pc_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/PC/eea_nt64_later.msi
rem --------PC product END--------

rem --------Server product START--------
rem SERVER Product 下载地址

rem Server2008系统专用杀毒软件,使用 v9.0
set path_server_nt61_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_v9.0.msi
set path_server_nt61_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_v9.0.msi

rem 建议使用最新版本
set path_server_late_x86=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt32_later.msi
set path_server_late_x64=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/CLIENT/Server/efsw_nt64_later.msi
rem --------Server product END--------

rem 追加参数,不需要则保持为空,PC 和 SERVER 版本共用同一个追加参数
::set params_eea=password=eset1234.
set params_product=

rem --------patch START--------
rem 补丁文件 下载地址目录
set path_hotfix_url=http://files.yjyn.top:6080/Company/YCH/EEAI/ESET/OTHER/hotfix/

rem --------patch END--------

rem -------------------

rem 临时文件和日志存放路径
set path_Temp=%temp%\esetInstall

rem 安装 cab 的默认参数
set params_hotfix=/norestart

rem 记录初始命令行参数
set flagArgs=%*
rem 移除uac请求添加的标志参数
if not "%*"=="" (set noFlagArgs=%flagArgs:-runas=%)
set srcArgs=%noFlagArgs%

if "#%DEFAULT_ARGS%"=="#" (
	set args=%srcArgs%
) else (
	set args=%DEFAULT_ARGS%
)

rem 下载文件阈值,小于多少判定为下载失败,  单位kb
set errorFileSize=4
rem 初始化系统版本,避免空参数导致的if 对比报错
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

if "%argsUac%"=="True" (
	if not "!isGetAdmin!"=="True" (
		call :getAdmin %*
	)
)

if "#%argsForce%"=="#True" set uacStatus=True
rem 进入安全模式
if "#%argsEntrySafeMode%"=="#True" (
	call :writeLog INFO setSafeBoot "开始配置安全模式" True True
	if "#!uacStatus!"=="#True" (
		if not %ntVerNumber% lss 7600 (
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
		call :writeLog ERROR uacStatus "你必须以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)
)

rem 退出安全模式
if "#%argsexitSafeMode%"=="#True" (
	call :writeLog INFO exitSafeMode "开始清除安全模式" True True
	if "#!uacStatus!"=="#True" (
		if not %ntVerNumber% lss 7600 (
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
		call :writeLog ERROR uacStatus "你必须以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)	
)

rem 卸载第三方安全软件
if "#%argsAvUninst%"=="#True" (
	call :writeLog INFO removeAV "开始处理第三方安全软件卸载" True True
	if "#!uacStatus!"=="#True" (
		call :writeLog DEBUG removeAV "开始扫描第三方安全软件..." True True
		call :avUninst
		if "!avUninstFlag!"=="" (
			call :writeLog INFO removeAV "未扫描到其他安全软件." True True
		) else (
			call :writeLog INFO removeAV "如果有弹出卸载窗口,请手动点击卸载程序选项进行卸载." True True
			if "#%argsGui%"=="#True" (
				call :writeLog INFO removeAV "按任意键进行下一步操作." True True
				pause >nul
			) 
		)
	) else (
		call :writeLog ERROR uacStatus "你必须以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)		
)

rem 卸载 Agent
if "#%argsUndoAgent%"=="#True" (
	call :writeLog INFO removeAgent "开始处理Agent卸载" True True
	if "#!uacStatus!"=="#True" (
		call :getVersion Agent
		if "#!productCode!"=="#" (
			call :writeLog INFO removeAgent "ESET Management Agent 未安装,无需卸载" True True
		) else (
			call :writeLog INFO removeAgent "开始卸载 [!productName!]" True True
			call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
			call :writeLog DEBUG removeAgent "[!productName!] 卸载退出码:[!errorlevel!]" False True
			call :writeLog INFO removeAgent "[!productName!] 卸载状态:[!returnValue!]" True True
			if "#!returnValue!"=="#False" (call :writeLog ERROR removeAgent "[!productName!] 卸载状态:[失败],请检查安装状态或联系管理员" True True)
		)
		if "#!returnValue!"=="#False" (set exitCode=7) else (set exitCode=0)
	) else (
		call :writeLog ERROR uacStatus "你必须以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)		
)

rem 卸载 Product
if "#%argsUndoProduct%"=="#True" (
	call :writeLog INFO removeProduct "开始处理安全产品卸载" True True
	if "#!uacStatus!"=="#True" (
		call :getVersion Product
		if "#!productCode!"=="#" (
			call :writeLog WARNING removeProduct "ESET Product 未安装,无需卸载" True True
		) else (
			call :writeLog INFO removeProduct "开始卸载 [!productName!]" True True
			call :uninstallProduct "!productCode!" "%params_msiexec%" "%params_agent%"
			call :writeLog DEBUG removeProduct "[!productName!] 卸载退出码:[!errorlevel!]" False True
			call :writeLog INFO removeProduct "[!productName!] 卸载状态:[!returnValue!]" True True
			if "#!msiexecExitCode!"=="#3010" (call :writeLog WARNING removeProduct " [!productName!] 卸载状态:[挂起],你需要重启以完成卸载" True True)
		)
		if "#!returnValue!"=="#False" (set exitCode=8) else (set exitCode=0)
	) else (
		call :writeLog ERROR uacStatus "你必须以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)		
)

rem 安装补丁
if "#%argsHotfix%"=="#True" (
	set hotFixFlag=False
	call :writeLog INFO instHotfix "开始处理补丁" True True
	if "#!uacStatus!"=="#True" (
		call :hotfixKey
		if %ntVerNumber% lss 7601 (
			call :writeLog WARNING instHotfix "版本小于:win7sp1/7601 将无法安装SHA-2补丁,建议升级系统到最新" True True
			goto :esetSkip
		)
		if %ntVerNumber% geq 19044 (
			call :writeLog INFO instHotfix "版本大于:21H2/19044 无需安装ACS补丁" True True
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
						call :writeLog INFO instHotfix "补丁安装完成,请重启电脑后继续后续操作." True True
						rem 如果需要重启,或有补丁安装失败,设置跳过标志						
						set hotFixFlag=True
					)
				if "#!returnValue!"=="#False" (
					call :writeLog ERROR instHotfix "补丁安装失败,请联系管理员处理." True True
					rem 如果需要重启,或有补丁安装失败,则设置跳过标志
					set hotFixFlag=True
					)
				)
			)
		)
		if "#!hotFixFlag!"=="#True" (
			rem 如果需要重启,或有补丁安装失败,则跳过agent和product的安装过程
			goto :esetSkip
			)
		if not "!keyFlag!"=="True" (
			call :writeLog WARNING instHotfix "补丁处理完毕,未能匹配当前系统版本,请联系相关人员处理" True True
			goto :esetSkip
		)
	) else (
		call :writeLog ERROR uacStatus "你必须以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)
)
:hotfixSkip

rem 安装Agent
if "#%argsAgent%"=="#True" (
	call :writeLog INFO instAgent "开始处理Agent安装" True True
	if not %ntVerNumber% LSS 7601 (
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
				call :getLinkType "!%path_agent%!"
				if not "!linkType!"=="url" (
					call :connectShare "!%path_agent%!" %shareUser% %sharePwd%
					call :writeLog INFO connectShare "Agent 共享连接状态是: [!returnValue!]" False True 
					set path_agent=!%path_agent%!
				) else (
					call :writeLog INFO downloadAgent "开始下载Agent: [!%path_agent%!]" True True
					call :downFile "%~f0" "!%path_agent%!" "%path_Temp%\agent.msi"
					call :writeLog INFO downloadAgent "[!%path_agent%!] 下载状态是: [!returnValue!]" True True 
					set path_agent=%path_Temp%\agent.msi
				)

				call :getLinkType "!path_agent_config!"
				if not "!linkType!"=="url" (
					call :connectShare "!path_agent_config!" %shareUser% %sharePwd%
					call :writeLog DEBUG connectShare "Agent 配置 共享连接状态是: [!returnValue!]" False True
					set path_agent_config=!path_agent_config!
				) else (
					call :writeLog INFO downloadAgentConfig "开始下载Agent config: [%path_agent_config%]" True True
					call :downFile "%~f0" "%path_agent_config%" "%path_Temp%\install_config.ini"
					call :writeLog INFO downloadAgentConfig "%path_agent_config% 下载状态是: [!returnValue!]" True True 
					set path_agent_config=%path_Temp%\install_config.ini
				)

				if not exist "!path_agent!" (
					call :writeLog ERROR instAgent "未找到可使用的路径:[!path_agent!]" True True
				) else (
					set tmp_params_msiexec=%params_msiexec%
					if not exist !path_agent_config! (
						if "#%argsGui%"=="#True" (
							call :writeLog ERROR instAgent "未找到配置文件 [!path_agent_config!],请手动输入服务器信息" True True
							set params_msiexec=/norestart
						)
					)
					call :writeLog INFO instAgent "开始安装Agent: [!path_agent!]" True True
					call :msiInstall "!path_agent!" "!params_msiexec!" "%params_agent%"
					call :writeLog DEBUG instAgent "Agent [!path_agent!] 安装退出码:[!errorlevel!]" False True
					call :writeLog INFO instAgent "Agent [!path_agent!] 安装状态是:[!returnValue!]" True True
					set params_msiexec=!tmp_params_msiexec!
					if "#!returnValue!"=="#False" (call :writeLog ERROR instAgent "Agent [!path_agent!] 安装状态是:[失败],请检查系统环境或联系管理员" True True)
					if "#!returnValue!"=="#False" (set exitCode=6) else (set exitCode=0)
				)
			) else (
				call :writeLog INFO instAgent "Agent 版本 [!agentCurrentVersionDot!] 已是最新" True True
				set exitCode=0
			)
		) else (
			call :writeLog ERROR uacStatus "你必须以管理员身份运行此脚本,才能正常使用这些功能" True True
			set exitCode=96
		)
	) else (
		call :writeLog ERROR instAgent "AGENT 不在支持当前系统版本!" True True
		set exitCode=101
	) 
)

rem 安装Product
if "#%argsProduct%"=="#True" (
	call :writeLog INFO instProduct "开始处理安全产品安装" True True
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
					call :writeLog DEBUG connectShareConnect "Product 共享连接状态是: [!returnValue!]" False True 
				) else (
					call :writeLog INFO downloadProduct "开始下载安全产品: [!%path_product%!]" True True
					call :downFile "%~f0" "!%path_product%!" "%path_Temp%\product.msi"
					call :writeLog INFO downloadProduct "安全产品下载状态是: [!returnValue!]" True True 
					set path_product=%path_Temp%\product.msi
				)
				if not exist "!path_product!" (
					call :writeLog ERROR instProduct "未找到可使用的路径:[!path_product!],安全产品安装失败" True True
					set exitCode=11
				) else (
					call :writeLog INFO instProduct "开始安装安全产品: [!path_product!]" True True
					call :msiInstall "!path_product!" "%params_msiexec%" "%params_product%"
					call :writeLog DEBUG instProduct "安全产品 [!path_product!] 安装退出码:[!errorlevel!]" False True
					call :writeLog INFO instProduct "安全产品 [!path_product!] 安装状态是:[!returnValue!]" True True
					if "#!returnValue!"=="#False" (call :writeLog ERROR instProduct "安全产品 [!path_product!] 安装状态是:[失败],请检查系统环境或联系管理员" True True)
					if "#!returnValue!"=="#False" (set exitCode=11) else (set exitCode=0)
				)
			) else (
				call :writeLog INFO instProduct "安全产品版本 [!productInstallVersionDot!] 已是最新" True True
				set exitCode=0
			)
		) else (
			call :writeLog ERROR uacStatus "你必须以管理员身份运行此脚本,才能正常使用这些功能" True True
			set exitCode=96
		)
	) else (
		call :writeLog ERROR instAgent "安全产品 不在支持当前系统版本!" True True
		set exitCode=101
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
	if not %ntVerNumber% lss 7600 (
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
	call :getSysInfo
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
echo  -h,	--help		[optional] 打印命令行帮助
echo  -a,	--all		[optional] 自动检查安装 补丁+Agent+安全产品
echo  -y,	--early		[optional] 安装旧版本 (v9.x)	
echo  -o,	--hotfix	[optional] 安装补丁
echo  -g,	--agent		[optional] 安装 Agent
echo  -p,	--product	[optional] 安装安全产品
echo  -n,	--undoAgent	[optional] 卸载 Agent
echo  -d,	--undoProduct	[optional] 卸载 安全产品	
echo  -e,	--entrySafeMode	[optional] 进入安全模式
echo  -x,	--exitSafeMode	[optional] 退出安全模式
echo  -t,	--esetlog	[optional] 抓取ESET安装日志	
echo  -s,	--status	[optional] 状态检查
echo  -f,	--force		[optional] 强制略过检查模块
echo  -c,	--uac		[optional] 以管理员身份运行脚本
echo  -l,	--log		[optional] 关闭日志
echo  -r,	--remove	[optional] 移除临时文件
echo  -i,    --avUninst	[optional] 移除其他安全软件
echo  -u,	--gui		[optional] 脚本执行完成后停留
echo  -v,	--version	[optional] 打印当前脚本版本
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
echo.*	y.安装旧版本 (v9.x)			*
echo.*	o.安装补丁				*
echo.*	g.安装 Agent				*
echo.*	p.安装安全产品				*
echo.*	n.卸载 Agent				*
echo.*	d.卸载 安全产品				*
echo.*	e.进入安全模式				*
echo.*	x.退出安全模式				*
echo.*	t.抓取ESET安装日志			*
echo.*	s.状态检查				*
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

set path_product=
set path_agent=
set path_agent_config=%path_agent_config%

rem 获取agent资源地址
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

rem 获取product资源地址
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

rem 获取资源类型, 解析传入参数; 传入参数: %1 = 资源连接；例：call :getLinkType %path_agent_old_x64% ; 返回值: url|null
:getLinkType
set tmpLink=%~1
set tmpLink=%tmpLink: =%
for /f "delims=:" %%a in ("%tmpLink%") do (
	if "%%a"=="http" set linkType=url
	if "%%a"=="https" set linkType=url
)
set returnValue = %linkType%
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

rem 判断是否安装补丁; 传入参数: 补丁号列表 = "补丁号 补丁号"；例：call :getHotfixStatus "KB4474419 KB4490628" ; 返回值:无返回值，但是如果查找到对应的补丁号存在则传入的补丁后会被赋值为以下状态: InstallPending|Installed|False，如 KB4474419=True
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

rem 获取系统版本和补丁对应键值
:hotfixKey
set hotfixKey=win7sp1/2008r2:7601:kb4490628_kb4474419  #  win8.1/ws2012:9200:kb5001401_kb5006732  #  win8.1/ws2012r2:9600:kb5006729  #  1507:none:none  #  1511:10586:none  #  1607:14393:none  #  1703:15063:none  #  1709:16299:none  #  1803:17134:none  #  1809/ws2019:17763:kb5005112_kb5005625  #  1903:10.0.18362:none  #  1909:18363:kb5004748_kb5005624  #  2004/20H1:19041:kb5005260_kb5005611  #  20H2/2009:19042:kb5005260_kb5005611  #  21H1:19043:kb5005260_kb5005611 # SERVER2022/21H2:20348:kb5005619
set hotfixKey=%hotfixKey: =%
set hotfixKey=%hotfixKey:#= %

::win7sp1/2008r2:7601:kb4490628_kb4474419_kb4575903_kb4570673_kb5006728 
goto :eof

rem 补丁安装过程
:hotfixInst
call :writeLog INFO instHotfix "开始处理补丁安装过程..." True True
set hotfixList=%~3
set hotfixList=%hotfixList:_= %
call :writeLog INFO instHotfix "系统类型: %~1, bulidNumber:%~2, 补丁安装列表: %hotfixList%" True True
if "#%hotfixList%"=="#none" (
    call :writeLog WARNING instHotfix "未获取到需要安装的补丁列表,暂不支持此系统,建议升级到更高版本" True True
    set returnValue=False
    goto :eof
)
call :writeLog INFO instHotfix "正在扫描系统补丁..." True True

call :getHotfixStatus "%hotfixList%"

for %%a in (%hotfixList%) do (
    if "#!%%a!"=="#Installed" (
        call :writeLog INFO instHotfix "补丁 [%%a] 已经存在,无需重复安装" True True
        set exitCode=0
		)

    if "#!%%a!"=="#InstallPending" (
        call :writeLog INFO instHotfix "补丁 [%%a] 已安装,但处于[挂起]状态,请重启电脑后继续运行当前脚本." True True
		set hotFixFlag=True
		set returnValue=True
        set exitCode=0
		)

    if "#!%%a!"=="#False" (
		call :getLinkType "%path_hotfix_url%"
		if not "!linkType!"=="url" (
			call :connectShare "%path_hotfix_url%" %shareUser% %sharePwd%
			call :writeLog DEBUG connectShare "补丁 %%a 共享连接状态是： [!returnValue!]" False True 
			set hotfix_%%a="%path_hotfix_url%hotfix_%%a_%sysArch%.cab"
		) else (
			call :writeLog INFO downloadHotfix "开始下载补丁: [%%a]" True True
			call :downFile "%~f0" "%path_hotfix_url%hotfix_%%a_%sysArch%.cab" "%path_Temp%\hotfix_%%a_%sysArch%.cab"
			call :writeLog INFO downloadHotfix "补丁 [[%%a]] 下载状态是: [!returnValue!]" True True 
			set hotfix_%%a="%path_Temp%\hotfix_%%a_%sysArch%.cab"
		)

        if not exist "!hotfix_%%a!" (
            call :writeLog ERROR instHotfix "未找到可使用的路径:[!hotfix_%%a!],终止安装" True True
            set returnValue=False
            goto :eof
        ) else (
            call :writeLog INFO instHotfix "开始安装补丁: [%%a]" True True
            call :hotFixInstall "!hotfix_%%a!" "%params_hotfix%"
            call :writeLog DEBUG instHotfix "hotfix [%%a] 安装退出码:[!errorlevel!]" False True
            call :writeLog INFO instHotfix "这个补丁 [%%a] 安装状态是:[!returnValue!]" True True
            if "#!dismExitCode!"=="#3010" (
                call :writeLog WARNING instHotfix "这个补丁 [%%a] 安装状态是:[挂起],你需要重启才能进行后续安装" True True
		set returnValue=True
                goto :eof
            )
        )
    )
)

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

echo 补丁状态列表:

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
	echo   当前系统无补丁需要安装或暂不支持
) else (
	if "#!hotfixList!"=="#none" (
    	echo   暂不支持此系统,建议升级到更高版本
	) else (
		set hotfixList=!hotfixList:_= !
		call :getHotfixStatus "!hotfixList!"
		for %%a in (!hotfixList!) do (
			if "#!%%a!"=="#Installed" (
			    echo   %%a 已安装
			)
			if "#!%%a!"=="#InstallPending" (
			    echo   %%a 已挂起^(待重启^)
			)
			if "#!%%a!"=="#False" (
			    echo   %%a 未安装
			)
		)
	)
)

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
	rem 判断是否已触发权限请求
	set isGetAdmin=True
	for %%a in (%*) do set runasflag=%%a
	if not "!runasflag!"=="-runas" (
		call :writeLog INFO getAdmin "请求管理员权限" True True
		call :runAsAdmin %*
		if "!runAsAdminFlag!"=="True" (
			call :writeLog DEBUG getAdmin "权限获取成功" True True
			exit
		) else (
			call :writeLog WARNING getAdmin "请求权限失败,将以普通权限运行." True True
			call :getUac
		)
	)
)
goto :eof

rem 使用管理员身份运行当前脚本,可以传递参数,但参数不能包含"双引号，如果不使用runas，则可以使用双引号 ['a b c  "a b c"'];返回值: returnValue=True|False
rem 调用的时候需要传递%*,将命令行参数传递给函数
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

rem 写入日志; 传入参数: %1 = 消息类型， %2 = 标题, %3 = 消息文本， %4 = True 写入标准输出 | False，%5 = True 写入日志文件 | False; 例：call :writeLog witeLog ERROR "This is a error message." True False; 返回值:无返回值
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

rem 获取格式化时间 YYYY/MM/DD HH:MM, 无需传入参数，调用后 dt会被赋值
:getFormatTime
set formatTime=
for /f "delims==. tokens=2" %%a in ('wmic os get localdatetime /value')  do set dt=%%a
set dt=!dt:~0,4!/!dt:~4,2!/!dt:~6,2! !dt:~8,2!:!dt:~12,2!
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

