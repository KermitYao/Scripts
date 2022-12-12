
::* �˽ű�����ָ��һ������ͨ��IPC$�ķ�ʽ�ڱ�Ŀͻ�����ִ��.
::* 2022-11-30 �ű����
::* 2022-12-09 1.���� ʹ -c ��������֧��һ��������ַ�б���ı�,�� -c ������ֵ������жϣ�����������ļ�������ı�,������ļ������ֵ������ַʹ��;2.���� �Ż��ű��߼�,�������
@rem version 1.2.1
@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem �����˲�����������ָ��������guiѡ�񽫻�ʧЧ;
rem �൱��ǿ��ʹ�������в�����
rem �������Ҫ����Ϊ�ռ���
rem ʹ�÷��� �� SET DEFAULT=-c 192.168.30.125 -u administrator -p eset1234. -f D:\test.bat -a "-t -m -p" -g , ��������cmd��������һ��
SET DEFAULT_ARGS=

set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

rem ���������б�
set argsList=argsHelp argsClient argsClientValue argsUser argsUserValue argsPassword argsPasswordValue argsFile argsFileValue argsArgs argsArgsValue argsTest argsGui
::----------------------------------

rem ----------- init -----------
rem ���ó�ʼ����
rem ��¼��ʼ�����в���
set svrName=ipcStart_TeMp
set srcArgs=%*

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
			echo ��������: %%~a
			ping -n 1 %%a | findstr "TTL=" >nul
			if !errorlevel! equ 0 (
				call :run "%%~a"
				set exitCode=!return!
			) else (
				echo     ������������ʧ��!
				set exitCode=5
			)
		)
	) else (
		echo ��������: %argsClientValue%
		call :run "%argsClientValue%"
		set exitCode=!return!
		goto :exitScript
	)
) else (
	echo ��Ҫ���������ȱʧ.
	set exitCode=2
	goto :exitScript
)


rem exitCode: ����:0,��׼�����б���:1,��������:2,����IPC$����:3,�����ļ�����:4,��������������������:5,δ֪����:99
:exitScript
if "#%argsGui%"=="#True" (
	echo �����������
	pause >nul
	exit /b %exitCode%
) else (
	exit /b %exitCode%
)

:getCmdHelp
echo  Usage: %~nx0 -c 192.168.1.99 -u username -p password -f filepath [-a args] [-t] [-g]
echo\
echo                      �˽ű�����ָ��һ������ͨ��IPC$�ķ�ʽ�ڱ�Ŀͻ�����ִ��.
echo\
echo  -h                    ��ӡ������Ϣ
echo  -c client ^| file      ָ����Ҫִ�еĿͻ��˵�ַ,������ͻ��˵�ַ���ı��ļ�.
echo  -u user               ָ���û���,����Ϊ����Ա�˻�,����ִ��ʧ��;���������˺�,��Ӧ�ô�������,����: adtest\administrator
echo  -p password           ָ������
echo  -f filepath           ָ��Ҫ�������ļ�·��,����ļ������ո�,Ӧ����·������˫������.
echo  -a args               ָ�������ļ��Ĳ���,����Ƕ����Ҫ����˫������
echo  -t                    ֻ����IPC$�ܷ�����,��ʵ������
echo  -g                    �ű���ɺ�������
echo.
echo		Example: %~nx0 -c 192.168.30.125 -u administrator -p eset1234. -f D:\test.bat -a "-t -m -p"
echo\
echo              Code by Kermit Yao @ Windows 11, 2022-11-30 ,kermit.yao@qq.com
goto :eof

rem ��ȡ gui ����,����;return=Null|True
:getGuiHelp
set guiArgsStatus=
set guiStatus=True
echo.
echo.
echo.*************************************************
echo.*						*
echo.*	1.ͨ��IPC$����ָ������	                *
echo.*	2.����IPC$�ܷ�����		        *
echo.*	3.��ʾ�����а���			*
echo.*	kermit.yao@qq.com			*
echo.*						*
echo.*************************************************
echo.
echo.
set /p input=��ѡ��(1^|2^|3):
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
	echo ����ѡ�����,������ѡ��.
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
set /p inputClient=������������ַ:
if "!inputClient!"=="" goto :loopClient

