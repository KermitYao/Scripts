@echo off
Net session >nul 2>&1 || (echo Start-Process  -FilePath %~fs0   -verb  runas | powershell - &exit)
setlocal enabledelayedexpansion
mode con: cols=60 lines=23
color 6f
title FAT To NTFS
set UAC_file=%SystemRoot%\System32\%gm_Btxs%%Random%.temp
(echo "%gm_Btxs%" >"%UAC_file%")>nul 2>nul
if exist "%UAC_file%" (
	set gm_Uac=Y
	del "%UAC_file%"
	) else (
	set gm_Uac=N
)
if [!gm_Uac!]==[N] (
	echo 权限不够,请以管理员身份运行...
	pause>nul
	exit
)
echo\
echo                    FAT格式转换NTFS格式.
for /l %%a in (1,1,5) do echo\
for %%a in (c d e f g h i j k l m n o p q r s t u v w x y z) do (
	if exist %%a: (
		set /a num+=1
		set disk_!num!=%%a
		set /p=!num!.[%%a] <nul
	)
)
echo\
echo\
set /p Input=请选择一个盘符:
for /l %%a in (1,1,%num%) do (
	if [%%a]==[%input%] (
		convert !disk_%%a!: /fs:NTFS&&echo 成功&pause>nul&exit
	)
)
echo 失败
pause>nul&exit