@echo off
setlocal enabledelayedexpansion
title Uninstall 360 safe
echo ����360��ȫ����
set findPath=360\360sd\Uninst.exe 360\360Safe\uninst.exe

for %%a in (%findPath%) do (
	if not "#"=="#%%a" (
		call :get360Path %%a
		if exist "!returnValue!" (
			echo ж��: %%a, ��������أ�������������ɡ�
			start "" "!returnValue!"
		)
	)
)

if "#Null"=="#!returnValue!" echo ������Կ���û�а�װ360��ȫ���.
pause
exit


rem ��ȡoffice��װ·��;return=Null|officePath
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