echo ���������˺�,��Ӧ�ô�������,����: adtest\administrator
:loopUser
set /p inputUser=�������û���:
if "!inputUser!"=="" goto :loopUser

:loopPwd
set /p inputPwd=����������:
if "!inputPwd!"=="" goto :loopPwd

:loopFile
if %input% equ 1 (
	set /p inputFile=�����������ļ�·��:
	call :isFile !inputFile!
	if not "!return!"=="True" goto :loopFile
)

:loopArgs
if %input% equ 1 (
	set /p inputArgs=�����������ļ�����^(���ж����������˫������,û�п��Բ�������^):
)
set guiArgsStatus=-c %inputClient% -u %inputUser% -p %inputPwd% -f %inputFile% -a %inputArgs% %func% -g
goto :eof

rem �����������; �������: %1 = �����б�����call :getArgs args ; ����ֵ: �޷���ֵ
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

if /i "#%~1"=="#-t" (	
    set argsTest=True
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

echo     ��ʼ����������%~1��...
call :connectIpc "%~1" "%argsUserValue%" "%argsPasswordValue%"
if not "!return!"=="True" (
	echo     ��������ʧ��!
	set exitCode=3
	goto :exitScript
) else (
	echo     �������ӳɹ�!
	set exitCode=0
	if not "%argsTest%" == "True" (
		echo     ��������ļ���%argsFileValue%��...
		for /f "delims=" %%a in ("%argsFileValue%") do set ipcFileName=%%~nxa
		set ipcFilePath=\\%~1\admin$\!ipcFileName!
		set ipcLocalPath=%windir%\!ipcFileName!
		call :copyFile "%argsFileValue%" "!ipcFilePath!"
		if not "!return!"=="True" (
			echo     ��������ļ�ʧ��!
			set exitCode=4
			goto :exitScript
		)
		echo     ��ʼ��������!ipcFileName!��...
		call :startProcess "\\%~1" "%svrName%" "!ipcLocalPath!" "%argsArgsValue%"
		if "!return!"=="True" (
			echo     ���������ɹ�.
			set exitCode=0
		) else (
			echo     ��������ʧ��.
			set exitCode=5
		)
	)
         net use "!clientIpc!" /delete >nul 2>&1
)
goto :eof


rem ���ӹ�������; �������: %1 = ������ %2 = �û���, %3 = ����; ����call :connectShare "\\127.0.0.1" "kermit" "5698" ; ����ֵ: return=True | False
:connectIpc
set tmpState=False
set cmd_user_param=/user:"%~2"
set clientIpc=\\%~1\ipc$
net use "!clientIpc!" /delete >nul 2>&1
for /f "delims=" %%a in ('net use "!clientIpc!" !cmd_user_param! "%~3" 2^>nul ^&^& echo statusTrue') do (
	set tm=%%a
	if "#!tm:~,10!"=="#statusTrue" (
		set tmpState=True
	)
)
set return=!tmpState!
goto :eof

rem �����ļ����ͻ���; �������: %1 = ��ǰ�ļ�·��, %2 = ���͵��ͻ��˵��ļ�·��; ����ֵ: return = True | False
:copyFile
copy /y "%~1" "%~2" >nul 2>&1
if %errorlevel% equ 0 (
	set return=True
) else (
	set return=False
)
goto :eof

rem �����ļ�; �������: %1 = ����, %2 = ��������, %3 = ipc����·��, %4 = �������
:startProcess
set flag_1=False
set flag_2=False
sc "%~1" query "%~2" >nul&&sc "%~1" delete "%~2" >nul
sc "%~1" create "%~2" binPath= "%~3 %~4" >nul&&set flag_1=True
sc "%~1" query "%~2" >nul
if %errorlevel% equ 0 (
	sc "%~1" start "%~2" >nul
	if !errorlevel! equ 1053 (
		set flag_2=True
		ping /n 3 127.0.0.1 >nul
		::sc "%~1" delete "%~2" >nul
		if "!flag_1!!flag_2!" == "TrueTrue" (
			set return=True
		)
	)
) else (
	set return=False
)
goto :eof