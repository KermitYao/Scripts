::code by ngrain cmd@win10 20170926
::20171926,v1.0,备份工具完成
::20181101,v1.1,添加对mysql的支持
::20181207,v1.2,完善已知bug
::20181220,v1.3,删除mssql差异备份,添加对单文件数据库的支持,优化逻辑关系,精简代码
::20181229,v1.4,添加对还原操作的支持(直接拖入对应的备份文件到此文件上即可。   dbBackup.cmd x:\x\backupfile.??bak),调整代码逻辑.
::20190218,v1.4.1,对single文件还原时，先备份原有文件。
::20191227,v1.5 修复添加到自动启动无效的bug,增加密码有特殊字符串的支持, 修复mysql非标准端口的设置不起作用的bug。
::20191227,v1.5 修复添加到自动启动无效的bug,增加密码有特殊字符串的支持, 修复mysql非标准端口的设置不起作用的bug。
::20240306,v1.6 修复mssql非默认端口的支持
::基本原理为 batch 组织逻辑关系,数据库命令执行实际操作,若本机并未安装实体命令行工具即会备份失效（single类型的数据库例外,因为是直接COPY）。

@set V=v1.6
@echo off
setlocal enabledelayedexpansion
title Backup Tools    ver:%V%

::-----------------------user var-------------------------
::备份目录
set fs=c:\Backup
::是否备份到U盘，为True则备份目录指向第一个被检测到的U盘;若U盘不存在则备份目录不做改变。

set fsu=False
::数据库类型(0=mssql,1=mysql,single=2)
set dbtype=0

::数据库地址
set dbaddr=127.0.0.1

::数据库账号
set dbuser="era_user"

::数据库密码
set dbpw="^P*x'$01v3L8MPlS"

::数据库端口,仅 mysql 数据库起作用。
set dbport=14222

::需要备份库的关键字,模糊匹配,不分大小写,可以是多个,以[,]分割;为 [.] 不进行筛选(即备份所有数据库).
::如果数据库为single(单文件),则此参数应为 文件的完整路径.
::若为还原模式,必须是完整的数据库名
set dbkeyys=era_db
::set dbkeyys="d:\xygl\fda\laundry.btf"

