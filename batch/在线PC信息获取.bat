::code by nameyu8023 cmd@xp
@echo off
setlocal enabledelayedexpansion
title �������߼������Ϣ��ȡ*[%date:~,10%%time:~,5%]
color df
::------------------------
::��ʼ��Ч
set memutx=1
:re
echo Hello!
set /a memutx+=1
mode con: cols=57 lines=%memutx%
cls
if %memutx% lss 30 goto re
::-------------------------
set xian=--------------------------------------------------------
set "cue_1= IP��ַ����"
set "cue_2= IP����������"
set file_name=���߼������Ϣ.log
::��������---------------------
::Ӧ�Բ�ͬϵͳIP�ؼ��ֲ�ͬ��
set kw_ip=ip
ver|findstr /i "6.">nul||set kw_ip=IPv4
::�ؼ���,�����ж��Ƿ�PINGͨ,���ǵ���Щϵͳ��PING������ʱ�������.(�ؼ������ִ�Сд)
set kw_ping=TTL
::��׼��,��PING�Ĵ�����
set precise=2
::�Ƿ������ʱ����PNG����һ�� PING֮���Ƿ���ʱ��ֻ�д�����Ч����һ�����Ч��(0��ʱ1����ʱ)
::��ʱ�����CPUʹ���ʣ���Ӧʱ������ӡ���֮��ʱ����٣�CPUʹ�������ӡ�������ʱ
set delayed=0
::������һ��PING�ĵȴ�ʱ�䡣
set speed=1
::-----------------------------
:memu
for /l %%a in (1,1,5) do echo\
echo              ��ȡ�����������߼��������Ϣ
echo.
echo                 [IP][MAC][NetBios��]
echo.
echo                   X.������һ��
echo.
echo                   Q.�˳�
echo.         
echo           ע:�Զ���ȡIP��Щ��������ܻ����
for /l %%a in (1,1,3) do echo\
pushd %temp%
>"����IP�ǣ�  [Ĭ�ϣ��Զ���ȡ����IP]" echo.
findstr /a:0c .* "����IP�ǣ�  [Ĭ�ϣ��Զ���ȡ����IP]*"
set lan_ip=
set gain_1=1
set gain_2=1
set /p lan_ip=
if "%lan_ip%"=="" echo ���ڻ�ȡ...&call :gain_ip
if %gain_1% equ 0 (
	if %gain_2% equ 0 (
		set lan_ip=%seif_ip%
		call :error_ 3 �ѻ�ȡ�� ����IP��[!lan_ip!]

		) else (
		cls
		call :error_ "�Զ���ȡIPʧ��!" %xian%
		goto memu
	)
)
del "����IP�ǣ�  [Ĭ�ϣ��Զ���ȡ����IP]" >nul 2>nul
if /i "%lan_ip%"=="x" cls&goto memu
if /i "%lan_ip%"=="q" goto quit
::��ȡ����
for /f "delims=. tokens=1-3*" %%i in ("%lan_ip%") do (
	set lan_ip_node_1=%%i
	set lan_ip_node_2=%%j
	set lan_ip_node_3=%%k
	set lan_ip_node_4=%%l
	set lan_ip_node=%%i.%%j.%%k
)
::���ip�����Ƿ�����
call :test_254 %lan_ip_node_1%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip%]%cue_1%" %xian%&goto memu
call :test_254 %lan_ip_node_2%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip%]%cue_1%" %xian%&goto memu
call :test_254 %lan_ip_node_3%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip%]%cue_1%" %xian%&goto memu
call :test_254 %lan_ip_node_4%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip%]%cue_1%" %xian%&goto memu
>"IP���ǣ�  �Կո������ [Ĭ�ϣ�1 254]" echo.
findstr /a:0c .* "IP���ǣ�  �Կո������ [Ĭ�ϣ�1 254]*"
set lan_ip_part=1 254
set /p lan_ip_part=
del "IP���ǣ�  �Կո������ [Ĭ�ϣ�1 254]"
if /i "%lan_ip_part%"=="x" cls&goto memu
if /i "%lan_ip_part%"=="q" goto quit
popd
::��ȡIP��
for /f "tokens=1,2" %%i in ("%lan_ip_part%") do (
	set lan_ip_part_1=%%i
	set lan_ip_part_2=%%j
)
::���ip�������Ƿ�����
call :test_254 %lan_ip_part_1%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip_part%]%cue_2%" %xian%&goto memu
call :test_254 %lan_ip_part_2%
if not [%bl%]==[0] cls&call :error_ 10 "[%lan_ip_part%]%cue_2%" %xian%&goto memu
::�ж���ʼ�Ƿ���ڽ�β
if %lan_ip_part_1% gtr %lan_ip_part_2% cls&call :error_ 10 "[%lan_ip_part%]%cue_2%" %xian%&goto memu
::��ȡIP�β���
set /a lan_ip_part=%lan_ip_part_2%-%lan_ip_part_1%
cls
echo ���������IP:[%lan_ip%]
echo �����IP��:[%lan_ip_part_1%-%lan_ip_part_2%]
echo ���ڴ��������Ϣ...
::������ʱ�ļ���
if not exist %temp%\lan_ip_test\ md %temp%\lan_ip_test\
::����IP��,����IP
arp /d 2>nul
for /l %%a in (%lan_ip_part_1%,1,%lan_ip_part_2%) do (
	(
	echo @echo off
	echo title �������߼������Ϣ��ȡ*[%date:~,10%%time:~,5%] ������...	
	echo ping /a /n %precise% %lan_ip_node%.%%a ^>%temp%\lan_ip_test\lan_ip_test_%%a.log
	echo exit
	)>%temp%\lan_ip_test\lan_ip_test_%%a.bat
start /b %temp%\lan_ip_test\lan_ip_test_%%a.bat
::�ж��Ƿ�������ʱ
if %delayed% equ 0 call :vfx %speed% ɨ��IP:%%a
)
::��ʱ
set /a delay=%precise%*1
title �������߼������Ϣ��ȡ*[%date:~,10%%time:~,5%] �ȴ���...
for /l %%a in (1,1,%delay%) do call :vfx 2 �ȴ�ɨ�����
::��ARP��Ϣ�����ı�
arp /a >"%temp%\lan_ip_test\lan_ip_test_arp.log"
cls
::�ռ�������Ϣ����ӡ�͵����ı�
set lan_ip_test_num=0
title �������߼������Ϣ��ȡ*[%date:~,10%%time:~,5%] ��ӡ��...
echo ���ڴ�ӡ��Ϣ...
call :gain_ip
call :gain_mac
echo     IP��ַ          MAC��ַ             NetBios��
echo %xian%
set /a lan_ip_part_1-=1
::��������IP����
set lan_ip_test_num=0
:gather
set /a lan_ip_part_1+=1
::���IP����
set str=
::���MAC����
set str_1=
::����PINGͨ��,��ʱ�ı���
for /f "delims=" %%a in ('findstr "%kw_ping%" "%temp%\lan_ip_test\lan_ip_test_%lan_ip_part_1%.log"') do (
	if not "%%a"=="" (
		::��ȡNetBios��
		for /f "delims=[" %%b in ('findstr "[" "%temp%\lan_ip_test\lan_ip_test_%lan_ip_part_1%.log"') do (
			set str=%%b
			set str=!str: =!
			::XP�ؼ����滻
			set str=!str:pinging=!
			::Win7�ؼ����滻
			set str=!str:����Ping=!
			)
		::��ȡMAC
		for /f "tokens=2" %%z in ('findstr "%lan_ip_node%.%lan_ip_part_1%" "%temp%\lan_ip_test\lan_ip_test_arp.log"') do (
			set str_1=%%z
			set str_1=!str_1: =!
		)
		goto next
	)
)

