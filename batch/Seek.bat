::code by nameyu8023 cmd@Win10  201611191106
@echo off
:Main
setlocal enabledelayedexpansion

::-----------------User var-----------------
::�����ļ���������
set include=.txt .ini .inf .bat .cmd .log .xml
::�����̷�
set vol=D E F G H I J K L M N O P Q R S T U V W X Y Z
::-----------------User var-----------------



::-----------------Begin code-----------------
::���������ļ�,״̬:False . True
set Include_state=False
::������ʱ������
set logname=%date:~,10%%time:~,8%
set logname=%logname:/=%
set logname=%logname:-=%
set logname=%logname: =%
set logname=%temp%\Search_%logname::=%.log


::��Ĭ ����
set Silence=False

::���� ����
set cmd_Bl=False

::��Ĭ ״̬
set Silence_state=
if  "%Silence%"=="True" set Silence_state=^>nul

::�жϴ����̷�
set search_vol=
for %%a in (%vol%) do (
	if exist %%a: (
		set "search_vol=!search_vol! %%a:"
	)
)

::�жϲ���״̬ 1=�ļ�  2=�ļ��� 3=�� 4=�ַ���
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

::���ò���״̬
if "%Pt_state%" == "1" (echo ----ϵͳ��ʾ:[%~1]����һ����Ч��Ŀ¼.&echo\)
if "%Pt_state%" == "2" (set search_vol="%~1")
if "%Pt_state%" == "4" set cmd_Bl=True

::�ж��Ƿ�Ϊ������
if "%cmd_Bl%" == "True" (
	::�ж��Ƿ�Ϊ��������
	if '%1'=='/?' (
		::���ð���ģ��
		call :cmd_help
		exit /b	
	) else (
	::�趨����
	set cmd_parameter=%1 %2 %3 %4 %5 %6 %7 %8 %9
	)
)

if "%cmd_Bl%" == "False" (
	title File Search tool
	color 6f
)
::�ж������в��� /k:=�ؼ��� /p:=Ŀ¼ /q=��Ĭ /i=����
if "%cmd_Bl%"=="True" (
	for %%a in (k p q i) do (
		set cmd_%%a=False
		call :cmd_pt cmd_parameter /%%a cmd_%%a
	)
)


::�ж� /k ����״̬
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


::�ж� /p ����״̬

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

::echo ����״̬=%Pt_state% ��־����=%logname% �̷�=%search_vol% �Ƿ�����=%cmd_Bl% �ж������в���k p q i=%cmd_k% %cmd_p% %cmd_q% %cmd_i% k����=%cmd_k_pt% k�ַ�=%cmd_k_str% p����=%cmd_p_pt% p�ַ�=%cmd_p_str%





::��ȡ��������
set Search_include=
for %%a in (%include%) do (
	set "Search_include=*%%a !Search_include!"
)
::��ʾ
:userinput
if not "%cmd_Bl%"=="True" (
	call :ui_help
	echo\
	echo ɨ��·��: [%search_vol%] .
	echo ��������: [%include%]
)

::�û�����
if not "%cmd_Bl%"=="True" (
	set /p search_keyword=������ؼ���:
	set search_i=!search_keyword:~-2!
	if "!search_i!" == "//" (
		set search_keyword=!search_keyword:~,-2!
		set Include_state=True
	)
)

::�ж��Ƿ�����Ϊ��
if [!search_keyword!] == [] cls&echo ���벻��Ϊ��.&goto userinput

::�����û�����
for /f "tokens=1*" %%a in ("!search_keyword!") do set search_keyword=%%a
set tmptime=%date% %time%
::������Ϣ
(
echo ɨ��·��:	[%search_vol%] .
echo ��������:	[%include%]
echo �Ƿ�����:	[!Include_state!]
echo ɨ��ؼ���:	[%search_keyword%]
echo ��ʼʱ��:	[%tmptime%]

echo -----------------------------------
echo\
)>%logname%



