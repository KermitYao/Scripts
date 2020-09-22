::code by nameyu8023 cmd@Win8
@echo off
setlocal enabledelayedexpansion
mode con: cols=77 lines=23
color 6f
set gm_Btxs=shortcut menu
set gm_Xian#1=-----------------------------------------------------------------------------
set gm_Xian#2=~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::每行显示多少个项目
set gm_Cdlb=4
::初始标题
set gm_Bt=code by nameyu8023 cmd@Win8
::配置文件路径
set gm_Pzlj=D:\gm_Pzwj.inf
::打开项目后菜单是否退出
set gm_Tc=Y
::密码验证
set gm_Mmyz=N
::初始密码
set gm_Csmm=802359
::_____________________________________
::窗口特效
title %gm_Btxs%
call :gm_CkfdX 16 3 77
call :gm_CkfdY 3  77 23
echo 正在读取...
::测试UAC
set UAC_file=gm_Pzlj
(echo "%gm_Btxs%" >"%UAC_file%")>nul 2>nul
if exist "%UAC_file%" (
	set gm_Uac=Y
	del "%UAC_file%"
	) else (
	set gm_Uac=N
)

::密码验证
for /l %%a in (0,1,9) do (
	set gm_Usermm=!gm_Usermm!%%a
)
if exist "%gm_Pzlj%" (
	call :gm_Hqlj
	cls
	call :gm_Khfq 2
	if not defined gm_Userpw (
		echo 密码遭到破坏!
		pause>nul
		exit
	)
	if not [!gm_Csmm!]==!gm_Userpw! (
		set gm_Mmyz=Y
		echo                          此菜单有密码保护!
		call :gm_Khfq 5
		set /p gm_Userip=密码验证,请输入密码!:
		if [!gm_Userip!]==!gm_Userpw! goto gm_Zcd
		echo                             密码错误。
		ping /n 3 127.1>nul
		exit
	)
)

::菜单显示
:gm_Zcd
set ljnum=0
if exist "%gm_Pzlj%" call :gm_Hqlj
set /a gm_Ckhs=ljnum/gm_Cdlb*3+25
call :gm_CkfdY 23  77 %gm_Ckhs%
echo\
echo    %gm_Bt%
echo %gm_Xian#1%
echo    主菜单
call :gm_Khfq 3

call :gm_Xscd !ljnum!
echo\
echo %gm_Xian#2%
echo\
echo                       P.菜单密码和项目删除操作.
echo\
echo       共[%ljnum%]条项目.
echo\
pushd %temp%
>"你需要做什么？[直接拖入文件,则添加项目]" echo.
findstr /a:0c .* "你需要做什么？[直接拖入文件,则添加项目]*"
del "你需要做什么？[直接拖入文件,则添加项目]" >nul 2>nul
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
		set gm_Bt=这些操作需要管理员权限,请右键以管理员身份运行！
		goto gm_Zcd
	)
	goto gm_Pwxm
)

call :gm_Qcyh %userip_Dk% userip_Dk
if exist "%userip_Dk%" goto gm_Tjxm
for /l %%a in (1,1,%ljnum%) do (
	if not exist !gm_Lj#%userip_Dk%! (
		cls
		set gm_Bt=错误,请再次选择!
		echo !gm_Xian#1!
		goto gm_Zcd
	) else (
		start "" !gm_Lj#%userip_Dk%!
		if [%gm_Tc%]==[Y] (
			set /p=    已启动... <nul 
			for %%b in (3 2 1) do (
				set /p=%%b  <nul
				ping /n 2 127.1>nul
			)
				exit
		) else (
		cls
		set gm_Bt=完成,项目[!gm_Mz#%userip_Dk%!]已打开!
		echo !gm_Xian#1!
		goto gm_Zcd
		)

	)
)



::提取项目路径和名称
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

