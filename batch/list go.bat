::code by ngrian win10@cmd. 201701227
@echo off
setlocal enabledelayedexpansion

::------------user var-----------------

::00201712270001 
::0020171227=ǰ׺�� 000=����ַ��� 1~n=���ɵ����У� 1=��ʼ �� n=��ֹ��

::ǰ׺
set prefi=0020171227

::����ַ�
set fill=0

::��ʼ
set beg=1

::����
set jump=1

::��ֹ
set end=3000000000

::------------user var-----------------
title list ^&go %beg% ~ %end%

set tmptime=%date% %time%

call :numlen %end%
set end_len=!numlen!
::��������
echo ��������...
(for /l %%a in (%beg%,%jump%,%end%) do (
	call :format %%a %end_len% %fill%  
	echo !prefi!!strtmp!
	title list ^&go %%a ~ %end%
))>%temp%\list.txt
call :outtime "%tmptime%" "%date% %time%"
echo ��ʱ:%D%��%H%ʱ%M%��%S%��
if exist %temp%\list.txt start "" %temp%\list.txt
echo end...
pause&exit

::��ʽ������ %1 = end ,%2 = end , %3=fill, ret = strtmp
:format
set _p=
set _num_1=%~1
set _num_2_len=%2

call :numlen !_num_1!
set _num_1_len=!numlen!
set /a _num_len=!_num_2_len!-!_num_1_len!

for /l %%a in (1,1,!_num_len!) do set _p=%3!_p!
set strtmp=!_p!%~1
goto :eof

::���㳤�� pat=str,ret=numlen
:numlen
if %1 lss 10 set numlen=1&&goto :eof
if %1 lss 100 set numlen=2&&goto :eof
if %1 lss 1000 set numlen=3&&goto :eof
if %1 lss 10000 set numlen=4&&goto :eof
if %1 lss 100000 set numlen=5&&goto :eof
if %1 lss 1000000 set numlen=6&&goto :eof
set numlen=9
goto :eof





::�����ʱ (call :outtime "2015-09-09 12:12:12.06" "%date% %time%")
:outtime
for /f "tokens=1,2,3,4,5,6,7 delims=-/:. " %%i in ("%1") do ((set Y1=%%i) && (set M1=%%j) && (set D1=%%k) && (set H1=%%l) && (set F1=%%m) && (set S1=%%n) && (set MS1=%%o))
for /f "tokens=1,2,3,4,5,6,7 delims=-/:. " %%i in ("%2") do ((set Y2=%%i) && (set M2=%%j) && (set D2=%%k) && (set H2=%%l) && (set F2=%%m) && (set S2=%%n) && (set MS2=%%o))
set /a secs=((d2-32075+1461*(y2+4800+(m2-14)/12)/4+367*(m2-2-(m2-14)/12*12)/12-3*((y2+4900+(m2-14)/12)/100)/4)*86400+H2*3600+F2*60+S2)-((d1-32075+1461*(y1+4800+(m1-14)/12)/4+367*(m1-2-(m1-14)/12*12)/12-3*((y1+4900+(m1-14)/12)/100)/4)*86400+H1*3600+F1*60+S1)
set /a D=secs/86400,H=(secs%%86400)/3600,M=(secs%%3600)/60,S=secs%%60
::echo.%1��%2֮�����:%D%��%H%ʱ%M%��%S%��
goto :eof


