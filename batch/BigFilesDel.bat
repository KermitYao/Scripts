::code by nameyu8023 cmd@WinXP
@echo off
setlocal enabledelayedexpansion
mode con: cols=77 lines=23
title ���ļ���С����
color 6f
:memu
echo\
echo ���ļ�����.
echo                ------------------------------------------
echo               ��              ����                     ��
echo               ��                                       ��
echo               ��1.   ���ļ��Ĵ�С�������ļ�.           ��
echo               ��                                       ��
echo               ��2. ����ָ�������ļ��Ĵ�С��·��.       ��
echo               ��                                       ��
echo               ��3. ����ѡ���Ƿ���Ҫ�Զ�ɾ��.           ��
echo               ��                                       ��
echo               ��                                       ��
echo                ------------------------------------------
echo\
echo ������·��,����ֱ������(Ĭ��Ϊȫ������):
set path_=
set /p "path_="
if [%path_%]==[] (
	call :diskall
	echo !path_!
) else (
	if not exist %path_%\ (
		cls
		echo �������,����������.
		echo -----------------------------
		goto memu
	)
)
echo\
echo �������ļ���Сֵ,��MByteΪ��λ(Ĭ��Ϊ300 MByte):
set /p size_=
if [%size_%]==[] (
	set "size_=300"
	echo !size_!
) else (
	for /f "delims=" %%a in ('echo %size_%^|findstr "[^0-9^$]"') do (
		cls
		echo �������,����������.
		echo -----------------------------
		goto memu
		)
)

:next
cls
echo ɨ��·�� [%path_%]
echo\
echo ��С�ļ�[%size_%] MB
echo\
echo ɨ���У��Ե�...
del /q/f %temp%\Big_Files.log >nul 2>nul
for %%a in (%path_%) do (
	if exist %%a (
		title ����ɨ��·�� [%%a] ...
		for /f "delims=" %%b in ('dir /a-d/b/s %%a') do (
			if exist %%~b (
				set /a size=%%~zb/1048576 >nul 2>nul
				if !size! gtr %size_% (
					set /a file_num+=1
					echo %%~fsb >>%temp%\Big_Files.log
					echo [%%~b]-[!size!] MB
					title ɨ��·�� [%path_%] ��ǰ�ļ�����[!file_num!]
				)
			)
		)
	)
)
start %temp%\Big_Files.log
cls
echo ɨ�����.
for /l %%a in (1,1,3) do echo\
echo ɨ��·�� [%path_%]
echo\
echo ��С�ļ�[%size_%] MB
echo\
echo    �� [!file_num!] ������ [%size_% MB] ���ļ�.
echo\
echo                      �Ƿ���Ҫɾ��?
echo\
echo   �� �� ѡ �� �� ( Y / N ) :
:xz
echo set tmp=y >%temp%\temp1.bat
echo set tmp=n >%temp%\temp2.bat
xcopy %temp%\temp1.bat %temp%\temp2.bat >nul
call %temp%\temp2.bat
if %tmp%==y goto Delete
if %tmp%==n EXIT
goto xz


:Delete
cls
set tmp6=!file_num!
for /f "delims=" %%a in ('type "%temp%\Big_Files.log"') do (
	set /a tmp6-=1
	title ����ɾ�� !file_num!\!tmp6!
	echo ɾ�� %%a OK!
	del /q /f %%a >nul 2>nul
)

echo\
echo\
echo      �� [!file_num!] ������ [%size_% MB] ���ļ�,ɾ�����!
echo\
echo                     ��������˳�.
pause>nul
exit

:diskall
for %%a in (c d e f g h i j k l m n o p q r s t u v w x y z) do (
	if exist %%a: (
		set path_=!path_! %%a:
	)
)
goto :eof