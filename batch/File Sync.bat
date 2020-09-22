::code by NGrain  cmd@win10 time:2017-04-24 20:59 
@echo off
setlocal enabledelayedexpansion
Title 文件同步
mode con: cols=80 lines=25
::--------------user variable---------------------

set back_bidirectional=true
set back_Accurate=3
set back_Speed_num=25
::--------------user variable---------------------

::fsutil fsinfo drivetype c:

::--------------system variable---------------------

set back_Prompt_f1=----------------------------------
set back_Catalog_count=0
set back_file_count=0
set back_wait=true
call :back_timename
set back_log=%temp%\back%back_timename%.t.p
set back_vbs=%temp%\back%back_timename%.vbs

set back_hex_GB=1073741824
set back_hex_MB=1048576
set back_hex_KB=1024
set back_hex_B=1

set back_totalsize=0

::--------------system variable---------------------

:back_Maininterface

::goto tmp

::用户输入第一个路径

call :back_ui_help
set /p back_user_input_p1=输入第一个目录:
call :back_path_correct back_user_input_p1
if exist "!back_path_correct!\" (
	set back_user_input_p1=!back_path_correct!
	) else (
	cls
	echo [%back_user_input_p1%]
	echo %back_Prompt_f1%
	echo 这是个错误的目录.
	goto :back_Maininterface
)
::用户输入第二个路径
:back_user_2
set /p back_user_input_p2=输入第二个目录:
:back_Maininterface
call :back_path_correct back_user_input_p2
if exist "!back_path_correct!\" (
	set back_user_input_p2=!back_path_correct!
	) else (
	cls
	echo [%back_user_input_p2%]
	echo %back_Prompt_f1%
	echo 这是个错误的目录.
	goto :back_Maininterface
)
if /i "%back_user_input_p2%" == "" (
	cls
	echo %back_Prompt_f1%
	echo 输入不能为空.
	call :back_ui_help
	goto back_user_2
)



::获取需同步文件夹
cls
echo %date% %time%
echo  从目录 [%back_user_input_p1%].
echo  至目录 [%back_user_input_p2%].
echo %back_Prompt_f1%
set /p=正在获取相关信息<nul
set back_tmptime=%date% %time:~,-3%

call :back_strlen_count "!back_user_input_p1!\"
set back_p1_count=%back_strlen_count%
call :back_strlen_count "!back_user_input_p2!\"
set back_p2_count=%back_strlen_count%

if /i "%back_bidirectional%" == "true" (
	call :back_set_tree "!back_user_input_p1!\" "!back_user_input_p2!\" %back_p1_count%
	call :back_set_tree "!back_user_input_p2!\" "!back_user_input_p1!\" %back_p2_count%
	call :back_set_file "!back_user_input_p1!\" "!back_user_input_p2!\" %back_p1_count%
	call :back_set_file "!back_user_input_p2!\" "!back_user_input_p1!\" %back_p2_count%
)

if /i "%back_bidirectional%" == "false" (
call :back_set_tree "!back_user_input_p1!\" "!back_user_input_p2!\" %back_p1_count%
call :back_set_tree "!back_user_input_p2!\" "!back_user_input_p2!\" %back_p2_count%
)


call :back_set_unit !back_totalsize! %back_vbs%
if not %back_totalsize% equ 0 call :back_vbs_calc !back_totalsize!/!back_hex_%back_unit%! %back_vbs%
set back_totalsize=%back_vbs_calc% %back_unit%
echo\
echo %back_Prompt_f1%
echo  需 同 步 目 录 数 [%back_Catalog_count%].
echo  需 同 步 文 件 数 [%back_file_count%].
echo  需 同 步 总 大 小 [%back_totalsize%]
echo %back_Prompt_f1%
if not %back_Catalog_count% equ 0 (
	echo 建立目录信息:
	for /f "delims=: tokens=1*" %%a in ('findstr /i "Catalog" %back_log%') do (
		set /a back_catalog_count_tmp+=1
		call :back_Small_files "%%~b"
		title 目录进度: !back_catalog_count_tmp!/%back_Catalog_count% 目录名: !back_small_tmp2!
		md "%%~b"
		call :back_vbs_calc !back_catalog_count_tmp!/%back_Catalog_count%*100 %back_vbs%
		call :back_Speed !back_vbs_calc! !back_vbs_calc!
	)
	echo\
	echo %back_Prompt_f1%
)
if not 	%back_file_count% equ 0 (
	echo 同步文件信息:
	for /f "delims=/ tokens=1-4" %%a in ('findstr /i "file" %back_log%') do (
		call :back_set_unit %%d %back_vbs%
		call :back_cut back_hex_tmp back_hex_!back_unit!
		call :back_vbs_calc %%d/!back_hex_tmp! %back_vbs%
		set /a back_file_count_tmp+=1
		title 文件进度: !back_file_count_tmp!/%back_file_count% 大小: !back_vbs_calc!!back_unit!  文件名:"%%~nxb
		copy /y %%b %%c >nul 2>nul
		call :back_vbs_calc !back_file_count_tmp!/%back_file_count%*100 %back_vbs%
		call :back_Speed !back_vbs_calc! !back_vbs_calc!
	)
	echo\
	echo %back_Prompt_f1%

)
:back_null
call :back_outtime "%back_tmptime%" "%date% %time:~,-3%"
Title 文件同步
echo  文 件 同 步 完 成. 
echo %back_Prompt_f1%
echo  耗时:%D%天%H%时%M%分%S%秒.
echo %back_Prompt_f1%
echo  双向同步:[%back_bidirectional%]
echo  同步日志:[%back_log%]
echo  总大小:[%back_totalsize%]
echo %back_Prompt_f1%
pause>nul
if exist %back_log% start notepad %back_log%
exit /b 2