if %lan_ip_part_1% equ %lan_ip_part_2% goto complete
goto gather
::����IP�ռ�
:next
::�ж��Ƿ����NetBios��
if not defined str set str=----------��----------
::�ж��Ƿ�Ϊ����IP
if [%lan_ip_node%.%lan_ip_part_1%]==[%seif_ip%] (
	set str_1=%mac%
	) else (
	::�ж��Ƿ����MAC��ַ
	if not defined str_1 (
		set str_1=-------��--------
	)
)
if not exist %file_name% (
	echo     IP��ַ          MAC��ַ             NetBios��>%file_name%
)
::��ӡ�Ű档
if %lan_ip_part_1% lss 100 set "lan_ip_part_1=%lan_ip_part_1% "
if %lan_ip_part_1% lss 10 set "lan_ip_part_1=%lan_ip_part_1% "
::��ӡ
echo %lan_ip_node%.%lan_ip_part_1%  !str_1!  !str!
echo %lan_ip_node%.%lan_ip_part_1%  !str_1!  !str!>>%file_name%
set /a lan_ip_test_num+=1
if %lan_ip_part_1% equ %lan_ip_part_2% goto complete
goto gather

:complete
title �������߼������Ϣ��ȡ*[%date:~,10%%time:~,5%] �����...
if %lan_ip_test_num% equ 0 echo �����߼������
echo %xian%
echo �����������...
set /a lan_ip_part_1=%lan_ip_part_2%-%lan_ip_part%
::�����ı�
if exist %file_name% (
	echo ���������IP:[%lan_ip%]>>%file_name%
	echo �����IP��:[%lan_ip_part_1%-%lan_ip_part_2%]��,����%lan_ip_test_num%��IP����.>>%file_name%
	echo %date:~,10% %time:~,5%>>%file_name%
	echo %xian%>>%file_name%
	start "" %file_name%
)
echo ���������IP:[%lan_ip%]
echo �����IP��:[%lan_ip_part_1%-%lan_ip_part_2%]��,����%lan_ip_test_num%��IP����.
echo ȫ���������,��������˳���
call :error_ 5
pause>nul
::ɾ����ʱ�ļ�
rd /q /s %temp%\lan_ip_test >nul 2>nul
::�˳���Ч
:quit
set memutx1=20
:re1
cls
echo Good-Bye!
set /a memutx1-=1
mode con: cols=45 lines=%memutx1%
if %memutx1% NEQ 1 goto re1
exit

::�����Ƿ�Ϊ0-254֮�ڵ�����
:test_254
set bl=1
for /l %%a in (0,1,254) do (
	if [%1]==[%%a] (
		set bl=0
	)
)
goto :eof
::��ȡ����IP
::��ȡ���һ��IP
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
::��ȡ����mac
::��ȡ���һ��12λMAC
:gain_mac

for /f "delims== tokens=1-2" %%a in ('nbtstat -a %seif_ip% ^|findstr /i "="') do (
	set mac=%%b
	set mac=!mac: =!

)
goto :eof
::��˸
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
::��ʱ��Ч
:vfx
for %%a in (�y  �|  �~  ��) do (
	for /l %%a in (1,1,8) do set /p=��<nul
	set /p=%%a [%2]<nul
	ping /n %1 127.1>nul
	for /l %%b in (1,1,20) do set /p=<nul
)
goto :eof

