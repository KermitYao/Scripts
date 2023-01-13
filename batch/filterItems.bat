@echo off
setlocal enabledelayedexpansion
set exitCode=0

call :isFile "%~1"
if !return!==False (
    echo 未找到360列表文件:"%~1"
    set exitCode=1
)

call :isFile "%~2"
if !return!==False (
    echo 未找到域控列表文件:"%~1"
    set exitCode=1
)
if %exitCode% equ 0 (
    echo 360列表文件:"%~1", 域控列表文件:"%~1", 按任意键开始匹配.
) else (
    echo 获取文件列表出错.
    pause
    exit /b 0
)
pause>nul

call :matchUser "%~1" "%~2"
exit /b 0

:isFile
set return=False
if exist "%~1" (
	if not exist "%~1\" (
		set return=True
	)
)
goto :eof

:matchUser

for /f "delims=, tokens=1-3" %%a in ('type "%~2"') do (
	if not "%%c"=="" (
		set tmpFlag=False
		echo findstr "^%%a," "%~1" ^>nul^&^&set tmpFlag=True
		findstr "^%%a," "%~1" >nul&&set tmpFlag=True
		if !tmpFlag!==False (
			echo %%a	%%c
			(echo %%a	%%c)>>noInstList.txt
		)
	)
)

goto :eof

:comment

    for /f "delims=, tokens=1" %%x in ('type "%~1"') do (
        if "%%~a"=="%%x" (
			set tmpFlag=True
        )
    )
goto :eof