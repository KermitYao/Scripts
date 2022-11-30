@echo off
setlocal enabledelayedexpansion
set srv="EraAgentSvc" "ekrn" "EIConnectorSvc" "ManageEngine AssetExplorer Agent" "INODE_SVR_SERVICE" "CGEDataService" 
set flag=NO
pushd %temp%
for %%a in (%srv%) do (
	for /f  "delims=: tokens=1*" %%x   in (%%a) do (
		sc query %%x >nul&&set flag=YES||set flag=NO
		if !flag!==NO (
			set /p=%%x--%%y--<nul
			>"NO" echo.
			findstr /a:04 .* "NO*"
			echo\
			del /q/f NO
		) else (
			set /p=%%x--%%y--<nul
			>"YES" echo.
			findstr /a:09 .* "YES*"
			del /q/f YES
			echo\
		)
	)
)
popd
echo 本机包含以下账户:
set userList= 
for /f "delims=" %%a in ('net user^|findstr -v " \\ ---  "^|findstr /v "命令成功完成"') do (
		set userList=!userList! %%a
	)
)
for %%a in (%userList%) do echo %%a
echo end...
pause

