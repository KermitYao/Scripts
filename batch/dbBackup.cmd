::code by ngrain cmd@win10 20170926
::20171926,v1.0,���ݹ������
::20181101,v1.1,��Ӷ�mysql��֧��
::20181207,v1.2,������֪bug
::20181220,v1.3,ɾ��mssql���챸��,��ӶԵ��ļ����ݿ��֧��,�Ż��߼���ϵ,�������
::20181229,v1.4,��ӶԻ�ԭ������֧��(ֱ�������Ӧ�ı����ļ������ļ��ϼ��ɡ�   dbBackup.cmd x:\x\backupfile.??bak),���������߼�.
::20190218,v1.4.1,��single�ļ���ԭʱ���ȱ���ԭ���ļ���
::20191227,v1.5 �޸���ӵ��Զ�������Ч��bug,���������������ַ�����֧��, �޸�mysql�Ǳ�׼�˿ڵ����ò������õ�bug��
::20191227,v1.5 �޸���ӵ��Զ�������Ч��bug,���������������ַ�����֧��, �޸�mysql�Ǳ�׼�˿ڵ����ò������õ�bug��
::20240306,v1.6 �޸�mssql��Ĭ�϶˿ڵ�֧��
::����ԭ��Ϊ batch ��֯�߼���ϵ,���ݿ�����ִ��ʵ�ʲ���,��������δ��װʵ�������й��߼��ᱸ��ʧЧ��single���͵����ݿ�����,��Ϊ��ֱ��COPY����

@set V=v1.6
@echo off
setlocal enabledelayedexpansion
title Backup Tools    ver:%V%

::-----------------------user var-------------------------
::����Ŀ¼
set fs=c:\Backup
::�Ƿ񱸷ݵ�U�̣�ΪTrue�򱸷�Ŀ¼ָ���һ������⵽��U��;��U�̲������򱸷�Ŀ¼�����ı䡣

set fsu=False
::���ݿ�����(0=mssql,1=mysql,single=2)
set dbtype=0

::���ݿ��ַ
set dbaddr=127.0.0.1

::���ݿ��˺�
set dbuser="era_user"

::���ݿ�����
set dbpw="^P*x'$01v3L8MPlS"

::���ݿ�˿�,�� mysql ���ݿ������á�
set dbport=14222

::��Ҫ���ݿ�Ĺؼ���,ģ��ƥ��,���ִ�Сд,�����Ƕ��,��[,]�ָ�;Ϊ [.] ������ɸѡ(�������������ݿ�).
::������ݿ�Ϊsingle(���ļ�),��˲���ӦΪ �ļ�������·��.
::��Ϊ��ԭģʽ,���������������ݿ���
set dbkeyys=era_db
::set dbkeyys="d:\xygl\fda\laundry.btf"

