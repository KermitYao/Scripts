::���ڶ� B-CloudS �ĵ��ú�����

@echo off
setlocal enabledelayedexpansion
title CloudBackupSetupTools 
pushd %~dp0

::---------var---------
set rfp="B-CloudS.exe"
for /f "delims=" %%a in ('dir /s/b %rfp%') do set afp="%%~a"
(echo "UAC TEST.%Random%.temp" >"%windir%\U.T"&&set Uac=Y&&del %windir%\U.T||set Uac=N)>nul 2>&1
::---------var---------

:bg
call :tel
set /p func=��ѡ����Ҫ�Ĺ���:
if %func% == 1 (
	cls
	call :uac
	call :regauto add %afp%

	if !regstate! == true (echo ��ӳɹ�) else (echo ���ʧ��)
) else (
	if %func% == 2 (
		cls
		call :uac
		call :regauto del %afp%
		if !regstate! == true (echo �Ƴ��ɹ�) else (echo �Ƴ�ʧ��)
	) else (
		if %func% == 3 (
			cls
			call %rfp%
		) else (
			if %func% == 4 (
				cls
				call %rfp% list
			) else (
				if %func% == 5 (
					cls
					echo δ����
				) else (
					cls&echo ѡ�����
				)
			)
		)
	)
)

goto :bg
:: %1 = type[add|del], %2 = filepath
:regauto
set regstate=false
if "%1" == "add" (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v %~n2 /d "cmd /c pushd %~dp0&start /min %~fs2 %3"  /f >nul 2>&1
	if "!errorlevel!" == "0" set regstate=true
)
if "%1" == "del" (
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "%~n2" /f >nul 2>&1
	if "!errorlevel!" == "0" set regstate=true
)
goto :eof

:tel
echo\
echo\
echo 			�Ʊ��ݷ���˰�װ����
echo\
echo 1.��ӷ���˳���������
echo\
echo 2.��������ɾ������˳���
echo\
echo 3.����һ�η���˳���
echo\
echo 4.��ȡ�û�״̬
echo\
echo 5.δ����
goto :eof

:uac
if %Uac% == N (
	echo Ȩ�޲���,���Թ���Ա������С�
	goto :bg
) else (
	goto :eof
)
