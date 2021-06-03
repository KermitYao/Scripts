@echo off
setlocal enabledelayedexpansion
title Uninstall 360 safe
echo 查找360安全程序
set findPath=360\360sd\Uninst.exe 360\360Safe\uninst.exe

for %%a in (%findPath%) do (
	if not "#"=="#%%a" (
		call :get360Path %%a
		if exist "!returnValue!" (
			echo 卸载: %%a, 如果有拦截，请允许操作即可。
			start "" "!returnValue!"
		)
	)
)

if "#Null"=="#!returnValue!" echo 这个电脑可能没有安装360安全软件.
pause
exit


rem 获取office安装路径;return=Null|officePath
:get360Path
set drive=c d e f g h i j k l m n o p q r s t u v w x y z
set 360Path=
for %%a in (%drive%) do (
	if exist %%a:\ (
		for /d %%l in ("%%a:\Program Files*") do (
			for /f "delims=" %%x in ('dir /a-d/b/s  "%%l\%~1"2^>nul') do (
				if exist "%%x" (
					set 360Path=%%x
					goto :get360PathBreak
				)
			)
		)
	)
)
:get360PathBreak
if "#"=="#!360Path!" (
	set returnValue=Null
) else (
	set returnValue=!360Path!
)

goto :eof
