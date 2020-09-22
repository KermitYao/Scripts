::code by nameyu8023 cmd@WinXP
@echo off
setlocal enabledelayedexpansion
mode con: cols=77 lines=23
title 按文件大小搜索
color 6f
:memu
echo\
echo 大文件搜索.
echo                ------------------------------------------
echo               ︳              帮助                     ︳
echo               ︳                                       ︳
echo               ︳1.   按文件的大小来搜索文件.           ︳
echo               ︳                                       ︳
echo               ︳2. 可以指定搜索文件的大小和路径.       ︳
echo               ︳                                       ︳
echo               ︳3. 可以选择是否需要自动删除.           ︳
echo               ︳                                       ︳
echo               ︳                                       ︳
echo                ------------------------------------------
echo\
echo 请输入路径,可以直接拖入(默认为全盘搜索):
set path_=
set /p "path_="
if [%path_%]==[] (
	call :diskall
	echo !path_!
) else (
	if not exist %path_%\ (
		cls
		echo 输入错误,请重新输入.
		echo -----------------------------
		goto memu
	)
)
echo\
echo 请输入文件最小值,以MByte为单位(默认为300 MByte):
set /p size_=
if [%size_%]==[] (
	set "size_=300"
	echo !size_!
) else (
	for /f "delims=" %%a in ('echo %size_%^|findstr "[^0-9^$]"') do (
		cls
		echo 输入错误,请重新输入.
		echo -----------------------------
		goto memu
		)
)

:next
cls
echo 扫描路径 [%path_%]
echo\
echo 最小文件[%size_%] MB
echo\
echo 扫描中，稍等...
del /q/f %temp%\Big_Files.log >nul 2>nul
for %%a in (%path_%) do (
	if exist %%a (
		title 正在扫描路径 [%%a] ...
		for /f "delims=" %%b in ('dir /a-d/b/s %%a') do (
			if exist %%~b (
				set /a size=%%~zb/1048576 >nul 2>nul
				if !size! gtr %size_% (
					set /a file_num+=1
					echo %%~fsb >>%temp%\Big_Files.log
					echo [%%~b]-[!size!] MB
					title 扫描路径 [%path_%] 当前文件数量[!file_num!]
				)
			)
		)
	)
)
start %temp%\Big_Files.log
cls
echo 扫描完成.
for /l %%a in (1,1,3) do echo\
echo 扫描路径 [%path_%]
echo\
echo 最小文件[%size_%] MB
echo\
echo    共 [!file_num!] 个大于 [%size_% MB] 的文件.
echo\
echo                      是否需要删除?
echo\
echo   你 的 选 择 ？ ( Y / N ) :
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
	title 正在删除 !file_num!\!tmp6!
	echo 删除 %%a OK!
	del /q /f %%a >nul 2>nul
)

echo\
echo\
echo      共 [!file_num!] 个大于 [%size_% MB] 的文件,删除完成!
echo\
echo                     按任意键退出.
pause>nul
exit

:diskall
for %%a in (c d e f g h i j k l m n o p q r s t u v w x y z) do (
	if exist %%a: (
		set path_=!path_! %%a:
	)
)
goto :eof