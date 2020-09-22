::code by nameyu8023 cmd@xp
@echo off
setlocal enabledelayedexpansion
title 内网在线计算机信息获取*[%date:~,10%%time:~,5%]
color df
::------------------------
::开始特效
set memutx=1
:re
echo Hello!
set /a memutx+=1
mode con: cols=57 lines=%memutx%
cls
if %memutx% lss 30 goto re
::-------------------------
set xian=--------------------------------------------------------
set "cue_1= IP地址有误。"
set "cue_2= IP段输入有误。"
set file_name=在线计算机信息.log
::参数设置---------------------
::应对不同系统IP关键字不同。
set kw_ip=ip
ver|findstr /i "6.">nul||set kw_ip=IPv4
::关键字,用于判断是否PING通,考虑到有些系统的PING结果，故保留此项.(关键字区分大小写)
set kw_ping=TTL
::精准度,既PING的次数。
set precise=2
::是否进行延时，既PNG与下一个 PING之间是否延时。只有此项生效，下一项才生效。(0延时1不延时)
::延时会减少CPU使用率，相应时间会增加。反之则时间减少，CPU使用率增加。建议延时
set delayed=0
::距离下一个PING的等待时间。
set speed=1
::-----------------------------
:memu
for /l %%a in (1,1,5) do echo\
echo              获取局域网内在线计算机的信息
echo.
echo                 [IP][MAC][NetBios名]
echo.
echo                   X.返回上一层
echo.
echo                   Q.退出
echo.         
echo           注:自动获取IP有些计算机可能会出错。
for /l %%a in (1,1,3) do echo\
pushd %temp%
>"网段IP是？  [默认：自动获取本机IP]" echo.
findstr /a:0c .* "网段IP是？  [默认：自动获取本机IP]*"
set lan_ip=
set gain_1=1
set gain_2=1
set /p lan_ip=
if "%lan_ip%"=="" echo 正在获取...&call :gain_ip
if %gain_1% equ 0 (
	if %gain_2% equ 0 (
		set lan_ip=%seif_ip%
		call :error_ 3 已获取！ 本机IP：[!lan_ip!]

		) else (
		cls
		call :error_ "自动获取IP失败!" %xian%
		goto memu
	)
)
del "网段IP是？  [默认：自动获取本机IP]" >nul 2>nul
if /i "%lan_ip%"=="x" cls&goto memu
if /i "%lan_ip%"=="q" goto quit
::提取网段
for /f "delims=. tokens=1-3*" %%i in ("%lan_ip%") do (
	set lan_ip_node_1=%%i
	set lan_ip_node_2=%%j
	set lan_ip_node_3=%%k
	set lan_ip_node_4=%%l
	set lan_ip_node=%%i.%%j.%%k
)
::检测ip输入是否有误
call :test_254 %lan_ip_node_1%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip%]%cue_1%" %xian%&goto memu
call :test_254 %lan_ip_node_2%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip%]%cue_1%" %xian%&goto memu
call :test_254 %lan_ip_node_3%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip%]%cue_1%" %xian%&goto memu
call :test_254 %lan_ip_node_4%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip%]%cue_1%" %xian%&goto memu
>"IP段是？  以空格隔开。 [默认：1 254]" echo.
findstr /a:0c .* "IP段是？  以空格隔开。 [默认：1 254]*"
set lan_ip_part=1 254
set /p lan_ip_part=
del "IP段是？  以空格隔开。 [默认：1 254]"
if /i "%lan_ip_part%"=="x" cls&goto memu
if /i "%lan_ip_part%"=="q" goto quit
popd
::提取IP段
for /f "tokens=1,2" %%i in ("%lan_ip_part%") do (
	set lan_ip_part_1=%%i
	set lan_ip_part_2=%%j
)
::检测ip段输入是否有误
call :test_254 %lan_ip_part_1%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip_part%]%cue_2%" %xian%&goto memu
call :test_254 %lan_ip_part_2%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip_part%]%cue_2%" %xian%&goto memu
::判断起始是否大于结尾
if %lan_ip_part_1% gtr %lan_ip_part_2% cls&call :error_ 10 "[%lan_ip_part%]%cue_2%" %xian%&goto memu
::获取IP段步长
set /a lan_ip_part=%lan_ip_part_2%-%lan_ip_part_1%
cls
echo 处理的网段IP:[%lan_ip%]
echo 处理的IP段:[%lan_ip_part_1%-%lan_ip_part_2%]
echo 正在处理测试信息...
::建立临时文件夹
if not exist %temp%\lan_ip_test\ md %temp%\lan_ip_test\
::设置IP段,测试IP
arp /d 2>nul
for /l %%a in (%lan_ip_part_1%,1,%lan_ip_part_2%) do (
	(
	echo @echo off
	echo title 内网在线计算机信息获取*[%date:~,10%%time:~,5%] 测试中...	
	echo ping /a /n %precise% %lan_ip_node%.%%a ^>%temp%\lan_ip_test\lan_ip_test_%%a.log
	echo exit
	)>%temp%\lan_ip_test\lan_ip_test_%%a.bat
start /b %temp%\lan_ip_test\lan_ip_test_%%a.bat
::判断是否启用延时
if %delayed% equ 0 call :vfx %speed% 扫描IP:%%a
)
::延时
set /a delay=%precise%*1
title 内网在线计算机信息获取*[%date:~,10%%time:~,5%] 等待中...
for /l %%a in (1,1,%delay%) do call :vfx 2 等待扫描完成
::将ARP信息导入文本
arp /a >"%temp%\lan_ip_test\lan_ip_test_arp.log"
cls
::收集测试信息并打印和导入文本
set lan_ip_test_num=0
title 内网在线计算机信息获取*[%date:~,10%%time:~,5%] 打印中...
echo 正在打印信息...
call :gain_ip
call :gain_mac
echo     IP地址          MAC地址             NetBios名
echo %xian%
set /a lan_ip_part_1-=1
::设置在线IP变量
set lan_ip_test_num=0
:gather
set /a lan_ip_part_1+=1
::清空IP变量
set str=
::清空MAC变量
set str_1=
::查找PING通的,临时文本。
for /f "delims=" %%a in ('findstr "%kw_ping%" "%temp%\lan_ip_test\lan_ip_test_%lan_ip_part_1%.log"') do (
	if not "%%a"=="" (
		::提取NetBios名
		for /f "delims=[" %%b in ('findstr "[" "%temp%\lan_ip_test\lan_ip_test_%lan_ip_part_1%.log"') do (
			set str=%%b
			set str=!str: =!
			::XP关键字替换
			set str=!str:pinging=!
			::Win7关键字替换
			set str=!str:正在Ping=!
			)
		::提取MAC
		for /f "tokens=2" %%z in ('findstr "%lan_ip_node%.%lan_ip_part_1%" "%temp%\lan_ip_test\lan_ip_test_arp.log"') do (
			set str_1=%%z
			set str_1=!str_1: =!
		)
		goto next
	)
)

