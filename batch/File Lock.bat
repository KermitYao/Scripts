::code by nameyu8023 cmd@Win7 2015.08.12������
@echo off
setlocal enabledelayedexpansion
mode con: cols=60 lines=23

>nul 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\Getadmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\Getadmin.vbs"
    "%TEMP%\Getadmin.vbs"
    DEL /f /q "%TEMP%\Getadmin.vbs" 2>nul
    Exit /b
)

color 6f
cd /d "%~dp0"
title File Lock    %cd%

::----------------�û�����--------------------
::��Ҫ���˵��ļ���
set Lock_Exception="RECYCLER" "System Volume Information" "$RECYCLE.BIN"
::�Ƿ������
set Lock_TreeC=/t
if "%Lock_TreeC%"=="/t" set Lock_TreeT=/r
::----------------�û�����--------------------

::----------------��ʼ����--------------------
set Lock_Default_Perm=R
set Lock_Perm_N=��Ȩ��
set Lock_Perm_R=�ɶ�ȡ
set Lock_Perm_F=�ɶ�д
set Lock_Perm_NOT=δ����
::----------------��ʼ����--------------------

::����UAC
(echo "UAC TEST.%Random%.temp" >"%windir%\U.T"&&set Uac=Y&&del %windir%\U.T||set Uac=N)>nul 2>&1
if [%gm_Uac%]==[N] (
	echo\
	echo\
	echo\
	echo\
	echo ��Щ������Ҫ����ԱȨ��,���Ҽ��Թ���Ա������У�
	pause >nul
	exit
)
If not [%1]==[] (
	Call :Lock_Perm %1
	If not [!Lock_Tmp1!]==[!Lock_Default_Perm!] (
		Call :Lock_Alc "%~1" !Lock_Default_Perm!
		Call :Lock_Ses ������
	) else (
		Call :Lock_Alc "%~1" F
		Call :Lock_Ses �ѽ���
	)
	Exit
)
set Lock_Num=0

for /f "delims=" %%a in ('dir /ad/b') do (
	set Lock_Tmp=0
	For %%b in (%Lock_Exception%) do (
		set Lock_Tmp1=%%b
		set Lock_Tmp1=!Lock_Tmp1:"=!
		If /i [%%a]==[!Lock_Tmp1!] (
			set Lock_Tmp=1
			)
		)
	If !Lock_Tmp! equ 0 (
		Call :Lock_Perm "%%a"
		set /a Lock_Num+=1
		set Lock_Path_!Lock_Num!=%%a
		Call :Lock_blhq Lock_Perm_Tmp Lock_Perm_!Lock_Tmp1!
		echo [!Lock_Perm_Tmp!]----^>^> [%%a]
		Echo -----------------------------------------------
	)
)
If !Lock_Num! gtr 0 (
	Echo ����ΪȨ������,��[!Lock_Num!]��Ŀ¼.
	) else (
	Echo δ�ҵ��ɲ���Ŀ¼.
	Goto :Next
)
echo\
echo    1.ȫ������    2.ȫ������
set /p Lock_User=��ѡ��:
Cls
If [%Lock_User%]==[1] (
	for /l %%a in (1,1,!Lock_Num!) do (
		Call :Lock_Alc  "!Lock_Path_%%a!" %Lock_Default_Perm%
	)
)
If [%Lock_User%]==[2] (
	for /l %%a in (1,1,!Lock_Num!) do (
		Call :Lock_Alc  "!Lock_Path_%%a!" F
	)
)
:Next
If [%Lock_User%]==[1] (
	Call :Lock_Ses ������
	) else (
	If [%Lock_User%]==[2] (
		Call :Lock_Ses �ѽ���
		) else (
		Call :Lock_Ses δѡ��
	)
)
exit


::�ж�Ȩ��
:Lock_Perm
Set Lock_Tmp1=
For /f "delims=" %%a in ('Cacls %1 2^>nul ^|Findstr /i "Everyone"') do (
	set Lock_Tmp1=%%a
	set Lock_Tmp1=!Lock_Tmp1: =!
	set Lock_Tmp1=!Lock_Tmp1:~-1!

)
If /i [%Lock_Tmp1%]==[] (
	Set Lock_Tmp1=Not
)
Goto :eof

::����Ȩ��
:Lock_Alc
Takeown %Lock_TreeT% /d y /f "%~1" >nul 2>&1
Echo Y|Cacls "%~1" %Lock_Tree% /p Everyone:%2 >nul 2>&1
Echo [�������] [%~1]
Echo -----------------------------------------------
Goto:eof

::��Ч
:Lock_Ses
set /p=    %1... <nul 
for %%b in (4 3 2 1) do (
	set /p=%%b  <nul
	ping /n 2 127.1>nul
)
Goto :eof



::���ر�����ȡ
:Lock_blhq
set %1=!%2!
goto :eof
