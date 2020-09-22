::code by nameyu8023 cmd@Win10  201611191106
@echo off
:Main
setlocal enabledelayedexpansion

::-----------------User var-----------------
::隐含文件搜索类型
set include=.txt .ini .inf .bat .cmd .log .xml
::包含盘符
set vol=D E F G H I J K L M N O P Q R S T U V W X Y Z
::-----------------User var-----------------



::-----------------Begin code-----------------
::搜索隐含文件,状态:False . True
set Include_state=False
::生成以时间命名
set logname=%date:~,10%%time:~,8%
set logname=%logname:/=%
set logname=%logname:-=%
set logname=%logname: =%
set logname=%temp%\Search_%logname::=%.log


::静默 参数
set Silence=False

::命令 参数
set cmd_Bl=False

::静默 状态
set Silence_state=
if  "%Silence%"=="True" set Silence_state=^>nul

::判断存在盘符
set search_vol=
for %%a in (%vol%) do (
	if exist %%a: (
		set "search_vol=!search_vol! %%a:"
	)
)

::判断参数状态 1=文件  2=文件夹 3=空 4=字符串
if exist "%~1" (
	set Pt_state=1
	if exist "%~1\" set Pt_state=2
	) else (
	if "%~1"=="" (
		set Pt_state=3
		) else (
		set Pt_state=4
	)	  
)

::设置参数状态
if "%Pt_state%" == "1" (echo ----系统提示:[%~1]不是一个有效的目录.&echo\)
if "%Pt_state%" == "2" (set search_vol="%~1")
if "%Pt_state%" == "4" set cmd_Bl=True

::判断是否为命令行
if "%cmd_Bl%" == "True" (
	::判断是否为帮助参数
	if '%1'=='/?' (
		::调用帮助模块
		call :cmd_help
		exit /b	
	) else (
	::设定参数
	set cmd_parameter=%1 %2 %3 %4 %5 %6 %7 %8 %9
	)
)

if "%cmd_Bl%" == "False" (
	title File Search tool
	color 6f
)
::判断命令行参数 /k:=关键字 /p:=目录 /q=静默 /i=隐含
if "%cmd_Bl%"=="True" (
	for %%a in (k p q i) do (
		set cmd_%%a=False
		call :cmd_pt cmd_parameter /%%a cmd_%%a
	)
)


::判断 /k 参数状态
set cmd_k_pt=False
if "%cmd_Bl%"=="True" (
	if "%cmd_k%"=="True" (
		call :cmd_pt_state cmd_parameter /k: cmd_k_str
		if not "!cmd_k_str!" == "" (
			set cmd_k_pt=True
		) else (
			echo String null.&exit /b
		)
	) else (
		echo Parameter is empty.&exit /b
	)
	
)


::判断 /p 参数状态

set cmd_p_pt=False
if "%cmd_k_pt%"=="True" (
	if "%cmd_p%"=="True" (
		call :cmd_pt_state cmd_parameter /p: cmd_p_str
		if not "!cmd_p_str!" == "" (
			set cmd_p_str=!cmd_p_str:"=!
			if exist "!cmd_p_str!\" (set cmd_p_pt=True) else (echo Path Error.&exit /b)
		) else (
			echo Path is empty.&exit /b
		)
	)
)



if "%cmd_Bl%" == "True" (
	if "%cmd_k_pt%" == "True" set search_keyword=%cmd_k_str%
	if "%cmd_p_pt%" == "True" set search_vol=%cmd_p_str%
	if "%cmd_q%" == "True" set Silence_state=^>nul
	if "%cmd_i%" == "True" set Include_state=True
)

::echo 参数状态=%Pt_state% 日志名称=%logname% 盘符=%search_vol% 是否命令=%cmd_Bl% 判断命令行参数k p q i=%cmd_k% %cmd_p% %cmd_q% %cmd_i% k参数=%cmd_k_pt% k字符=%cmd_k_str% p参数=%cmd_p_pt% p字符=%cmd_p_str%





::获取隐含类型
set Search_include=
for %%a in (%include%) do (
	set "Search_include=*%%a !Search_include!"
)
::提示
:userinput
if not "%cmd_Bl%"=="True" (
	call :ui_help
	echo\
	echo 扫描路径: [%search_vol%] .
	echo 隐含类型: [%include%]
)

::用户输入
if not "%cmd_Bl%"=="True" (
	set /p search_keyword=请输入关键字:
	set search_i=!search_keyword:~-2!
	if "!search_i!" == "//" (
		set search_keyword=!search_keyword:~,-2!
		set Include_state=True
	)
)

::判断是否输入为空
if [!search_keyword!] == [] cls&echo 输入不能为空.&goto userinput

::修正用户输入
for /f "tokens=1*" %%a in ("!search_keyword!") do set search_keyword=%%a
set tmptime=%date% %time%
::导出信息
(
echo 扫描路径:	[%search_vol%] .
echo 隐含类型:	[%include%]
echo 是否隐含:	[!Include_state!]
echo 扫描关键字:	[%search_keyword%]
echo 开始时间:	[%tmptime%]

echo -----------------------------------
echo\
)>%logname%



