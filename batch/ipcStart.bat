
::* 此脚本可以指定一个程序通过IPC$的方式在别的客户端上执行.
::* 2022-11-30 脚本完成
::* 2022-12-09 1.更新 使 -c 参数可以支持一个包含地址列表的文本,即 -c 参数的值会进行判断，如果发现是文件则解析文本,如果非文件，则把值当作地址使用;2.更新 优化脚本逻辑,精简代码
::* 2022-12-24 1.新增 新增 -m参数, 此参数可以指定一个文件启动方式，默认使用 sc 通过服务器启动已经传送的文件, 通过 -m schtasks  可以指定通过计划任务的方式启动,对脚本类文件更友好
::* 2023-01-06 1.新增 -e 参数,此参数可以指定一个文件来输出每个主机的执行结果，通过 -e filename 来指定输出的文件.; 2.新增 若有特殊字符密码时,可以通过指定: passWord 变量的方式进行设定.
@rem version 1.4.0
@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem 开启此参数，命令行指定参数和gui选择将会失效;
rem 相当于强制使用命令行参数；
rem 如果不需要保持为空即可
rem 使用方法 ： SET DEFAULT=-c 192.168.30.125 -u administrator -p eset1234. -f D:\test.bat -a "-t -m -p" -g , 与正常的cmd参数保持一致
SET DEFAULT_ARGS=

set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
::排查模式: True | False
set debug=False
rem 解析参数列表
set argsList=argsHelp argsClient argsClientValue argsUser argsUserValue argsPassword argsPasswordValue argsFile argsFileValue argsArgs argsArgsValue argsTest argsGui argsMethod argsMethodValue argsExport argsExportValue
::----------------------------------

rem ----------- init -----------
rem 设置初始变量
rem 记录初始命令行参数
set svrName=ipcStart_TeMp
set srcArgs=%*

rem 如果密码有特殊字符,可以在此处强制指定,主要是: [!] 和 [^] 这两个字符, 如果包含这两个字符则在字符前加 [^] 符号进行转义,如果不需要保持为空或者注释掉即可
::set "passWord=abcd1234^!@#$%^^&*()_+-="
set "passWord="

if not defined DEFAULT_ARGS (
	set args=%srcArgs%
) else (
	set args=%DEFAULT_ARGS%
)
if not defined args (
	call :getGuiHelp
	set args=!guiArgsStatus!)
)

call :getArgs %args%

rem 如果密码有特殊字符,可以在此处强制指定
if not "!passWord!" == "" (
	set "argsPasswordValue=!passWord!"
)

if "%argsHelp%" == "True" (
	call :getCmdHelp
	set exitCode=0
	goto :exitScript
)

if "%argsClient% %argsUser% %argsPassword%" == "True True True" (
	call :isFile "%argsClientValue%"
	if "!return!" == "True" (
		for /f %%a in ('type "%argsClientValue%"') do (
			echo\
			echo 处理主机: %%~a
			ping -n 1 %%a | findstr "TTL=" >nul
			if !errorlevel! equ 0 (
				call :run "%%~a"
				set exitCode=!return!
			) else (
				echo     测试网络连接失败!
				call :exportHost "%%~a" 1 "!argsExportValue!"
				set exitCode=5
			)
		)
	) else (
		echo 处理主机: %argsClientValue%
		call :run "%argsClientValue%"
		set exitCode=!return!
		goto :exitScript
	)
) else (
	echo 必要参数错误或缺失.
	set exitCode=2
	goto :exitScript
)


