::code by nameyu8023 cmd@Win XP
@echo off
title 模拟数字表
color 80
mode con: cols=80 lines=12
setlocal enabledelayedexpansion


:memu

::截取时间
set time_1=%time:~,-3%
call :snum_
set time_2=!time_1:^:=x!


::清空变量
set tmp=
set tmp1=
set tmp2=


for %%a in (a b c d e f g) do (
	::获取数组
	for /l %%b in (0,1,7) do (
		set tmp=!time_2:~%%b,1!
		::获取字体
		call :tmp !tmp!%%a tmp1
		::字体排列
		set tmp2=!tmp2!!tmp1!
	)
)
cls
::显示日期
echo.
echo %date%
echo.
echo !tmp2!

::检测时间变化
:loop
set time_3=%time:~,-3%
if not "%time_3%"=="%time_1%" goto memu
goto loop




::多重变量获取
:tmp
set %2=!%1!
goto :eof






::设置字体
:snum_
:0
set 0a= ████ 
set 0b= █　　█ 
set 0c= █　　█ 
set 0d= █　　█ 
set 0e= █　　█ 
set 0f= █　　█ 
set 0g= ████ 


:1
set 1a=　　 ◢█ 
set 1b=　　　 █ 
set 1c=　　　 █ 
set 1d=　　　 █ 
set 1e=　　　 █ 
set 1f=　　　 █ 
set 1g=　　　 █ 


:2
set 2a= ████ 
set 2b=　　　 █ 
set 2c=　　　 █ 
set 2d= ████ 
set 2e= █　　　 
set 2f= █　　　 
set 2g= ████ 


:3
set 3a= ████ 
set 3b=　　　 █ 
set 3c=　　　 █ 
set 3d= ████ 
set 3e=　　　 █ 
set 3f=　　　 █ 
set 3g= ████ 


:4
set 4a= █　　█ 
set 4b= █　　█ 
set 4c= █　　█ 
set 4d= ████ 
set 4e=　　　 █ 
set 4f=　　　 █ 
set 4g=　　　 █ 


:5
set 5a= ████ 
set 5b= █　　　 
set 5c= █　　　 
set 5d= ████ 
set 5e=　　　 █ 
set 5f=　　　 █ 
set 5g= ████ 


:6
set 6a= ████ 
set 6b= █　　　 
set 6c= █　　　 
set 6d= ████ 
set 6e= █　　█ 
set 6f= █　　█ 
set 6g= ████ 


:7
set 7a= ████ 
set 7b=　　　 █ 
set 7c=　　　 █ 
set 7d=　　　 █ 
set 7e=　　　 █ 
set 7f=　　　 █ 
set 7g=　　　 █ 


:8
set 8a= ████ 
set 8b= █　　█ 
set 8c= █　　█ 
set 8d= ████ 
set 8e= █　　█ 
set 8f= █　　█ 
set 8g= ████ 


:9
set 9a= ████ 
set 9b= █　　█ 
set 9c= █　　█ 
set 9d= ████ 
set 9e=　　　 █ 
set 9f=　　　 █ 
set 9g= ████ 


:x
set xa=　　　　　
set xb=　　　　　
set xc=　　█　　
set xd=　　　　　
set xe=　　█　　
set xf=　　　　　
set xg=　　　　　
goto :eof