::׼������
set search_condition=
for %%a in (%search_vol%) do (
	
	::���������ؼ���
	set "search_condition=*%search_keyword%*"
	
	::��������ģ��
	Call :Error "Keyword:[!search_keyword!],Searched [%%a]..." 
	Call :SearchFile search_condition %%a
	::�ж��Ƿ����������ļ�
	if "%Include_state%"=="True" (
		::���������ؼ���
		set "search_condition=!Search_include!"
		::��������ģ��
		Call :Error "Include Keyword:[!search_keyword!] file."
		call :SearchFile search_condition %%a %search_keyword%		
	)
)
call :outtime "%tmptime%" "%date% %time%"
::�������ģʽ
if not "%cmd_Bl%"=="True" (
	
	::��׼���
	echo Cmd=Close >>%logname%
	echo ��ʱ:%D%��%H%ʱ%M%��%S%�� >>%logname%
	echo ��ʱ:%D%��%H%ʱ%M%��%S%��
	echo ----------end-------------
	echo\
	echo �����,�����������־.
	pause>nul
	start "" %logname%
	exit
	) else (
	
	::��Ĭ���
	echo Cmd=Open >>%logname%
	echo CmdParameter=%cmd_parameter% >>%logname%
	echo Time Consuming:%D%Day %H%Hour %M%Minute %S%Second >>%logname%
	echo\
	echo Complete to export to:
	echo [%logname%]
	echo Time Consuming:%D%Day %H%Hour %M%Minute %S%Second
	exit /b
) 



::����ģ��
:SearchFile

::���ݲ���  %1=�ؼ��� %2=Ŀ¼ %3=�����ؼ���
pushd %2
(

::�����ļ����ļ���
for /f "delims=" %%z in ('dir /b/s !%1! 2^>nul') do (
	
	::�ж�ɨ������
	if "%3" == "%search_keyword%" (

		::���������ļ�
		for /f "delims=: tokens=3" %%a in ('find /i /c "%3" "%%z" 2^>nul') do (
			set Include_tmp=%%a

			::�ж��Ƿ������ؼ���
			if not "!Include_tmp: =!" == "0" (

				::�������
				echo %%z n:!Include_tmp: =!
				(echo %%z n:!Include_tmp: =!)>>%logname%
				)
			)
		) else (
	
		::��׼���
		echo %%z
		(echo %%z)>>%logname%
	)
)
)%Silence_state%
popd
goto :eof

::����ģ��
:Error
(
echo ----------System prompt:%1
echo ----------System prompt:%1>>%logname%
)%Silence_state%
goto :eof

::�����а���
:cmd_help
echo ���������ؼ��ֵ��ļ����ļ��С�
echo\
echo %~n0 [/K:] [/P:] [/Q]  [/I]
echo\
echo   /K:	��ʾ�������ַ���·����
echo   /P:	ָ��һ��Ŀ¼,ֻ�ڴ�Ŀ¼������;����ѡ��,��Ĭ��ȫ��������
echo   /Q	��Ĭִ��,����ʾ�����
echo   /I	���������ַ������ļ���
echo\
echo /K:string ��ѡ���Ǳ����,��ֻ����һ����
echo /P:"c:\test 1" ��·���а����ո�,Ӧ�������Ű�����
goto :eof



::�������
:ui_help
echo ���������ؼ��ֵ��ļ����ļ��С�
echo\
echo ֱ������һ��Ŀ¼�����ļ���,����Ĭ�Ͻ���ȫ��������
echo\
echo    �˹��߻�����ѡ��Ŀ¼��,�������������ַ�����·����
echo    �����������ַ����Ľ�β�� "//", ���ͬʱ�г����ݰ����ؼ��ֵ��ļ���
echo\
echo ���������ַ���ֻ����һ��,�Ҳ����������ġ�
goto :eof

::��ȡ������� %1=���� %2=ȷ�Ϲؼ��� %3=���ձ���

::�жϴ��ݲ���״̬
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


::�����ʱ (call :outtime "2015-09-09 12:12:12.06" "%date% %time%")
:outtime
for /f "tokens=1,2,3,4,5,6,7 delims=-/:. " %%i in ("%1") do ((set Y1=%%i) && (set M1=%%j) && (set D1=%%k) && (set H1=%%l) && (set F1=%%m) && (set S1=%%n) && (set MS1=%%o))
for /f "tokens=1,2,3,4,5,6,7 delims=-/:. " %%i in ("%2") do ((set Y2=%%i) && (set M2=%%j) && (set D2=%%k) && (set H2=%%l) && (set F2=%%m) && (set S2=%%n) && (set MS2=%%o))
set /a secs=((d2-32075+1461*(y2+4800+(m2-14)/12)/4+367*(m2-2-(m2-14)/12*12)/12-3*((y2+4900+(m2-14)/12)/100)/4)*86400+H2*3600+F2*60+S2)-((d1-32075+1461*(y1+4800+(m1-14)/12)/4+367*(m1-2-(m1-14)/12*12)/12-3*((y1+4900+(m1-14)/12)/100)/4)*86400+H1*3600+F1*60+S1)
set /a D=secs/86400,H=(secs%%86400)/3600,M=(secs%%3600)/60,S=secs%%60
::echo.%1��%2֮�����:%D%��%H%ʱ%M%��%S%��
goto :eof