rem exitCode: 正常:0,标准命令行报错:1,参数错误:2,连接IPC$出错:3,复制文件出错:4,创建服务或启动服务出错:5,未知错误:99
:exitScript
if "#%argsGui%"=="#True" (
	echo 按任意键结束
	pause >nul
	exit /b %exitCode%
) else (
	exit /b %exitCode%
)
exit 99
:getCmdHelp
echo  Usage: %~nx0 -c host -u username -p password -f filepath [-a args] [-t] [-g] [-m schtasks]
echo\
echo                      此脚本可以指定一个程序通过IPC$的方式在别的客户端上执行.
echo\
echo  -h                    打印帮助信息
echo  -c client ^| file      指定需要执行的客户端地址,或包含客户端地址的文本文件.
echo  -u user               指定用户名,必须为管理员账户,否则将执行失败;如果是域控账号,还应该带上域名,例如: adtest\administrator
echo  -p password           指定密码
echo  -f filepath           指定要启动的文件路径,如果文件包含空格,应当将路径放在双引号内.
echo  -a args               指定启动文件的参数,如果是多个需要放在双引号内
echo  -m sc^|schtasks        指定通过何种方式启动文件,默认使用sc创建服务的方式启动,schtasks使用任务计划.
echo  -t                    只测试IPC$能否连接,不实际运行
echo  -e exportFile         导出处理的主机列表
echo  -g                    脚本完成后保留窗口
echo.
echo		Example: %~nx0 -c 192.168.30.125 -u administrator -p eset1234. -f D:\test.bat -a "-t -m sc -p" -m schtasks -g exportHost.log
echo\
echo              Code by Kermit Yao @ Windows 11, 2022-11-30 ,kermit.yao@qq.com
goto :eof

rem 获取 gui 界面,返回;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.*************************************************
echo.*						*
echo.*	1.通过IPC$启动指定程序	                *
echo.*	2.测试IPC$能否连接		        *
echo.*	3.显示命令行帮助			*
echo.*	kermit.yao@qq.com			*
echo.*						*
echo.*************************************************
echo.
echo.
set /p input=请选择(1^|2^|3):
for %%a in (1 2 3) do (
	if /i "#!input!"=="#%%a" (
		cls
		echo.
		set guiArgsStatus=True
	)
)

if "!helpValue!"=="True" (
	goto :eof
)

if "#!guiArgsStatus!"=="#" (
	cls
	echo 参数选择错误,请重新选择.
	goto getGuiHelp
)

if %input% equ 3 (
    set guiArgsStatus=-h -g
    goto :eof
)

if %input% equ 2 (
    set func=-t
)

:loopClient
set /p inputClient=请输入主机地址:
if "!inputClient!"=="" goto :loopClient

echo 如果是域控账号,还应该带上域名,例如: adtest\administrator
:loopUser
set /p inputUser=请输入用户名:
if "!inputUser!"=="" goto :loopUser

:loopPwd
set /p inputPwd=请输入密码:
if "!inputPwd!"=="" goto :loopPwd

:loopFile
if %input% equ 1 (
	set /p inputFile=请输入启动文件路径:
	call :isFile !inputFile!
	if not "!return!"=="True" goto :loopFile
)

:loopArgs
if %input% equ 1 (
	set /p inputArgs=请输入启动文件参数^(若有多个参数放在双引号内,没有可以不用输入^):
)
set guiArgsStatus=-c %inputClient% -u %inputUser% -p %inputPwd% -f %inputFile% -a %inputArgs% %func% -g
goto :eof

rem 解析传入参数; 传入参数: %1 = 参数列表；例：call :getArgs args ; 返回值: 无返回值
:getArgs

:loop
if "%~1" == "" goto :getArgsBreak

if /i "#%~1"=="#-h" (
    set argsHelp=True
)

if /i "#%~1"=="#-c" (
	if not "#$~2"=="#" (
    	echo %~2|findstr "^/ ^-" >nul||(set argsClient=True&set argsClientValue=%~2)
	)
)

if /i "#%~1"=="#-u" (
	if not "#$~2"=="#" (
    	echo %~2|findstr "^/ ^-" >nul||(set argsUser=True&set argsUserValue=%~2)
	)
)

if /i "#%~1"=="#-p" (
	if not "#$~2"=="#" (
    	echo %~2|findstr "^/ ^-" >nul||(set argsPassword=True&set argsPasswordValue=%~2)
	)
)

if /i "#%~1"=="#-f" (
	if not "#$~2"=="#" (
    	echo %~2|findstr "^/ ^-" >nul||(set argsFile=True&set argsFileValue=%~2)
	)
)

if /i "#%~1"=="#-a" (
	if not "#$~2"=="#" (
    	set argsArgs=True
		set argsArgsValue=%~2
	)
)

if /i "#%~1"=="#-m" (
	if not "#$~2"=="#" (
    	echo %~2|findstr "^/ ^-" >nul||(set argsMethod=True&set argsMethodValue=%~2)
	)
)

if /i "#%~1"=="#-t" (	
    set argsTest=True
)