::需要过滤库的关键字,模糊匹配,不分大小写,可以是多个,以[,]分割;为 [!@#$%] 不进行筛选.（single此项失效）
set dbkeyns=!@#

::还原模式时库文件放置路径,仅 mssql 时有效,默认存放在安装目录
set msFilePath=

if "%msFilePath%"=="" (
	if exist "%windir%\SysWOW64" (
		set "msFilePath=%PROGRAMFILES(X86)%\Microsoft SQL Server\MSSQL.1\MSSQL\Data\"
	) else (
		set "msFilePath=%PROGRAMFILES%\Microsoft SQL Server\MSSQL.1\MSSQL\Data\"
	)
)

::冗余间隔天数,自动删除N天之前的旧备份；0 为不启用循环删除
set ld=60
::是否自启动,若为 [True] 则设置自启动,启动规则见 [st]
set ar=False
::自动添加计划任务 (11:11 代表每天的 11点11分开始备份)，若为 [auto] 则添加开机自启动。
set st=23:00


::扩展名,决定备份文件的扩展名或后缀名。
::mssql 扩展名
set msext=msbak
::mysql 扩展名
set myext=mybak
::single 扩展名
set fdext=fdbak
::-----------------------user var-------------------------

::-----------------------sys var-------------------------
::判断是否拖入文件
if "%1"=="" (
	set backupPath=False	
) else (
	set backupPath=%~1
)
::获取U盘的第一个盘符
if "%fsu%"=="True" (
	call :getDriveu
	if exist "!Driveu_1:~,1!:" (
		set fs=!Driveu_1:~,1!%fs:~1%
	)
)

::添加临时环境变量,(命令行所在的目录)
if exist "%windir%\SysWOW64" (
	set "msdbPath=%PROGRAMFILES(X86)%\Microsoft SQL Server\90\Tools\Binn"
	set "mydbPath=%PROGRAMFILES(X86)%\mysql\bin"
	set "mydbPath=%PROGRAMFILES%\mysql\bin"
) else (
	set "msdbPath=%PROGRAMFILES%\Microsoft SQL Server\90\Tools\Binn"
	set "mydbPath=%PROGRAMFILES%\mysql\bin"
)

set "customPath=C:\Program Files (x86)\Mysql\bin"
set path=%path%;%msdbPath%;%mydbPath%;%customPath%

::日志路径
set pro=%fs%\backpro.log
set newfl=False
set own=%~0
set st=%st: =%
set lines=----------------------------------
set test=Single
set restoreState=False

::-----------------------sys var-------------------------

::########################begin###############################


md %fs%\ >nul 2>&1
echo 初始化配置. >>%pro%
echo 初始化配置.

::测试mssql命令行是否可用。
if %dbtype% equ 0 (
	for /f "delims= skip=2 eol=(" %%a in ('sqlcmd -S %dbaddr%^,%dbport% -U%dbuser% -P%dbpw% -Q "select name from sysdatabases" ') do (
		set test=%%a
	)
)

::测试mysql命令行是否可用。
if %dbtype% equ 1 (
	for /f "delims=" %%a in ('mysql -h %dbaddr% -P%dbport% -u%dbuser% -p%dbpw% -se "show databases;"') do (
		set test=%%a
	)
)

::测试备份目录是否存在
if not exist %fs%\ (
	echo 目录错误 >>%pro%
	echo 目录错误.
	ping /n 5 127.1 >nul
	exit /b 1
)

::测试数据库是否可调用
if "%test%"=="Single" (
	if not %dbtype% equ 2 (
		echo 配置错误. >>%pro%
		echo 配置错误.
		ping /n 5 127.1 >nul
		exit /b 2
	) else (
		if not exist %dbkeyys% (
			if not exist "%~1" (
				echo 数据库错误. >>%pro%
				echo 数据库错误
				ping /n 5 127.1 >nul
				exit /b 3
			)
		)
	)
) 

::初始化需要存在的关键字
if "%dbkeyys%"=="" (
	set dbkeyy=/c:".*"
) else (
	for %%a in (%dbkeyys%) do set dbkeyy=!dbkeyy! /c:"%%a"
)

::初始化需要排除的关键字
if "%dbkeyns%"=="" (
	set dbkeyn=/c:".*"
) else (
	for %%a in (%dbkeyns%) do set dbkeyn=!dbkeyn! /c:"%%a"
)

::main
call :getTime
::如果拖入了一个路径则配置为还原模式, 开始导入数据库
if exist %backupPath% (
	call :importUI
	if %dbtype% equ 0 call :importMssqlBackup
	if %dbtype% equ 1 call :importMysqlBackup
	if %dbtype% equ 2 call :importSingleBackup
) else (
	call :backUI
	if %dbtype% equ 0 call :getMssqlBackup
	if %dbtype% equ 1 call :getMysqlBackup
	if %dbtype% equ 2 call :getSingleBackup

)

::添加自启动
if "%ar%"=="True" (
	if "%st%"=="auto" (
		call :setAutorun add "%own%"
	) else (
		call :setSchtasks "%own%"
	)
)

::删除备份文件
call :delLd
call :doneUI
exit 0

::----------------DONE----------------

::获取时间
:getTime
set back_timename=%date:~,10%%time%
set back_timename=%back_timename:/=%
set back_timename=%back_timename:-=%
set back_timename=%back_timename: =%
set back_timename=%back_timename::=%
set back_timename=%back_timename:.=%
goto :eof

::获取路径信息
:getPathInfo
set paths=%~dp1
set name=%~n1
set ext=%~x1
goto :eof

::mssql 备份
:getMssqlBackup
for /f "eol=(" %%a in ('sqlcmd -S %dbaddr%^,%dbport% -U %dbuser% -P %dbpw% -Q "select name from sysdatabases"^|findstr /i /r %dbkeyy%^|findstr /i /v /r %dbkeyn%') do (
	echo 处理数据库: [%%a]
	echo 处理数据库: [%%a] >>%pro%
	md %fs%\%%a\ >>%pro% 2>&1
	(echo backup database %%a to disk = '%fs%\%%a\%back_timename%_%%a.%msext%')>%temp%\n.sql
	sqlcmd -S %dbaddr%^,%dbport% -U %dbuser% -P %dbpw% -i %temp%\n.sql >>%pro% 2>&1
	echo [ok] Backup databases -- full [%%a]
)
goto :eof

::mysql 备份
:getMysqlBackup
for /f "delims=" %%a in ('mysql -h %dbaddr% -u%dbuser% -P%dbport% -p%dbpw% -se "show databases"2^>nul^|findstr /i /r %dbkeyy%^|findstr /i /v /r %dbkeyn%') do (
	echo 处理数据库: [%%a]
	echo 处理数据库: [%%a] >>%pro%
	md %fs%\%%a\ >>%pro% 2>&1
	mysqldump -h %dbaddr% -u%dbuser% -p%dbpw% --databases "%%a">"%fs%\%%a\%back_timename%_%%a.%myext%" 2>nul
	echo [ok] Backup databases -- full [%%a]
)
goto :eof

::single 备份
:getSingleBackup
echo 处理数据库: [%dbkeyys%]
echo 处理数据库: [%dbkeyys%] >>%pro%
if exist "%dbkeyys%" (
    call :getPathInfo %dbkeyys%
    md %fs%\!name!\ >>%pro% 2>&1
    copy /y %dbkeyys% "%fs%\!name!\%back_timename%_!name!.%fdext%" >nul 2>&1
    if exist "%fs%\!name!\%back_timename%_!name!.%fdext%" (
        echo 操作已完成.>>%pro%
        echo [ok] Backup databases -- full [%dbkeyys%]
    ) else (
        echo 操作失败.>>%pro%
        echo [error] Backup failure -- [%dbkeyys%]
    )
) else (
    echo [error] File not found. [%dbkeyys%].>>%pro%
    echo 操作失败.>>%pro%
    echo [error] File not found. [%dbkeyys%]
)
goto :eof

::
:importMssqlBackup
echo 处理备份文件: [%backupPath%]

set logicState=False
set num=0
for /f "skip=2 tokens=1,2" %%a in ('sqlcmd  -S %dbaddr%^,%dbport% -Usa -Pbetterlife -Q "restore filelistonly from disk='%backupPath%'"') do (
	set /a num+=1
	set logicName_!num!=%%a
)
if /i "!logicName_2:~-4!"=="_log" set logicState=True

if "!logicState!"=="False" (
	echo 未能获取逻辑名称,强制恢复。
	(echo restore database %dbkeyys% from disk='%backupPath%')>%temp%\n.sql
) else (
	(
	echo restore database %dbkeyys%
	echo from disk='%backupPath%'
	echo with recovery,
	echo move '!logicName_1!' to "%msFilePath%!dbkeyys!.mdf",
	echo move '!logicName_2!' to "%msFilePath%!dbkeyys!_log.ldf"
	)>%temp%\n.sql
)

echo\
sqlcmd  -S %dbaddr%,%dbport% -U %dbuser% -P %dbpw% -i %temp%\n.sql >%temp%\tmp.error&&type %temp%\tmp.error&&type %temp%\tmp.error >>%pro% 2>&1
echo\


goto :eof

:importMysqlBackup
echo 处理备份文件: [%backupPath%]
(
mysql -h %dbaddr% -u%dbuser% -p%dbpw% -e "create database %dbkeyys%;"
mysql -h %dbaddr% -u%dbuser% -p%dbpw% --default-character-set=utf8 %dbkeyys% <"%backupPath%" &&set restoreState=True
)>>%pro% 2>&1
if "%restoreState%"=="True" (
	echo [ok] Restore databases -- [%dbkeyys%]
) else (
	echo [fail] Restore databases -- [%dbkeyys%]
)
echo %restoreState% >>%pro%
goto :eof


:importSingleBackup
echo 处理备份文件: [%backupPath%]
if exist "%dbkeyys%" (
	call :getPathInfo %dbkeyys%
	echo 备份源文件.
	copy /y %dbkeyys% "!paths!%back_timename%_!name!.%fdext%"
)>>%pro% 2>&1
(
	echo 开始还原.
	copy /y "%backupPath%" %dbkeyys% &&set restoreState=True
)>>%pro% 2>&1
if "%restoreState%"=="True" (
	echo [ok] Restore databases -- [%dbkeyys%]
) else (
	echo [fail] Restore databases -- [%dbkeyys%]
)
echo 还原状态:%restoreState% >>%pro%

goto :eof

::若为备份模式则调用此提示
:backUI
echo 初始化完成. >>%pro%
echo 初始化完成.
echo 开始主进程. >>%pro%
echo 开始主进程.
echo 	数据库类型:[%dbtype%] >>%pro%
echo 	数据库类型:[%dbtype%]
echo 	备份关键字:[%dbkeyys%] >>%pro%
echo 	备份关键字:[%dbkeyys%]
echo 	过滤关键字:[%dbkeyns%] >>%pro%
echo 	过滤关键字:[%dbkeyns%]
echo 	开始获取数据库. >>%pro%
echo 	开始获取数据库.
echo %lines%
echo {>>%pro%
goto :eof

::若为还原模式则调用此提示
:importUI
echo 初始化完成. >>%pro%
echo 初始化完成.
echo 开始主进程. >>%pro%
echo 开始主进程.
echo 	数据库类型:[%dbtype%] >>%pro%
echo 	数据库类型:[%dbtype%]
echo 	数据库名称:[%dbkeyys%] >>%pro%
echo 	数据库名称:[%dbkeyys%]
echo  	开始导入 >>%pro%
echo 	开始导入.
echo %lines%
echo {>>%pro%
echo file:%backupPath% >>%pro%
goto :eof

::完成提示
:doneUI
echo %lines%
echo [ok] 全部操作已完成！时间:%date% %time%
echo [ok] all backup！time:%date% %time% >>%pro%
echo }>>%pro%
echo\
echo 将在以下时间后退出:
for /l %%b in (6,-1,1) do (
	set /p=%%b  <nul
	ping /n 2 127.1>nul
)
exit /b 0

::删除冗余文件
:delLd
echo 开始删除冗余文件 >>%pro%
for /f "delims=" %%a in ('forfiles /p %fs% /m *.*bak /s /d -%ld% /c "cmd /c echo @path" 2^>nul') do (
	del /q %%a
	echo [ok] delete [%%~a]
	echo 删除 [%%~a] >>%pro%
)
goto :eof

::获取U盘盘符
:getDriveu
(for /f "tokens=2 delims==" %%a in ('wmic LogicalDisk where "DriveType='2'" get DeviceID /value') do (
	set /a count+=1  
	set Driveu_!count!=%%a  
))>nul 2>&1
goto :eof

::添加任务计划
:setSchtasks
(
schtasks /create /F /sc daily /st %st% /tn "%~n1" /tr "cmd /C start /min %~fs1"
)>nul 2>&1
goto :eof

::添加自启动
:: %1 = type[add|del], %2 = filepath
:setAutorun
set regstate=false
if "%1" == "add" (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "%~n2" /d "cmd /c pushd %~dp0&start /min %~fs2 %~fs3"  /f >nul 2>&1
	if "!errorlevel!" == "0" set regstate=true
)

if "%1" == "del" (
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "%~n2" /f >nul 2>&1
	if "!errorlevel!" == "0" set regstate=true
)
goto :eof