::处理项目菜单
:gm_Xscd
if not defined gm_Mz#1 (
	echo 你还没有在菜单中加入项目,或者项目已被移除!
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
::添加项目
:gm_Tjxm
if [%gm_Uac%]==[N] (
	set gm_Bt=这些操作需要管理员权限,请右键以管理员身份运行！
	goto gm_Zcd
)
cls
echo\
echo\
echo    %userip_Dk%
echo %gm_Xian#1%
echo    添加项目
call :gm_Khfq 3
set user_tmp=%userip_Dk%
set ljfg_sum=
call :gm_Ljfg userip_Dk Ljfg_sum
set /a Ljfg_sum+=1
set userip_Dk#%Ljfg_sum%=!gm_tmpath!
for /l %%a in (1,1,%Ljfg_sum%) do set /p=%%a.[!userip_Dk#%%a!] <nul
call :gm_Khfq 3
echo              你可以在上面选择一个作为项目名称;
echo                    也可以自己定义一个。
call :gm_Khfq 2
set /p userip_Mz=请输入项目名称[尽量不要输入特殊字符]:
if [%userip_Mz%]==[] (
	cls
	set gm_Bt=完成,没有添加任何项目!
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
set gm_Bt=完成,新项目[%userip_Mz%]已添加!
echo !gm_Xian#1!
goto gm_Zcd

::密码和项目删除菜单
:gm_Pwxm
cls
echo\
echo\
echo    code by nameyu8023 cmd@Win8
echo %gm_Xian#1%
echo    菜单密码和项目删除操作
call :gm_Khfq 3
call :gm_Xscd !ljnum!
echo\
echo\
echo                    输入项目编号即可删除此项目;
echo             或者直接输入密码来修改或开启菜单进入密码.
echo                        输入[OFF]来关闭密码
echo\
echo\
set gm_Pwxm=
set /p gm_Pwxm=请输入项目编号删除或直接输入密码:
if [!gm_Pwxm!]==[] exit

for /l %%a in (1,1,!ljnum!) do (
	if [%%a]==[!gm_Pwxm!] (
		set gm_Bt=完成,项目已删除!
		call :gm_Delxm !gm_Userip! !ljnum! !gm_Pwxm!
		goto gm_Zcd
	)
)

if /i [!gm_Pwxm!]==[off] (
	set gm_Bt=完成,密码已关闭!
	call :gm_Mmxg !gm_Csmm! !ljnum!
	goto gm_Zcd
)

set gm_Csmm=!gm_Pwxm!
call :gm_Mmxg !gm_Pwxm! !ljnum!
if [!gm_Mmyz!]==[Y] (
	set gm_Bt=完成,密码已修改!
	) else (
	set gm_Bt=完成,密码已添加!
)
goto gm_Zcd




::X轴窗口放大
:gm_CkfdX
set gm_CkfdX=%1
:xre
set /a gm_CkfdX+=1
mode con: cols=%gm_CkfdX% lines=%2
if %gm_CkfdX% lss %3 goto xre
goto :eof

::Y轴窗口放大
:gm_CkfdY
set gm_CkfdY=%1
:yre
set /a gm_CkfdY+=1
mode con: cols=%2 lines=%gm_CkfdY%
if %gm_CkfdY% lss %3 goto yre
goto :eof



::去除路径中的双引号
:gm_Qcyh
for %%a in (%1) do set %2=%%~a
goto :eof


::路径分割
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

::空行获取
:gm_Khfq
for /l %%a in (1,1,%1) do echo\
goto :eof



::修改密码
:gm_Mmxg
echo [%1]>"%gm_Pzlj%"
for /l %%a in (1,1,%2) do echo !gm_Lj#%%a!;!gm_Mz#%%a!>>"%gm_Pzlj%"
goto :eof

::删除项目
:gm_Delxm
echo [%1]>"%gm_Pzlj%"
for /l %%a in (1,1,%2) do (
	if not [%%a]==[%3] (
		echo !gm_Lj#%%a!;!gm_Mz#%%a!>>"%gm_Pzlj%"
	)
)
goto :eof


::多重变量获取
:gm_blhq
echo !%2!
set %1=!%2!
goto :eof