
::* �˽ű�����ָ��һ������ͨ��IPC$�ķ�ʽ�ڱ�Ŀͻ�����ִ��.
::* 2022-11-30 �ű����
::* 2022-12-09 1.���� ʹ -c ��������֧��һ��������ַ�б���ı�,�� -c ������ֵ������жϣ�����������ļ�������ı�,������ļ������ֵ������ַʹ��;2.���� �Ż��ű��߼�,�������
::* 2022-12-24 1.���� ���� -m����, �˲�������ָ��һ���ļ�������ʽ��Ĭ��ʹ�� sc ͨ�������������Ѿ����͵��ļ�, ͨ�� -m schtasks  ����ָ��ͨ���ƻ�����ķ�ʽ����,�Խű����ļ����Ѻ�
::* 2023-01-06 1.���� -e ����,�˲�������ָ��һ���ļ������ÿ��������ִ�н����ͨ�� -e filename ��ָ��������ļ�.; 2.���� ���������ַ�����ʱ,����ͨ��ָ��: passWord �����ķ�ʽ�����趨.
@rem version 1.4.0
@echo off
setlocal enabledelayedexpansion

::----------------------------------
rem �����˲�����������ָ��������guiѡ�񽫻�ʧЧ;
rem �൱��ǿ��ʹ�������в�����
rem �������Ҫ����Ϊ�ռ���
rem ʹ�÷��� �� SET DEFAULT=-c 192.168.30.125 -u administrator -p eset1234. -f D:\test.bat -a "-t -m -p" -g , ��������cmd��������һ��
SET DEFAULT_ARGS=

set bugTest=echo -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
::�Ų�ģʽ: True | False
set debug=False
rem ���������б�
set argsList=argsHelp argsClient argsClientValue argsUser argsUserValue argsPassword argsPasswordValue argsFile argsFileValue argsArgs argsArgsValue argsTest argsGui argsMethod argsMethodValue argsExport argsExportValue
::----------------------------------

rem ----------- init -----------
rem ���ó�ʼ����
rem ��¼��ʼ�����в���
set svrName=ipcStart_TeMp
set srcArgs=%*

rem ��������������ַ�,�����ڴ˴�ǿ��ָ��,��Ҫ��: [!] �� [^] �������ַ�, ��������������ַ������ַ�ǰ�� [^] ���Ž���ת��,�������Ҫ����Ϊ�ջ���ע�͵�����
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

rem ��������������ַ�,�����ڴ˴�ǿ��ָ��
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
			echo ��������: %%~a
			ping -n 1 %%a | findstr "TTL=" >nul
			if !errorlevel! equ 0 (
				call :run "%%~a"
				set exitCode=!return!
			) else (
				echo     ������������ʧ��!
				call :exportHost "%%~a" 1 "!argsExportValue!"
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
exit 99
:getCmdHelp
echo  Usage: %~nx0 -c host -u username -p password -f filepath [-a args] [-t] [-g] [-m schtasks]
echo\
echo                      �˽ű�����ָ��һ������ͨ��IPC$�ķ�ʽ�ڱ�Ŀͻ�����ִ��.
echo\
echo  -h                    ��ӡ������Ϣ
echo  -c client ^| file      ָ����Ҫִ�еĿͻ��˵�ַ,������ͻ��˵�ַ���ı��ļ�.
echo  -u user               ָ���û���,����Ϊ����Ա�˻�,����ִ��ʧ��;���������˺�,��Ӧ�ô�������,����: adtest\administrator
echo  -p password           ָ������
echo  -f filepath           ָ��Ҫ�������ļ�·��,����ļ������ո�,Ӧ����·������˫������.
echo  -a args               ָ�������ļ��Ĳ���,����Ƕ����Ҫ����˫������
echo  -m sc^|schtasks        ָ��ͨ�����ַ�ʽ�����ļ�,Ĭ��ʹ��sc��������ķ�ʽ����,schtasksʹ������ƻ�.
echo  -t                    ֻ����IPC$�ܷ�����,��ʵ������
echo  -e exportFile         ��������������б�
echo  -g                    �ű���ɺ�������
echo.
echo		Example: %~nx0 -c 192.168.30.125 -u administrator -p eset1234. -f D:\test.bat -a "-t -m sc -p" -m schtasks -g exportHost.log
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

echo     ��ʼ����������%~1��...
call :connectIpc "%~1" "%argsUserValue%" "%argsPasswordValue%"
if not "!return!"=="True" (
	echo     ��������ʧ��!
	call :exportHost "%~1" 2 "!argsExportValue!"
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
		call :copyFile "%argsFileValue%" "!ipcFilePath!" "%~1"
		if not "!return!"=="True" (
			echo     ��������ļ�ʧ��!
			call :exportHost "%~1" 3 "!argsExportValue!"
			set exitCode=4
			goto :exitScript
		)
		echo     ��ʼ��������!ipcFileName!��...
		if "%argsMethodValue%" == "schtasks" (
			call :startProcessSchtasks "\\%~1" "%svrName%" "!ipcLocalPath!" "%argsArgsValue%" "%argsUserValue%" "%argsPasswordValue%"
		) else (
			call :startProcessSC "\\%~1" "%svrName%" "!ipcLocalPath!" "%argsArgsValue%"
		)
		if "!return!"=="True" (
			echo     ���������ɹ�.
			set exitCode=0
		) else (
			echo     ��������ʧ��.
			set exitCode=5
		)
	) else (
		call :exportHost "%~1" 10 "!argsExportValue!"
	)
         net use "!clientIpc!" /delete >nul 2>&1
)
goto :eof


