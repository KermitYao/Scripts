@echo off
setlocal enabledelayedexpansion
set srv="EraAgentSvc" "ekrn" "EIConnectorSvc"  "INODE_SVR_SERVICE" "CGEDataService" 
set flag=NO
pushd %temp%
for %%a in (%srv%) do (
	for /f  "delims=: tokens=1*" %%x   in (%%a) do (
		sc query %%x >nul&&set flag=YES||set flag=NO
		if !flag!==NO (
			set /p=%%x--%%y--<nul
			echo.NO

		) else (
			set /p=%%x--%%y--<nul
			echo.YES

		)
	)
)
popd
echo �������������˻�:
set userList= 
for /f "delims=" %%a in ('net user^|findstr -v " \\ ---  "^|findstr /v "����ɹ����"') do (
		set userList=!userList! %%a
	)
)
for %%a in (%userList%) do echo %%a
echo end...
pause