if /i "#%~1"=="#-e" (
	if not "#$~2"=="#" (
    	echo %~2|findstr "^/ ^-" >nul||(set argsExport=True&set argsExportValue=%~2)
	)
)

if /i "#%~1"=="#-g" (	
    set argsGui=True
)

shift
goto :loop
:getArgsBreak

for %%a in (%argsList%) do (
	if "#!%%a!"=="#True" set argsStatus=True
)
goto :eof

:isFile
set return=False
if exist "%~1" (
	if not exist "%~1\" (
		set return=True
	)
)
goto :eof


:run

echo     开始连接主机【%~1】...
call :connectIpc "%~1" "%argsUserValue%" "%argsPasswordValue%"
if not "!return!"=="True" (
	echo     主机连接失败!
	call :exportHost "%~1" 2 "!argsExportValue!"
	set exitCode=3
	goto :exitScript
) else (
	echo     主机连接成功!
	set exitCode=0
	if not "%argsTest%" == "True" (
		echo     传送相关文件【%argsFileValue%】...
		for /f "delims=" %%a in ("%argsFileValue%") do set ipcFileName=%%~nxa
		set ipcFilePath=\\%~1\admin$\!ipcFileName!
		set ipcLocalPath=%windir%\!ipcFileName!
		call :copyFile "%argsFileValue%" "!ipcFilePath!" "%~1"
		if not "!return!"=="True" (
			echo     传送相关文件失败!
			call :exportHost "%~1" 3 "!argsExportValue!"
			set exitCode=4
			goto :exitScript
		)
		echo     开始启动程序【!ipcFileName!】...
		if "%argsMethodValue%" == "schtasks" (
			call :startProcessSchtasks "\\%~1" "%svrName%" "!ipcLocalPath!" "%argsArgsValue%" "%argsUserValue%" "%argsPasswordValue%"
		) else (
			call :startProcessSC "\\%~1" "%svrName%" "!ipcLocalPath!" "%argsArgsValue%"
		)
		if "!return!"=="True" (
			echo     进程启动成功.
			set exitCode=0
		) else (
			echo     进程启动失败.
			set exitCode=5
		)
	) else (
		call :exportHost "%~1" 10 "!argsExportValue!"
	)
         net use "!clientIpc!" /delete >nul 2>&1
)
goto :eof


rem 导出主机到文件；传入参数: %1 = 主机, %2 = 类型 (0=成功, 1=网络测试未通过, 2=连接ipc失败, 3=复制文件失败, 4=创建服务失败, 5=启动服务失败, 6=创建任务计划失败, 7=启动任务计划失败)， %3 = 导出文件路径
rem call :exportHost host 0 !argsExportValue!
:exportHost

if not "!argsExport!" == "" (
	if not exist "%~3" (
		echo           IP         STATE{0=成功, 1=网络测试未通过, 2=连接ipc失败, 3=复制文件失败, 4=创建服务失败, 5=启动服务失败, 6=创建任务计划失败, 7=启动任务计划失败}>>"%~3"
	)
	set tmpHost=%~1
	set tmpHost=!tmpHost:\=!
	::echo host: !tmpHost! -- type: %2 -- exportFile: %~3
	echo !tmpHost!  %2 >>"%~3"
)
goto :eof


rem 连接共享主机; 传入参数: %1 = 主机， %2 = 用户名, %3 = 密码; 例：call :connectShare "\\127.0.0.1" "kermit" "5698" ; 返回值: return=True | False
:connectIpc
set tmpState=False
set cmd_user_param=/user:"%~2"
set clientIpc=\\%~1\ipc$
if "%debug%" == "True" (
	echo debug -- 清空连接信息.
	net use "!clientIpc!" /delete
) else (
	net use "!clientIpc!" /delete >nul 2>&1
)

if "%debug%" == "True" (
	echo debug -- 执行远程连接
	for /f "delims=" %%a in ('net use "!clientIpc!" !cmd_user_param! "!argsPasswordValue!" ^&^& echo statusTrue') do (
		set tm=%%a
		if "#!tm:~,10!"=="#statusTrue" (
			set tmpState=True
		)
	)
) else (
	for /f "delims=" %%a in ('net use "!clientIpc!" !cmd_user_param! "!argsPasswordValue!" 2^>nul ^&^& echo statusTrue') do (
		set tm=%%a
		if "#!tm:~,10!"=="#statusTrue" (
			set tmpState=True
		)
	)
)