::echo p1strcount=%back_strlen_count%  p1=!back_user_input_p1! p2=!back_user_input_p2! log=%back_log% tmst=%back_time_state% catalogcount=%back_Catalog_count% filecount=%back_file_count% outtime=%D%Day %H%Hour %M%Minute %S%Second




::获取时间前后状态
:back_time_state
set /a back_difference=(%d%*24*60*60)+(%h%*60*60)+(%m%*60)+%s%
if %back_difference% gtr 0 (set back_time_state=1)
if %back_difference% equ 0 (set back_time_state=0)
if %back_difference% lss 0 (set back_time_state=-1)
goto :eof



::计算耗时 (call :outtime "2015-09-09 12:12:12.06" "%date% %time%")
:back_outtime
for /f "tokens=1,2,3,4,5,6,7 delims=-/:. " %%i in ("%1") do ((set Y1=%%i) && (set M1=%%j) && (set D1=%%k) && (set H1=%%l) && (set F1=%%m) && (set S1=%%n) && (set MS1=%%o))
for /f "tokens=1,2,3,4,5,6,7 delims=-/:. " %%i in ("%2") do ((set Y2=%%i) && (set M2=%%j) && (set D2=%%k) && (set H2=%%l) && (set F2=%%m) && (set S2=%%n) && (set MS2=%%o))
set /a secs=((d2-32075+1461*(y2+4800+(m2-14)/12)/4+367*(m2-2-(m2-14)/12*12)/12-3*((y2+4900+(m2-14)/12)/100)/4)*86400+H2*3600+F2*60+S2)-((d1-32075+1461*(y1+4800+(m1-14)/12)/4+367*(m1-2-(m1-14)/12*12)/12-3*((y1+4900+(m1-14)/12)/100)/4)*86400+H1*3600+F1*60+S1)
set /a D=secs/86400,H=(secs%%86400)/3600,M=(secs%%3600)/60,S=secs%%60
::echo.%1与%2之间相隔:%D%天%H%时%M%分%S%秒
goto :eof


::获取底层目录 接收参数 %1 返回 [back_small_tmp2]
:back_Small_files
set back_small_tmp1=%~1
for /l %%a in (1,1,100) do (
	for /f "delims=\ tokens=1*" %%b in ("!back_small_tmp1!") do (
		set back_small_tmp1=%%c
		set back_small_tmp2=%%b

	)
)
goto :eof

::获取同步所需目录 接收参数 源目录[%1] 目标目录[%2] 源目录字符数[%3] 返回 获取路径[%back_log%] 
:back_set_tree
for /f "delims=" %%a in ('dir /ad-s/b/s "%~1"') do (
	if "!back_wait!" == "true" (call :back_wait !back_wait!&set back_wait=false) else (call :back_wait !back_wait!&set back_wait=true)
	set back_path_source_tmp=%%~a
	if not exist "%~2!back_path_source_tmp:~%3!" (	
		set /a back_Catalog_count+=1
		echo Catalog:%~2!back_path_source_tmp:~%3!
	)>>%back_log%
)

goto :eof



::获取同步所需文件 接收参数 源目录[%1] 目标目录[%2] 源目录字符数[%3] 返回 获取路径[%back_log%] 
:back_set_file

(for /f "delims=" %%a in ('dir /a-d-s/b/s "%~1"') do (
if "!back_wait!" == "true" (call :back_wait !back_wait!&set back_wait=false) else (call :back_wait !back_wait!&set back_wait=true)
	set back_path_source_tmp2=%%~a
	if not exist "%~2!back_path_source_tmp2:~%3!" (
		set /a back_file_count+=1
		call :back_vbs_calc !back_totalsize!+%%~za %back_vbs%
		set back_totalsize=!back_vbs_calc!
		(echo file: / "%%~a" / "%~2!back_path_source_tmp2:~%3!" / %%~za)>>%back_log%
	) else (
		call :back_time_state "!back_path_source_tmp2!" "%~2!back_path_source_tmp2:~%3!"
		if /i "%back_bidirectional%" == "true" (
			if "!back_time_state!" == "-1" (
				set /a back_file_count+=1
				call :back_vbs_calc !back_totalsize!+%%~za %back_vbs%
				set back_totalsize=!back_vbs_calc!
				(echo file: / "%%~a" / "%~2!back_path_source_tmp2:~%3!" / %%~za)>>%back_log%
			)
		)
		if /i "%back_bidirectional%" == "false" (
			if /i not "!back_time_state!" == "0" (
				set /a back_file_count+=1
				call :back_vbs_calc !back_totalsize!+%%~za %back_vbs%
				set back_totalsize=!back_vbs_calc!
				(echo file: / "%%~a" / "%~2!back_path_source_tmp2:~%3!" / %%~za)>>%back_log%
			)
		)		
	)

))2>nul
goto :eof

