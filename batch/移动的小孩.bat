@echo off
setlocal enabledelayedexpansion
color 5f
mode con: cols=75 lines=4
:memu
for /l %%a in (1,1,60) do (
set a= !a!
ping /n 1 127.1 >nul
cls
echo !a!     ��q��r  
echo !a!    /���Ũ�\ 
echo !a!    ~��~~��~
)
for /l %%a in (1,1,60) do (
set a=!a:~,-1!
ping /n 1 127.1 >nul
cls
echo !a!     ��q��r  
echo !a!    /���Ũ�\ 
echo !a!    ~��~~��~
)
goto memu






set tmp1=%x_renwu1%           %y_renwu1%
set tmp2=%x_renwu2%           %y_renwu2%
set tmp3=%x_renwu3%           %y_renwu3%