rem �����������ļ����������: %1 = ����, %2 = ���� (0=�ɹ�, 1=�������δͨ��, 2=����ipcʧ��, 3=�����ļ�ʧ��, 4=��������ʧ��, 5=��������ʧ��, 6=��������ƻ�ʧ��, 7=��������ƻ�ʧ��)�� %3 = �����ļ�·��
rem call :exportHost host 0 !argsExportValue!
:exportHost

if not "!argsExport!" == "" (
	if not exist "%~3" (
		echo           IP         STATE{0=�ɹ�, 1=�������δͨ��, 2=����ipcʧ��, 3=�����ļ�ʧ��, 4=��������ʧ��, 5=��������ʧ��, 6=��������ƻ�ʧ��, 7=��������ƻ�ʧ��}>>"%~3"
	)
	set tmpHost=%~1
	set tmpHost=!tmpHost:\=!
	::echo host: !tmpHost! -- type: %2 -- exportFile: %~3
	echo !tmpHost!  %2 >>"%~3"
)
goto :eof


rem ���ӹ�������; �������: %1 = ������ %2 = �û���, %3 = ����; ����call :connectShare "\\127.0.0.1" "kermit" "5698" ; ����ֵ: return=True | False
:connectIpc
set tmpState=False
set cmd_user_param=/user:"%~2"
set clientIpc=\\%~1\ipc$
if "%debug%" == "True" (
	echo debug -- ���������Ϣ.
	net use "!clientIpc!" /delete
) else (
	net use "!clientIpc!" /delete >nul 2>&1
)

if "%debug%" == "True" (
	echo debug -- ִ��Զ������
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

rem �����ļ����ͻ���; �������: %1 = ��ǰ�ļ�·��, %2 = ���͵��ͻ��˵��ļ�·��; ����ֵ: return = True | False
:copyFile

if "%debug%" == "True" (
	echo debug -- �����ļ�������
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

rem �����ļ�; �������: %1 = ����, %2 = ��������, %3 = ipc����·��, %4 = �������
:startProcessSC
set flag_1=False
set flag_2=False

if "%debug%" == "True" (
	echo debug -- ��ѯ��ɾ������������
	sc "%~1" query "%~2" &&sc "%~1" delete "%~2"
	echo debug -- �����µ���������
	echo sc "%~1" create "%~2" binPath= "%~3 %~4" &&set flag_1=True
	sc "%~1" create "%~2" binPath= "%~3 %~4" &&set flag_1=True
	echo debug -- ��ѯ�����Ƿ񴴽�
	sc "%~1" query "%~2"
) else (
	sc "%~1" query "%~2" >nul&&sc "%~1" delete "%~2" >nul
	sc "%~1" create "%~2" binPath= "%~3 %~4" >nul&&set flag_1=True
	sc "%~1" query "%~2" >nul
)

if %errorlevel% equ 0 (
	if "%debug%" == "True" (
		echo debug -- ��ʼ��������
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


rem �����ļ�; �������: %1 = ����, %2 = ��������, %3 = ipc����·��, %4 = �������, %5 = �˺�, %6 = ����
:startProcessSchtasks
set return=False
if "%debug%" == "True" (
	echo debug -- �˺ţ�[%~5], ���룺[!argsPasswordValue!],��ʼ�����ƻ�����...
	schtasks /CREATE /S "%~1" /U "%~5" /P "!argsPasswordValue!" /RU "system" /TN "%~2" /TR "cmd.exe /c %~3 %~4" /ST 00:00 /SC ONCE /F
	if !errorlevel! equ 0 (
		echo debug -- ��ʼ�����ƻ�����...
		schtasks /run /S "%~1" /U "%~5" /P "!argsPasswordValue!" /TN "%~2" /i
		if !errorlevel! equ 0 (
			set return=True
			call :exportHost "%~1" 0 "!argsExportValue!"
			echo debug -- ��ʼɾ���ƻ�����...
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
