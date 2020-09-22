::ngrain&win10&cmd&2018119

@echo off

if not "%~1" =="" (
	if "%~1"=="a" (
		call :regInfo True
		exit /0
	)
	if "%~1"=="b" (
		call :regInfo False
		exit /0
	)
)


call :tips 5

set /p i=请选择^<a^|b^>:
if '%i%'=='a' (
	call :regInfo True
	echo Done
	ping /n 4 127.1 >nul
)
if '%i%'=='b' (
	call :regInfo False
	echo Done
	ping /n 4 127.1 >nul
)

::true|no
:regInfo
if '%1' == 'True' (
	reg add "HKEY_CURRENT_USER\Software\4078793D850F3A2D28F7BCE56C1891C6\3F7539FB95C675225F37F3F155556F1D\Register.ini" /t REG_SZ /v UsedType /d "2" /f
	reg add "HKEY_CURRENT_USER\Software\4078793D850F3A2D28F7BCE56C1891C6\3F7539FB95C675225F37F3F155556F1D\Register.ini" /t REG_SZ /v UsedValue /d "99" /f 
)>nul 2>&1
if '%1' == 'False' (
	reg add "HKEY_CURRENT_USER\Software\4078793D850F3A2D28F7BCE56C1891C6\3F7539FB95C675225F37F3F155556F1D\Register.ini" /t REG_SZ /v UsedType /d "2" /f
	reg add "HKEY_CURRENT_USER\Software\4078793D850F3A2D28F7BCE56C1891C6\3F7539FB95C675225F37F3F155556F1D\Register.ini" /t REG_SZ /v UsedValue /d "2" /f
)>nul 2>&1
goto :eof

:tips
for /l %%a in (1,1,%1) do echo\
echo 		a.重置试用模式 [99天]
echo\
echo 		b.立即重新注册
echo\
goto :eof