if %lan_ip_part_1% equ %lan_ip_part_2% goto complete
goto gather
::在线IP收集
:next
::判断是否存在NetBios名
if not defined str set str=----------无----------
::判断是否为本机IP
if [%lan_ip_node%.%lan_ip_part_1%]==[%seif_ip%] (
	set str_1=%mac%
	) else (
	::判断是否存在MAC地址
	if not defined str_1 (
		set str_1=-------无--------
	)
)
if not exist %file_name% (
	echo     IP地址          MAC地址             NetBios名>%file_name%
)
::打印排版。
if %lan_ip_part_1% lss 100 set "lan_ip_part_1=%lan_ip_part_1% "
if %lan_ip_part_1% lss 10 set "lan_ip_part_1=%lan_ip_part_1% "
::打印
echo %lan_ip_node%.%lan_ip_part_1%  !str_1!  !str!
echo %lan_ip_node%.%lan_ip_part_1%  !str_1!  !str!>>%file_name%
set /a lan_ip_test_num+=1
if %lan_ip_part_1% equ %lan_ip_part_2% goto complete
goto gather

:complete
title 内网在线计算机信息获取*[%date:~,10%%time:~,5%] 已完成...
if %lan_ip_test_num% equ 0 echo 无在线计算机。
echo %xian%
echo 正在做最后处理...
set /a lan_ip_part_1=%lan_ip_part_2%-%lan_ip_part%
::导入文本
if exist %file_name% (
	echo 处理的网段IP:[%lan_ip%]>>%file_name%
	echo 处理的IP段:[%lan_ip_part_1%-%lan_ip_part_2%]内,共有%lan_ip_test_num%条IP在线.>>%file_name%
	echo %date:~,10% %time:~,5%>>%file_name%
	echo %xian%>>%file_name%
	start "" %file_name%
)
echo 处理的网段IP:[%lan_ip%]
echo 处理的IP段:[%lan_ip_part_1%-%lan_ip_part_2%]内,共有%lan_ip_test_num%条IP在线.
echo 全部处理完毕,按任意键退出。
call :error_ 5
pause>nul
::删除临时文件
rd /q /s %temp%\lan_ip_test >nul 2>nul
::退出特效
:quit
set memutx1=20
:re1
cls
echo Good-Bye!
set /a memutx1-=1
mode con: cols=45 lines=%memutx1%
if %memutx1% NEQ 1 goto re1
exit

::测试是否为0-254之内的数字
:test_254
set bl=1
for /l %%a in (0,1,254) do (
	if [%1]==[%%a] (
		set bl=0
	)
)
goto :eof
::获取本机IP
::获取最后一个IP
:gain_ip

for /f "delims=[,] tokens=1-2" %%a in  ('nbtstat -a ip ^|findstr /i "["') do (
	set seif_ip=%%b
	if not "!seif_ip!"=="" goto next
)
:next
set gain_1=0
set gain_2=1
if not "%seif_ip%"=="" set gain_2=0
goto :eof
::获取本机mac
::获取最后一个12位MAC
:gain_mac

for /f "delims== tokens=1-2" %%a in ('nbtstat -a %seif_ip% ^|findstr /i "="') do (
	set mac=%%b
	set mac=!mac: =!

)
goto :eof
::闪烁
:error_
for /l %%a in (1,1,%1) do (
	color 4d
	ping /n 1 127.1>nul
	color df
	ping /n 1 127.1>nul
)
echo.%2
echo.%3
goto :eof
::延时特效
:vfx
for %%a in (▂  ▅  ▇  █) do (
	for /l %%a in (1,1,8) do set /p=·<nul
	set /p=%%a [%2]<nul
	ping /n %1 127.1>nul
	for /l %%b in (1,1,20) do set /p=<nul
)
goto :eof