::准备搜索
set search_condition=
for %%a in (%search_vol%) do (
	
	::修正搜索关键字
	set "search_condition=*%search_keyword%*"
	
	::调用搜索模块
	Call :Error "Keyword:[!search_keyword!],Searched [%%a]..." 
	Call :SearchFile search_condition %%a
	::判断是否搜索隐含文件
	if "%Include_state%"=="True" (
		::修正隐含关键字
		set "search_condition=!Search_include!"
		::调用搜索模块
		Call :Error "Include Keyword:[!search_keyword!] file."
		call :SearchFile search_condition %%a %search_keyword%		
	)
)
call :outtime "%tmptime%" "%date% %time%"
::修正输出模式
if not "%cmd_Bl%"=="True" (
	
	::标准输出
	echo Cmd=Close >>%logname%
	echo 耗时:%D%天%H%时%M%分%S%秒 >>%logname%
	echo 耗时:%D%天%H%时%M%分%S%秒
	echo ----------end-------------
	echo\
	echo 已完成,按任意键打开日志.
	pause>nul
	start "" %logname%
	exit
	) else (
	
	::静默输出
	echo Cmd=Open >>%logname%
	echo CmdParameter=%cmd_parameter% >>%logname%
	echo Time Consuming:%D%Day %H%Hour %M%Minute %S%Second >>%logname%
	echo\
	echo Complete to export to:
	echo [%logname%]
	echo Time Consuming:%D%Day %H%Hour %M%Minute %S%Second
	exit /b
) 



::搜索模块
:SearchFile

::传递参数  %1=关键字 %2=目录 %3=隐含关键字
pushd %2
(

::搜索文件和文件夹
for /f "delims=" %%z in ('dir /b/s !%1! 2^>nul') do (
	
	::判断扫描条件
	if "%3" == "%search_keyword%" (

		::搜索隐含文件
		for /f "delims=: tokens=3" %%a in ('find /i /c "%3" "%%z" 2^>nul') do (
			set Include_tmp=%%a

			::判断是否隐含关键字
			if not "!Include_tmp: =!" == "0" (

				::隐含输出
				echo %%z n:!Include_tmp: =!
				(echo %%z n:!Include_tmp: =!)>>%logname%
				)
			)
		) else (
	
		::标准输出
		echo %%z
		(echo %%z)>>%logname%
	)
)
)%Silence_state%
popd
goto :eof

::错误模块
:Error
(
echo ----------System prompt:%1
echo ----------System prompt:%1>>%logname%
)%Silence_state%
goto :eof

::命令行帮助
:cmd_help
echo 搜索包含关键字的文件和文件夹。
echo\
echo %~n0 [/K:] [/P:] [/Q]  [/I]
echo\
echo   /K:	显示包含此字符串路径。
echo   /P:	指定一个目录,只在此目录中搜索;若不选择,则默认全盘搜索。
echo   /Q	静默执行,仅显示结果。
echo   /I	搜索包含字符串的文件。
echo\
echo /K:string 此选项是必须的,且只能有一个。
echo /P:"c:\test 1" 若路径中包含空格,应当用引号包含。
goto :eof



::界面帮助
:ui_help
echo 搜索包含关键字的文件和文件夹。
echo\
echo 直接拖入一个目录到此文件上,否则默认进行全盘搜索。
echo\
echo    此工具会搜索选择目录中,包含你所输入字符串的路径。
echo    若在所输入字符串的结尾加 "//", 则会同时列出内容包含关键字的文件。
echo\
echo 所搜索的字符串只能有一个,且不许是连续的。
goto :eof

::获取输入参数 %1=参数 %2=确认关键字 %3=接收变量

::判断传递参数状态
:cmd_pt
set tm=
for %%a in (!%1!) do (
	set tm=%%a
	if /i "!tm:~,2!" == "%2" (set %3=True)
)
goto :eof


:cmd_pt_state
set tm=
set %3=
for %%a in (!%1!) do (
	set tm=%%a
	if /i "!tm:~,3!" == "%2" (set %3=!tm:~3!)
)
goto :eof


::计算耗时 (call :outtime "2015-09-09 12:12:12.06" "%date% %time%")
:outtime
for /f "tokens=1,2,3,4,5,6,7 delims=-/:. " %%i in ("%1") do ((set Y1=%%i) && (set M1=%%j) && (set D1=%%k) && (set H1=%%l) && (set F1=%%m) && (set S1=%%n) && (set MS1=%%o))
for /f "tokens=1,2,3,4,5,6,7 delims=-/:. " %%i in ("%2") do ((set Y2=%%i) && (set M2=%%j) && (set D2=%%k) && (set H2=%%l) && (set F2=%%m) && (set S2=%%n) && (set MS2=%%o))
set /a secs=((d2-32075+1461*(y2+4800+(m2-14)/12)/4+367*(m2-2-(m2-14)/12*12)/12-3*((y2+4900+(m2-14)/12)/100)/4)*86400+H2*3600+F2*60+S2)-((d1-32075+1461*(y1+4800+(m1-14)/12)/4+367*(m1-2-(m1-14)/12*12)/12-3*((y1+4900+(m1-14)/12)/100)/4)*86400+H1*3600+F1*60+S1)
set /a D=secs/86400,H=(secs%%86400)/3600,M=(secs%%3600)/60,S=secs%%60
::echo.%1与%2之间相隔:%D%天%H%时%M%分%S%秒
goto :eof
