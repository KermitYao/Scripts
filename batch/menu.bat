::code by nameyu8023 cmd@Win8
@echo off
setlocal enabledelayedexpansion
mode con: cols=77 lines=23
color 6f
set gm_Btxs=shortcut menu
set gm_Xian#1=-----------------------------------------------------------------------------
set gm_Xian#2=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::ÿ����ʾ���ٸ���Ŀ
set gm_Cdlb=4
::��ʼ����
set gm_Bt=code by nameyu8023 cmd@Win8
::�����ļ�·��
set gm_Pzlj=D:\gm_Pzwj.inf
::����Ŀ��˵��Ƿ��˳�
set gm_Tc=Y
::������֤
set gm_Mmyz=N
::��ʼ����
set gm_Csmm=802359
::_____________________________________
::������Ч
title %gm_Btxs%
call :gm_CkfdX 16 3 77
call :gm_CkfdY 3  77 23
echo ���ڶ�ȡ...
::����UAC
set UAC_file=gm_Pzlj
(echo "%gm_Btxs%" >"%UAC_file%")>nul 2>nul
if exist "%UAC_file%" (
	set gm_Uac=Y
	del "%UAC_file%"
	) else (
	set gm_Uac=N
)

::������֤
for /l %%a in (0,1,9) do (
	set gm_Usermm=!gm_Usermm!%%a
)
if exist "%gm_Pzlj%" (
	call :gm_Hqlj
	cls
	call :gm_Khfq 2
	if not defined gm_Userpw (
		echo �����⵽�ƻ�!
		pause>nul
		exit
	)
	if not [!gm_Csmm!]==!gm_Userpw! (
		set gm_Mmyz=Y
		echo                          �˲˵������뱣��!
		call :gm_Khfq 5
		set /p gm_Userip=������֤,����������!:
		if [!gm_Userip!]==!gm_Userpw! goto gm_Zcd
		echo                             �������
		ping /n 3 127.1>nul
		exit
	)
)

::�˵���ʾ
:gm_Zcd
set ljnum=0
if exist "%gm_Pzlj%" call :gm_Hqlj
set /a gm_Ckhs=ljnum/gm_Cdlb*3+25
call :gm_CkfdY 23  77 %gm_Ckhs%
echo\
echo    %gm_Bt%
echo %gm_Xian#1%
echo    ���˵�
call :gm_Khfq 3

call :gm_Xscd !ljnum!
echo\
echo %gm_Xian#2%
echo\
echo                       P.�˵��������Ŀɾ������.
echo\
echo       ��[%ljnum%]����Ŀ.
echo\
pushd %temp%
>"����Ҫ��ʲô��[ֱ�������ļ�,�������Ŀ]" echo.
findstr /a:0c .* "����Ҫ��ʲô��[ֱ�������ļ�,�������Ŀ]*"
del "����Ҫ��ʲô��[ֱ�������ļ�,�������Ŀ]" >nul 2>nul
set userip_Dk=
for /l %%a in (1,1,%ljnum%) do (
	if "%1"=="%%a" (
		set userip_Dk=%1
	) else (
		echo !gm_Mz#%%a!|find /i "%1">nul&&set userip_Dk=%%a
	)
)
if "[%userip_Dk%]"=="[]" set /p userip_Dk=

if "[%userip_Dk%]"=="[]" exit

if /i "[%userip_Dk%]"=="[P]" (
	if "%gm_Uac%"=="N" (
		set gm_Bt=��Щ������Ҫ����ԱȨ��,���Ҽ��Թ���Ա������У�
		goto gm_Zcd
	)
	goto gm_Pwxm
)

call :gm_Qcyh %userip_Dk% userip_Dk
if exist "%userip_Dk%" goto gm_Tjxm
for /l %%a in (1,1,%ljnum%) do (
	if not exist !gm_Lj#%userip_Dk%! (
		cls
		set gm_Bt=����,���ٴ�ѡ��!
		echo !gm_Xian#1!
		goto gm_Zcd
	) else (
		start "" !gm_Lj#%userip_Dk%!
		if [%gm_Tc%]==[Y] (
			set /p=    ������... <nul 
			for %%b in (3 2 1) do (
				set /p=%%b  <nul
				ping /n 2 127.1>nul
			)
				exit
		) else (
		cls
		set gm_Bt=���,��Ŀ[!gm_Mz#%userip_Dk%!]�Ѵ�!
		echo !gm_Xian#1!
		goto gm_Zcd
		)

	)
)



::��ȡ��Ŀ·��������
:gm_Hqlj
set ljnum=0
for /f "skip=1 delims=; tokens=1,*" %%a in ('type "%gm_Pzlj%"') do (
	if exist "%%a" (
		set /a ljnum+=1
		set gm_Lj#!ljnum!=%%a
		set gm_Mz#!ljnum!=%%b
	)
)
for /f "delims=" %%a in ('type "%gm_Pzlj%"^|findstr /b "["^|findstr /e "]"') do (
	call set gm_Userpw=%%a
)
goto :eof

