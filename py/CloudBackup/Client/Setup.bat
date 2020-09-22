::用于对 backfilec 的调用和设置

@echo off
setlocal enabledelayedexpansion
title CloudBackupSetupTools 
pushd %~dp0

::---------var---------
set rfp="B-CloudC.exe"
for /f "delims=" %%a in ('dir /s/b %rfp%') do set afp="%%~a"
(echo "UAC TEST.%Random%.temp" >"%windir%\U.T"&&set Uac=Y&&del %windir%\U.T||set Uac=N)>nul 2>&1
::---------var---------

:bg
call :tel
set /p func=请选择需要的功能:
if %func% == 1 (
	cls
	call :uac
	call :regauto add %afp% conf

	if !regstate! == true (echo 添加成功) else (echo 添加失败)
) else (
	if %func% == 2 (
		cls
		call :uac
		call :regauto del %afp%
		if !regstate! == true (echo 移除成功) else (echo 移除失败)
	) else (
		if %func% == 3 (
			cls
			call %rfp% conf
		) else (
			if %func% == 4 (
				cls
				call %rfp% down
			) else (
				if %func% == 5 (
					cls
					echo 未开放
				) else (
					cls&echo 选择错误
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
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "%~n2" /d "cmd /c pushd %~dps0&start /min %~fs2 %3"  /f >nul 2>&1
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
echo 			云备份安装工具
echo\
echo 1.添加备份程序到启动项
echo\
echo 2.从启动项删除备份程序
echo\
echo 3.启动一次备份程序
echo\
echo 4.从服务器下载已备份文件
echo\
echo 5.未开放
echo\
goto :eof

:uac
if %Uac% == N (
	echo 权限不足,请以管理员身份运行。
	goto :bg
) else (
	goto :eof
)