set return=!tmpState!
goto :eof

rem 复制文件到客户端; 传入参数: %1 = 当前文件路径, %2 = 传送到客户端的文件路径; 返回值: return = True | False
:copyFile

if "%debug%" == "True" (
	echo debug -- 复制文件到主机
	copy /y "%~1" "%~2"
) else (
	copy /y "%~1" "%~2" >nul 2>&1
)

if %errorlevel% equ 0 (
	set return=True
) else (
	set return=Fals
)
goto :eof

rem 启动文件; 传入参数: %1 = 主机, %2 = 服务名称, %3 = ipc本地路径, %4 = 程序参数
:startProcessSC
set flag_1=False
set flag_2=False

if "%debug%" == "True" (
	echo debug -- 查询和删除重名服务项
	sc "%~1" query "%~2" &&sc "%~1" delete "%~2"
	echo debug -- 创建新的启动服务
	echo sc "%~1" create "%~2" binPath= "%~3 %~4" &&set flag_1=True
	sc "%~1" create "%~2" binPath= "%~3 %~4" &&set flag_1=True
	echo debug -- 查询服务是否创建
	sc "%~1" query "%~2"
) else (
	sc "%~1" query "%~2" >nul&&sc "%~1" delete "%~2" >nul
	sc "%~1" create "%~2" binPath= "%~3 %~4" >nul&&set flag_1=True
	sc "%~1" query "%~2" >nul
)

if %errorlevel% equ 0 (
	if "%debug%" == "True" (
		echo debug -- 开始启动服务
		sc "%~1" start "%~2"
	) else (
		sc "%~1" start "%~2" >nul
	)

	if !errorlevel! equ 1053 (
		set flag_2=True
		ping /n 3 127.0.0.1 >nul
		sc "%~1" delete "%~2" >nul
		if "!flag_1!!flag_2!" == "TrueTrue" (
			set return=True
			call :exportHost %~1 0 "!argsExportValue!"
		)
	) else (
		call :exportHost "%~1" 5 "!argsExportValue!"
	)
) else (
	set return=False
	call :exportHost "%~1" 4 "!argsExportValue!"
)
goto :eof


rem 启动文件; 传入参数: %1 = 主机, %2 = 任务名称, %3 = ipc本地路径, %4 = 程序参数, %5 = 账号, %6 = 密码
:startProcessSchtasks
set return=False
if "%debug%" == "True" (
	echo debug -- 账号：[%~5], 密码：[!argsPasswordValue!],开始创建计划任务...
	schtasks /CREATE /S "%~1" /U "%~5" /P "!argsPasswordValue!" /RU "system" /TN "%~2" /TR "cmd.exe /c %~3 %~4" /ST 00:00 /SC ONCE /F
	if !errorlevel! equ 0 (
		echo debug -- 开始启动计划任务...
		schtasks /run /S "%~1" /U "%~5" /P "!argsPasswordValue!" /TN "%~2" /i
		if !errorlevel! equ 0 (
			set return=True
			call :exportHost "%~1" 0 "!argsExportValue!"
			echo debug -- 开始删除计划任务...
			schtasks /delete /S "%~1" /U "%~5" /P "!argsPasswordValue!" /TN "%~2" /F
		) else (
			call :exportHost "%~1" 7 "!argsExportValue!"
		)
	) else (
		call :exportHost "%~1" 6 "!argsExportValue!"
	)
) else (
	schtasks /CREATE /S "%~1" /U "%~5" /P "!argsPasswordValue!" /RU "system" /TN "%~2" /TR "cmd.exe /c %~3 %~4" /ST 00:00 /SC ONCE /F >nul 2>&1
	if !errorlevel! equ 0 (
		schtasks /run /S "%~1" /U "%~5" /P "!argsPasswordValue!" /TN "%~2" /i  >nul 2>&1
		if !errorlevel! equ 0 (
			set return=True
			call :exportHost "%~1" 0 "!argsExportValue!"
			schtasks /delete /S "%~1" /U "%~5" /P "!argsPasswordValue!" /TN "%~2" /F >nul 2>&1
		) else (
			call :exportHost "%~1" 7 "!argsExportValue!"
		)
	) else (
		call :exportHost "%~1" 6 "!argsExportValue!"
	)
)
goto :eof