::��Ҫ���˿�Ĺؼ���,ģ��ƥ��,���ִ�Сд,�����Ƕ��,��[,]�ָ�;Ϊ [!@#$%] ������ɸѡ.��single����ʧЧ��
set dbkeyns=!@#

::��ԭģʽʱ���ļ�����·��,�� mssql ʱ��Ч,Ĭ�ϴ���ڰ�װĿ¼
set msFilePath=

if "%msFilePath%"=="" (
	if exist "%windir%\SysWOW64" (
		set "msFilePath=%PROGRAMFILES(X86)%\Microsoft SQL Server\MSSQL.1\MSSQL\Data\"
	) else (
		set "msFilePath=%PROGRAMFILES%\Microsoft SQL Server\MSSQL.1\MSSQL\Data\"
	)
)

::����������,�Զ�ɾ��N��֮ǰ�ľɱ��ݣ�0 Ϊ������ѭ��ɾ��
set ld=60
::�Ƿ�������,��Ϊ [True] ������������,��������� [st]
set ar=False
::�Զ���Ӽƻ����� (11:11 ����ÿ��� 11��11�ֿ�ʼ����)����Ϊ [auto] ����ӿ�����������
set st=23:00


::��չ��,���������ļ�����չ�����׺����
::mssql ��չ��
set msext=msbak
::mysql ��չ��
set myext=mybak
::single ��չ��
set fdext=fdbak
::-----------------------user var-------------------------

::-----------------------sys var-------------------------
::�ж��Ƿ������ļ�
if "%1"=="" (
	set backupPath=False	
) else (
	set backupPath=%~1
)
::��ȡU�̵ĵ�һ���̷�
if "%fsu%"=="True" (
	call :getDriveu
	if exist "!Driveu_1:~,1!:" (
		set fs=!Driveu_1:~,1!%fs:~1%
	)
)

::�����ʱ��������,(���������ڵ�Ŀ¼)
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

::��־·��
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
echo ��ʼ������. >>%pro%
echo ��ʼ������.

::����mssql�������Ƿ���á�
if %dbtype% equ 0 (
	for /f "delims= skip=2 eol=(" %%a in ('sqlcmd -S %dbaddr%^,%dbport% -U%dbuser% -P%dbpw% -Q "select name from sysdatabases" ') do (
		set test=%%a
	)
)

::����mysql�������Ƿ���á�
if %dbtype% equ 1 (
	for /f "delims=" %%a in ('mysql -h %dbaddr% -P%dbport% -u%dbuser% -p%dbpw% -se "show databases;"') do (
		set test=%%a
	)
)

::���Ա���Ŀ¼�Ƿ����
if not exist %fs%\ (
	echo Ŀ¼���� >>%pro%
	echo Ŀ¼����.
	ping /n 5 127.1 >nul
	exit /b 1
)

::�������ݿ��Ƿ�ɵ���
if "%test%"=="Single" (
	if not %dbtype% equ 2 (
		echo ���ô���. >>%pro%
		echo ���ô���.
		ping /n 5 127.1 >nul
		exit /b 2
	) else (
		if not exist %dbkeyys% (
			if not exist "%~1" (
				echo ���ݿ����. >>%pro%
				echo ���ݿ����
				ping /n 5 127.1 >nul
				exit /b 3
			)
		)
	)
) 

::��ʼ����Ҫ���ڵĹؼ���
if "%dbkeyys%"=="" (
	set dbkeyy=/c:".*"
) else (
	for %%a in (%dbkeyys%) do set dbkeyy=!dbkeyy! /c:"%%a"
)

::��ʼ����Ҫ�ų��Ĺؼ���
if "%dbkeyns%"=="" (
	set dbkeyn=/c:".*"
) else (
	for %%a in (%dbkeyns%) do set dbkeyn=!dbkeyn! /c:"%%a"
)

::main
call :getTime
::���������һ��·��������Ϊ��ԭģʽ, ��ʼ�������ݿ�
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

::���������
if "%ar%"=="True" (
	if "%st%"=="auto" (
		call :setAutorun add "%own%"
	) else (
		call :setSchtasks "%own%"
	)
)

::ɾ�������ļ�
call :delLd
call :doneUI
exit 0

::----------------DONE----------------

::��ȡʱ��
:getTime
set back_timename=%date:~,10%%time%
set back_timename=%back_timename:/=%
set back_timename=%back_timename:-=%
set back_timename=%back_timename: =%
set back_timename=%back_timename::=%
set back_timename=%back_timename:.=%
goto :eof

::��ȡ·����Ϣ
:getPathInfo
set paths=%~dp1
set name=%~n1
set ext=%~x1
goto :eof

::mssql ����
:getMssqlBackup
for /f "eol=(" %%a in ('sqlcmd -S %dbaddr%^,%dbport% -U %dbuser% -P %dbpw% -Q "select name from sysdatabases"^|findstr /i /r %dbkeyy%^|findstr /i /v /r %dbkeyn%') do (
	echo �������ݿ�: [%%a]
	echo �������ݿ�: [%%a] >>%pro%
	md %fs%\%%a\ >>%pro% 2>&1
	(echo backup database %%a to disk = '%fs%\%%a\%back_timename%_%%a.%msext%')>%temp%\n.sql
	sqlcmd -S %dbaddr%^,%dbport% -U %dbuser% -P %dbpw% -i %temp%\n.sql >>%pro% 2>&1
	echo [ok] Backup databases -- full [%%a]
)
goto :eof

::mysql ����
:getMysqlBackup
for /f "delims=" %%a in ('mysql -h %dbaddr% -u%dbuser% -P%dbport% -p%dbpw% -se "show databases"2^>nul^|findstr /i /r %dbkeyy%^|findstr /i /v /r %dbkeyn%') do (
	echo �������ݿ�: [%%a]
	echo �������ݿ�: [%%a] >>%pro%
	md %fs%\%%a\ >>%pro% 2>&1
	mysqldump -h %dbaddr% -u%dbuser% -p%dbpw% --databases "%%a">"%fs%\%%a\%back_timename%_%%a.%myext%" 2>nul
	echo [ok] Backup databases -- full [%%a]
)
goto :eof

::single ����
:getSingleBackup
echo �������ݿ�: [%dbkeyys%]
echo �������ݿ�: [%dbkeyys%] >>%pro%
if exist "%dbkeyys%" (
    call :getPathInfo %dbkeyys%
    md %fs%\!name!\ >>%pro% 2>&1
    copy /y %dbkeyys% "%fs%\!name!\%back_timename%_!name!.%fdext%" >nul 2>&1
    if exist "%fs%\!name!\%back_timename%_!name!.%fdext%" (
        echo ���������.>>%pro%
        echo [ok] Backup databases -- full [%dbkeyys%]
    ) else (
        echo ����ʧ��.>>%pro%
        echo [error] Backup failure -- [%dbkeyys%]
    )
) else (
    echo [error] File not found. [%dbkeyys%].>>%pro%
    echo ����ʧ��.>>%pro%
    echo [error] File not found. [%dbkeyys%]
)
goto :eof

::
:importMssqlBackup
echo �������ļ�: [%backupPath%]

set logicState=False
set num=0
for /f "skip=2 tokens=1,2" %%a in ('sqlcmd  -S %dbaddr%^,%dbport% -Usa -Pbetterlife -Q "restore filelistonly from disk='%backupPath%'"') do (
	set /a num+=1
	set logicName_!num!=%%a
)
if /i "!logicName_2:~-4!"=="_log" set logicState=True

if "!logicState!"=="False" (
	echo δ�ܻ�ȡ�߼�����,ǿ�ƻָ���
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
echo �������ļ�: [%backupPath%]
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
echo �������ļ�: [%backupPath%]
if exist "%dbkeyys%" (
	call :getPathInfo %dbkeyys%
	echo ����Դ�ļ�.
	copy /y %dbkeyys% "!paths!%back_timename%_!name!.%fdext%"
)>>%pro% 2>&1
(
	echo ��ʼ��ԭ.
	copy /y "%backupPath%" %dbkeyys% &&set restoreState=True
)>>%pro% 2>&1
if "%restoreState%"=="True" (
	echo [ok] Restore databases -- [%dbkeyys%]
) else (
	echo [fail] Restore databases -- [%dbkeyys%]
)
echo ��ԭ״̬:%restoreState% >>%pro%

goto :eof

::��Ϊ����ģʽ����ô���ʾ
:backUI
echo ��ʼ�����. >>%pro%
echo ��ʼ�����.
echo ��ʼ������. >>%pro%
echo ��ʼ������.
echo 	���ݿ�����:[%dbtype%] >>%pro%
echo 	���ݿ�����:[%dbtype%]
echo 	���ݹؼ���:[%dbkeyys%] >>%pro%
echo 	���ݹؼ���:[%dbkeyys%]
echo 	���˹ؼ���:[%dbkeyns%] >>%pro%
echo 	���˹ؼ���:[%dbkeyns%]
echo 	��ʼ��ȡ���ݿ�. >>%pro%
echo 	��ʼ��ȡ���ݿ�.
echo %lines%
echo {>>%pro%
goto :eof

::��Ϊ��ԭģʽ����ô���ʾ
:importUI
echo ��ʼ�����. >>%pro%
echo ��ʼ�����.
echo ��ʼ������. >>%pro%
echo ��ʼ������.
echo 	���ݿ�����:[%dbtype%] >>%pro%
echo 	���ݿ�����:[%dbtype%]
echo 	���ݿ�����:[%dbkeyys%] >>%pro%
echo 	���ݿ�����:[%dbkeyys%]
echo  	��ʼ���� >>%pro%
echo 	��ʼ����.
echo %lines%
echo {>>%pro%
echo file:%backupPath% >>%pro%
goto :eof

::�����ʾ
:doneUI
echo %lines%
echo [ok] ȫ����������ɣ�ʱ��:%date% %time%
echo [ok] all backup��time:%date% %time% >>%pro%
echo }>>%pro%
echo\
echo ��������ʱ����˳�:
for /l %%b in (6,-1,1) do (
	set /p=%%b  <nul
	ping /n 2 127.1>nul
)
exit /b 0

::ɾ�������ļ�
:delLd
echo ��ʼɾ�������ļ� >>%pro%
for /f "delims=" %%a in ('forfiles /p %fs% /m *.*bak /s /d -%ld% /c "cmd /c echo @path" 2^>nul') do (
	del /q %%a
	echo [ok] delete [%%~a]
	echo ɾ�� [%%~a] >>%pro%
)
goto :eof

::��ȡU���̷�
:getDriveu
(for /f "tokens=2 delims==" %%a in ('wmic LogicalDisk where "DriveType='2'" get DeviceID /value') do (
	set /a count+=1  
	set Driveu_!count!=%%a  
))>nul 2>&1
goto :eof

::�������ƻ�
:setSchtasks
(
schtasks /create /F /sc daily /st %st% /tn "%~n1" /tr "cmd /C start /min %~fs1"
)>nul 2>&1
goto :eof

::���������
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
