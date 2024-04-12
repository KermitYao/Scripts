1>1/* ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Net session >nul 2>&1 || (echo Start-Process  -FilePath %~fs0   -verb  runas | powershell - &exit)

goto :begin
::* 此脚本可以自动安装360epp客户端,主要用于批量安装、域控等自动安装场景
::* 2022-10-30 脚本完成
::* 2022-11-28 1.新增 自动弹出其他安全软件卸载程序
::* 2022-12-25 1.修复 软件卸载功能现在可以支持msi格式的安装包了（国外软件常用）使用｛ESET Management Agent｝方式指定
::* v2.0.0_20230310_beta
	1.重构部分代码
	2.新增 现在可以通过命令行参数来使用脚本了
	3.新增 新增了支持功能,方便排查问题
	4.修复 某些情况下使用js下载失败,但是未能切换到powershell下载的问题。

::* v2.1.1_20230515_beta
	1.新增 现在可以根据不通的客户端ip地址自动选择不同的下载连接了,用于多服务器负载的场景
	2.修复 卸载是提示未安装实际已安装的问题
:begin

cls
@set version=v2.1.1_20230515_beta
@echo off
title 360Inst tool.
setlocal enabledelayedexpansion

::-----------user var-----------

rem 设置360智能安装包下载地址,以冒号分隔字段, 第一个字段为匹配的ip内容,多个ip用空格分隔,第二个字段为下载连接;如果无论本地ip是什么都用这个连接则第一个字段写 "." 一个点即可,点表示匹配所有内容
rem 如 192.168.1.和192.168.2. 开头的ip,使用sdUrl_1 变量的链接则: sdUrl_1=192.168.1. 192.168.2.:http://yjyn.top:8081/online/Ent_360EPP1383860355[360epp.yjyn.top-8084]-W.exe
rem 尽量填写更多的内容,匹配更加精准.最多可以写20个, sdUrl_1 - sdUrl_20
set sdUrl_1=10.152. 10.153. 10.154. 172.22. 172.23. 172.24.:http://10.152.9.185:8081/online/Ent_360EPP689218535[10.152.9.185-8080]-W.exe
set sdUrl_2=10.155. 10.156. 10.157. 172.25. 172.26. 172.27.:http://10.152.9.220:8081/online/Ent_360EPP689218535[10.152.9.220-8080]-W.exe
set sdUrl_3=10.158. 10.159. 172.28. 172.29.:http://10.152.10.97:8081/online/Ent_360EPP689218535[10.152.10.97-8080]-W.exe

rem 开启此参数，命令行指定参数和gui选择将会失效;
rem 相当于强制使用命令行参数；
rem 如果不需要保持为空即可
rem 使用方法 ： SET DEFAULT=-o --agent -l --remove -, 与正常的cmd参数保持一致
SET DEFAULT_ARGS=-i -p -s -u
::-----------user var-----------

rem ----------- init -----------
rem 日志等级 DEBUG|INFO|WARNING|ERROR
set logLevel=DEBUG

rem 调试开关
set DEBUG=False
set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem 解析参数列表
set argsList=argsHelp argsProduct argsUndoProduct argsSysStatus argsLog argsRemove argsGui argsAvUninst argsVersion

rem 临时文件和日志存放路径
set path_Temp=%temp%\360inst

rem 记录初始命令行参数
set srcArgs=%*

if "#%DEFAULT_ARGS%"=="#" (
	set args=%srcArgs%

) else (
	set args=%DEFAULT_ARGS%
)
set initProductName=360终端安全管理系统
rem 下载文件阈值,小于多少判定为下载失败,  单位kb
set errorFileSize=4

if not exist %path_Temp% md %path_Temp%

if "#%args%"=="#" (
	call :getGuiHelp
	if "#%DEFAULT_ARGS%"=="#" (set args=!returnValue!) 
)
call :getArgs %args%

rem 用于启动第三方杀毒软件卸载程序,本质是搜索注册表键值,如果存在相应的键值,则启动卸载程序
rem 以键的方式配置, "产品名称:注册表键值名称", 如果是msi类安装程序建议使用 {程序安装代码或名称},脚本会自动搜索 wimc product 进行匹配
set avList= "360安全卫士:360安全卫士" "360杀毒:360SD" "腾讯电脑管家:QQPCMgr" "火绒安全软件:HuorongSysdiag" "亚信安全:OfficeScanNT" "金山毒霸:Kingsoft Internet Security" "赛门铁克:{Symantec Endpoint Protection}" "ESET代理:{ESET Management Agent}" "ESET 杀毒:{ESET Endpoint Antivirus}"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

rem 下载文件阈值,小于多少判定为下载失败,  单位kb
set errorFileSize=4

rem ----------- init -----------

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
call :getUac

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

rem 卸载 Product
if "#%argsUndoProduct%"=="#True" (
	call :writeLog INFO uninstallProduct "开始处理安全产品卸载" True True
	if "#!uacStatus!"=="#True" (
		if "#!productName!"=="#" (
			call :writeLog WARNING uninstallProduct "【%initProductName%】 未安装,无需卸载" True True
		) else (
			call :writeLog INFO uninstallProduct "开始卸载 [!productName!]" True True

			set tempAvList=%avList%
			set avList="%initProductName%:360EPPX"
			call :avUninst
			set avList=%tempAvList%
			call :writeLog INFO uninstallProduct "如果有弹出卸载窗口,请请手动点击卸载程序选项进行卸载..." True True
		)
		if "#!returnValue!"=="#False" (set exitCode=8) else (set exitCode=0)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)		
)

rem 安装Product

if "#%argsProduct%"=="#True" (
	call :getUrl "!ipList!"
	set sdUrl=!returnValue!
	for /f "delims=/ tokens=4" %%a in ("!sdUrl!") do (
		echo %%a|findstr "^Ent_360EPP[0-9]*\[.*\]-W.exe" >nul
		if !errorlevel! equ 0 set name_360=%%a
	)
	call :writeLog INFO installProduct "开始处理安全产品安装" True True
	if "#!uacStatus!"=="#True" (
		if "#%regStatus%+%processStatus%"=="#True+True" (
			call :writeLog INFO installProduct "安全产品版本 [%initProductName%] 已安装,无需再次安装" True True
			set exitCode=0
		) else (
			if "!name_360!"=="" (
				call :writeLog INFO installProduct "下载链接错误无法正确解析: [%initProductName%] 中止安装" True True
			) else (
				call :writeLog INFO downloadProduct "开始下载安全产品: [!sdUrl!]" True True
				call :downFile "%~f0" "!sdUrl!" "%path_Temp%\!name_360!"
				call :writeLog INFO downloadProduct "Product.msi 下载状态是: [!returnValue!]" True True 
				set path_product=%path_Temp%\!name_360!
			)
		)
		if not exist "!path_product!" (
			call :writeLog ERROR installProduct "未找到可使用的路径:[!path_product!],安全产品安装失败" True True
			set exitCode=11
		) else (
			call :writeLog INFO installProduct "开始安装安全产品: [!path_product!]" True True

			if "#%argsGui%"=="#True" (
				start /b "360Install" "!path_product!"
			) else (
				start /b "360Install" "!path_product!" /s
				
			)
			echo\
			echo 这个过程可能需要10分钟左右的时间,请稍后...
			echo\
			call :checkInstStatus 600
			if "!instStatus!"=="2" (
				call :writeLog ERROR installProduct "安全产品 [!path_product!] 安装状态是:[失败],请检查系统环境或联系管理员" True True
				set exitCode=11
			) else if "!instStatus!"=="1" (
				call :writeLog ERROR installProduct "安全产品 [!path_product!] 安装状态是:[超时],请检查系统环境或联系管理员" True True
				set exitCode=11
			) else if "!instStatus!"=="0" (
				call :writeLog ERROR installProduct "安全产品 [!path_product!] 安装状态是:[成功]" True True
				echo\
				echo 如果客户端未能正常启动,请重启电脑后即可正常启动.
				echo\
				set exitCode=0
			) else (
				call :writeLog ERROR installProduct "安全产品 [!path_product!] 安装状态是:[未知],请检查系统环境或联系管理员" True True
				set exitCode=11
			)
		)
	) else (
		call :writeLog ERROR uacStatus "你必须要以管理员身份运行此脚本,才能正常使用这些功能" True True
		set exitCode=96
	)
)

rem 删除已下载的临时文件
if "#%argsRemove%"=="#True" (
	call :writeLog INFO delTempFile "开始删除临时文件" True True
	pushd %path_Temp%
	for %%a in (*.exe *.error) do (
		del /f /q %%a
	)
	popd
)

rem 打印系统状态
if "#%argsSysStatus%"=="#True" (
	call :writeLog INFO printSysStatus "开始打印系统状态" True True
	call :getStatus
	set exitCode=0
)
goto :exitScript
rem exitCode: 正常:0,标准命令行报错:1,系统版本错误:2,系统平台错误:3,无法获取补丁包:4,有补丁安装失败或挂起:5,安装Agent失败:6,卸载agent失败:7,卸载product失败:8,进入安装模式失败:9,退出安装模式失败:10,安装product失败:11,Win7系统不是sp1:12，权限不足错误:96,参数错误:97,无法解析参数:98,未知错误:99
:exitScript


rem 测试函数,开启debug模式此处代码将被执行
 if %DEBUG%==True (
	call :debug
	set exitCode=999
 )
if "#%argsGui%"=="#True" (
	call :writeLog INFO argsList "argsList:[!args!]" False True
	call :writeLog INFO exit "脚本已完成,按任意键结束" True True
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
set valueList=sdUrl
for %%a in (!valueList!) do echo %%a:[!%%a!]

echo ----------URL-----------
echo.
echo --------------- debug ---------------
goto :eof

:getCmdHelp
echo  Usage: %~nx0 [options]
echo\
echo  -h,	--help		打印命令行帮助
echo  -p,	--product	安装【%initProductName%】
echo  -d,	--undoProduct	卸载【%initProductName%】
echo  -s,	--status	检查状态
echo  -l,	--log		关闭日志打印
echo  -r,	--remove	删除临时文件
echo  -i,    --avUninst	移除其他杀毒软件
echo  -u,	--gui		保留操作窗口
echo  -v,	--version	打印当前版本
echo.
echo		Example:%~nx0 -o --agent -l --remove
echo\
echo              Code by Kermit Yao @ Windows 11, 2023-03-8 ,jianyu.yao@ych-sh.com
goto :eof

rem 获取 gui 界面,返回;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.*************************************************
echo.*						*
echo.*	p.安装安全产品				*
echo.*	d.卸载 安全产品				*
echo.*	s.检查状态				*
echo.*	i.卸载其他软件				*
echo.*	v.打印当前脚本版本			*
echo.*	h.显示命令行帮助			*
echo.*	jianyu.yao@ych-sh.com			*
echo.*						*
echo.*************************************************
echo.
echo.
set /p input=请选择:(p^|d^|s^|^i^|v^|h):
for %%a in (p d s i v h) do (
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

	if /i "#%%a"=="#-p" set argsProduct=True
	if /i "#%%a"=="#--product" set argsProduct=True

	if /i "#%%a"=="#-d" set argsUndoProduct=True
	if /i "#%%a"=="#--undoProduct" set argsUndoProduct=True

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
	rem echo error
	rem echo %%a: !%%a!
)
goto :eof

::多重变量获取
:getVar
set %1=!%2!
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

rem 匹配ip格式;传入参数: %1 = ip; 例: call :matchIp 10.1.1.5; 返回值: returnValue=True | False
:matchIp
set flag=False
if not "%~1"=="" (
	echo "%~1" | findstr "^[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*$">nul&&echo flag=True
)
set returnValue=%flag%
set flag=
goto :eof

rem 根据不通ip获取杀毒下载连接;传入参数: %1 = ipList; 例: call :getUrl 10.1.1.5,10.1.1.6; 返回值: returnValue=下载连接
:getUrl
set flag=False
set returnValue=
for /l %%a in (1 1 20) do (
	if not "!sdUrl_%%a!"=="" (
		for /f "delims=: tokens=1*" %%x in ("!sdUrl_%%a!") do (
			echo "%~1"|findstr "%%x" >nul && set flag=True
			if "!flag!"=="True" (
				set returnValue=%%y
				goto :eof
			)
		)
	)
)
if "!flag!"=="False" (
	for /f "delims=: tokens=1*" %%x in ("!sdUrl_1!") do set returnValue=%%y
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
						call :writeLog INFO avUninst "启动【%%~b】卸载程序: !tempMsg!" True True
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
				echo\
				echo	等待卸载完成...
				echo\
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

:getStatus
set regStatus=False
set processStatus=False
echo 命令参数:%args%

call :getUac
call :getProductInfo

echo UAC权限:%uacStatus%
echo 计算机名称:%computerName%
echo 系统版本:%sysVersion%
echo NT内核版本:%ntVer%
echo 系统类型:%sysType%
echo IP 地址列表:%ipList%
echo 系统平台类型:%sysArch%

echo 产品名称:%productName%
echo 安装路径:%productPath%
echo 安装时间:%productInstTime%
echo 中心地址:%productConnectAddress%
echo 授权  ID:%productEppID%
echo 上次通讯:%productLastConnectTime%

if "#%regStatus%+%processStatus%"=="#True+True" (
	echo ***************** 【%initProductName%】安装正常 *****************
) else (
	echo ***************** 【%initProductName%】安装异常 *****************
)

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

rem 循环检查安装是否完成; 传入参数： %1 超时时间； 例： call :checkInstStatus 600; 返回值: instStatus = True | False
:checkInstStatus
set loopTimes=%1
set loopInit=1
set instStatus=3
:checkInstStatusLoop
set instProcessStatus=False
call :getProductInfo
tasklist /FO CSV /FI "IMAGENAME eq !name_360!" 2>nul|findstr /c:"!name_360!" >nul&& set instProcessStatus=True
if "%instProcessStatus%"=="True" (
	if "#%regStatus%+%processStatus%"=="#True+True" (
		set instStatus=0
		goto :checkInstStatusBreak
	) else (
		set /a loopInit+=1
		ping /n 2 127.0.0.1 >nul
	)
) else (
	if "#%regStatus%+%processStatus%"=="#True+True" (
		set instStatus=0
		goto :checkInstStatusBreak
	) else (
		set instStatus=2
		goto :checkInstStatusBreak
	)
)

if %loopInit% GEQ %loopTimes% (
	set instStatus=1
	goto :checkInstStatusBreak
)

goto :checkInstStatusLoop
:checkInstStatusBreak
goto :eof

rem 获取软件版本; 传入参数: %1 =Product | Agent ; 例：call :getVersion Product; 返回值:returnValue=版本号 | Null,如果产品存在则以下变量会被赋值：productCode,productName,productVersion,productDir
:getProductInfo
set productName=
set productPath=
set productInstTime=
set productConnectAddress=
set productEppID=
set productLastConnectTime=
set processStatus=False
set regStatus=False
tasklist /FI "IMAGENAME eq 360epp.exe" 2>nul|findstr "360epp.exe" >nul&& set processStatus=True
if "%sysArch%"=="x64" (
	set regPath="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\360Safe\360EntSecurity"
) else (
	set regPath="HKEY_LOCAL_MACHINE\SOFTWARE\360Safe\360EntSecurity"
)
reg query %regPath% /v MsgSrvIP >nul 2>&1
if %errorlevel% equ 1 goto :eof
for /f "tokens=1,2*" %%a in ('reg query %regPath% 2^>nul') do (
	if "%%a"=="ProductName" (set productName=%%c)
	if "%%a"=="InstPath" (set productPath=%%c)
	if "%%a"=="InstTime" (set productInstTime=%%c)
	if "%%a"=="MsgSrvIP" (set productConnectAddress=%%c)
	if "%%a"=="Partner" (set productEppID=%%c)
	if "%%a"=="SYSTEMConnectedTime" (set productLastConnectTime=%%c)
)
if not "#%productConnectAddress%"=="#" set regStatus=True
goto :eof

rem 当满足一定条件时,调用获取系统信息函数以提高运行效率.
:getSysInfo
set tmpArgsList_getSysVer=argsProduct argsSysStatus DEBUG 
for %%a in (%tmpArgsList_getSysVer%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		call :getSysVer
		goto :endGetSysVer
	)
)
:endGetSysVer

set tmpArgsList_getSysArch=argsProduct argsSysStatus argsUndoProduct DEBUG
for %%a in (%tmpArgsList_getSysArch%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		call :getSysArch
		goto :endGetSysArch
	)
)
:endGetSysArch

set tmpArgsList_getProductInfo=argsUndoProduct argsProduct
for %%a in (%tmpArgsList_getProductInfo%) do (
	if "#!%%a!"=="#True" (
		call :getProductInfo
		goto :endGetProductInfo
	)
)
:endGetProductInfo

set tmpArgsList_getDownUrl=argsProduct DEBUG
for %%a in (%tmpArgsList_getDownUrl%) do (
	if "#!%%a!"=="#True" (
		rem echo %%a: !%%a!
		goto :eof
	)
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