::������Ŀ�˵�
:gm_Xscd
if not defined gm_Mz#1 (
	echo �㻹û���ڲ˵��м�����Ŀ,������Ŀ�ѱ��Ƴ�!
	goto :eof
)
set cdnum=1
for /l %%a in (1,1,%1) do (
	if !cdnum! lss %gm_Cdlb% (
		set /p=%%a.[!gm_Mz#%%a!]     <nul
		set /a cdnum+=1
		) else (
		set /p=%%a.[!gm_Mz#%%a!]     <nul
		echo\
		echo %gm_Xian#2%
		set cdnum=1 
		)
)
goto :eof
::�����Ŀ
:gm_Tjxm
if [%gm_Uac%]==[N] (
	set gm_Bt=��Щ������Ҫ����ԱȨ��,���Ҽ��Թ���Ա������У�
	goto gm_Zcd
)
cls
echo\
echo\
echo    %userip_Dk%
echo %gm_Xian#1%
echo    �����Ŀ
call :gm_Khfq 3
set user_tmp=%userip_Dk%
set ljfg_sum=
call :gm_Ljfg userip_Dk Ljfg_sum
set /a Ljfg_sum+=1
set userip_Dk#%Ljfg_sum%=!gm_tmpath!
for /l %%a in (1,1,%Ljfg_sum%) do set /p=%%a.[!userip_Dk#%%a!] <nul
call :gm_Khfq 3
echo              �����������ѡ��һ����Ϊ��Ŀ����;
echo                    Ҳ�����Լ�����һ����
call :gm_Khfq 2
set /p userip_Mz=��������Ŀ����[������Ҫ���������ַ�]:
if [%userip_Mz%]==[] (
	cls
	set gm_Bt=���,û������κ���Ŀ!
	echo !gm_Xian#1!
	goto gm_Zcd
)
for /l %%a in (1,1,%Ljfg_sum%) do (
	if [%%a]==[%userip_Mz%] (
		set userip_Mz=!userip_Dk#%%a!
	)
)
if exist "%gm_Pzlj%" (
	echo "%user_tmp%";%userip_Mz%>>"%gm_Pzlj%"
	) else (
	echo [!gm_Csmm!]>"%gm_Pzlj%"
	echo "%user_tmp%";%userip_Mz%>>"%gm_Pzlj%"
)
set user_tmp=
cls
set gm_Bt=���,����Ŀ[%userip_Mz%]�����!
echo !gm_Xian#1!
goto gm_Zcd

::�������Ŀɾ���˵�
:gm_Pwxm
cls
echo\
echo\
echo    code by nameyu8023 cmd@Win8
echo %gm_Xian#1%
echo    �˵��������Ŀɾ������
call :gm_Khfq 3
call :gm_Xscd !ljnum!
echo\
echo\
echo                    ������Ŀ��ż���ɾ������Ŀ;
echo             ����ֱ�������������޸Ļ����˵���������.
echo                        ����[OFF]���ر�����
echo\
echo\
set gm_Pwxm=
set /p gm_Pwxm=��������Ŀ���ɾ����ֱ����������:
if [!gm_Pwxm!]==[] exit

for /l %%a in (1,1,!ljnum!) do (
	if [%%a]==[!gm_Pwxm!] (
		set gm_Bt=���,��Ŀ��ɾ��!
		call :gm_Delxm !gm_Userip! !ljnum! !gm_Pwxm!
		goto gm_Zcd
	)
)

if /i [!gm_Pwxm!]==[off] (
	set gm_Bt=���,�����ѹر�!
	call :gm_Mmxg !gm_Csmm! !ljnum!
	goto gm_Zcd
)

set gm_Csmm=!gm_Pwxm!
call :gm_Mmxg !gm_Pwxm! !ljnum!
if [!gm_Mmyz!]==[Y] (
	set gm_Bt=���,�������޸�!
	) else (
	set gm_Bt=���,���������!
)
goto gm_Zcd




::X�ᴰ�ڷŴ�
:gm_CkfdX
set gm_CkfdX=%1
:xre
set /a gm_CkfdX+=1
mode con: cols=%gm_CkfdX% lines=%2
if %gm_CkfdX% lss %3 goto xre
goto :eof

::Y�ᴰ�ڷŴ�
:gm_CkfdY
set gm_CkfdY=%1
:yre
set /a gm_CkfdY+=1
mode con: cols=%2 lines=%gm_CkfdY%
if %gm_CkfdY% lss %3 goto yre
goto :eof



::ȥ��·���е�˫����
:gm_Qcyh
for %%a in (%1) do set %2=%%~a
goto :eof


::·���ָ�
:gm_Ljfg


for /f "delims=\" %%a in ("!%1!") do (
	set gm_tmpath=%%~na
	if [!%1#%2!]==[%%a] goto :eof
	set /a %2+=1
	set %1#!%2!=%%a
	set %1=!%1:%%a=!
	goto gm_Ljfg
)
goto :eof

::���л�ȡ
:gm_Khfq
for /l %%a in (1,1,%1) do echo\
goto :eof



::�޸�����
:gm_Mmxg
echo [%1]>"%gm_Pzlj%"
for /l %%a in (1,1,%2) do echo !gm_Lj#%%a!;!gm_Mz#%%a!>>"%gm_Pzlj%"
goto :eof

::ɾ����Ŀ
:gm_Delxm
echo [%1]>"%gm_Pzlj%"
for /l %%a in (1,1,%2) do (
	if not [%%a]==[%3] (
		echo !gm_Lj#%%a!;!gm_Mz#%%a!>>"%gm_Pzlj%"
	)
)
goto :eof


::���ر�����ȡ
:gm_blhq
echo !%2!
set %1=!%2!
goto :eof