::获取时间前后状态 传递参数 file1 file2 返回 %back_time_state%
:back_time_state
call :back_outtime "%~t2" "%~t1"
set /a back_difference=(%d%*24*60*60)+(%h%*60*60)+(%m%*60)+%s%
if %back_difference% gtr 0 (set back_time_state=1)
if %back_difference% equ 0 (set back_time_state=0)
if %back_difference% lss 0 (set back_time_state=-1)

goto :eof




::判断写入权限 接受参数 路径 %1  返回  false true 
:back_uac
set back_uac=false
call :back_timename
echo %back_timename%_%1 >%1\%back_timename%_tmp.tmp
if exist %%a\%back_timename%_tmp.tmp (
	set back_uac=true
	del /q/f "%1\%back_timename%_tmp.tmp"
	goto :eof
)
goto :eof 




::获取时间  返回  back_timename
:back_timename
set back_timename=%date:~,10%%time:~,8%
set back_timename=%back_timename:/=%
set back_timename=%back_timename:-=%
set back_timename=%back_timename: =%
set back_timename=%back_timename::=%
goto :eof


::修正路径，去 ["] 去 [\] 接收参数 %1 返回 [back_path_correct]
:back_path_correct
set back_path_correct_tmp=!%1!
set back_path_correct=!back_path_correct_tmp:"=!
if "!back_path_correct:~-1!" == "\" set "back_path_correct=!back_path_correct:~,-1!"
goto :eof


::计算字符数量 接收参数[%1] 返回 [back_strlen_count]
:back_strlen_count
set back_strlen_count_tmp=%~1
for /l %%a in (0,1,100) do (
	if "!back_strlen_count_tmp:~%%a,1!"=="" (
		set back_strlen_count=%%a
		goto :eof
		)
)
goto :eof



::计算数据单位  接收参数 数值 [%1] 临时文件写入路径 [%2] 返回 [back_unit （GB MB KB B）]
:back_set_unit
set back_unit=
for %%a in (back_hex_GB back_hex_MB back_hex_KB back_hex_B ) do (
	set back_unit_tmp=%%a
	call :back_vbs_calc int^(%1/!%%a!^) %2
	if !back_vbs_calc! gtr 0 (set back_unit=!back_unit_tmp:~9!&goto :eof)
)
set back_unit=!back_unit_tmp:~9!
goto :eof


::数学计算 接收参数 计算公式 [%1] 临时文件写入路径 [%2] 返回 [back_vbs_cal]
:back_vbs_calc
set back_vbs_calc=
echo WSH.echo " "^&Cdbl(%1) >%2
for /f "delims=. tokens=1*" %%x in ('cscript //nologo %2') do (
	set back_vbs_calc=%%y
	if not "%%y" == "" (set back_vbs_calc=.!back_vbs_calc:~,2!)
	if "%%x" == " " (set back_vbs_calc=0!back_vbs_calc!)
	set back_vbs_calc=%%x!back_vbs_calc!
	set back_vbs_calc=!back_vbs_calc: =!
)

goto :eof

::多重变量获取 接收参数 变量名 [%2] 接收变量名 [%1]  返回 [%1]
:back_cut
set %1=!%2!
goto :eof


::进度显示 接收参数 进度百分比 [%1] 字符串 [%2] 返回进度
:back_Speed

::call :back_strlen_count %2
call :back_vbs_calc int(%1/(100/!back_Speed_num!)) %back_vbs%
set back_Speed_true=!back_vbs_calc!
set /a back_Speed_false=back_Speed_num-0-!back_Speed_true!
::set /a back_Speed_fall=back_Speed_num*2+2+!back_strlen_count!
set /a back_Speed_fall=back_Speed_num*2+2
set /p=[<nul
for /l %%a in (1,1,%back_Speed_true%) do ( 
set /p=■<nul
)
for /l %%a in (1,1,%back_Speed_false%) do ( 
set /p=□<nul
)
set /p=]<nul
for /l %%a in (1,1,%back_Speed_fall%) do (
set /p=<nul
)
goto :eof


::等待动画 接收参数 [%1] true  false
:back_wait
if "%1" == "true" set /p=//////<nul
if "%1" == "false" set /p=\\\\\\<nul
set /p=<nul
goto :eof


::帮助 UI
:back_ui_help
echo %back_Prompt_f1%
echo  对指定的两个目录进行同步.
echo\
echo  默认双向同步,以修改日期晚的为准.
echo\
echo  若在目录的结尾加"//",则进行单向同步.
echo\
echo  单向同步以第一个目录为准.
echo %back_Prompt_f1%
goto :eof