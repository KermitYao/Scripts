@echo off
setlocal enabledelayedexpansion
color 5f
mode con: cols=75 lines=4
:memu
for /l %%a in (1,1,60) do (
set a= !a!
ping /n 1 127.1 >nul
cls
echo !a!     ¡ñ¨q¡ð¨r  
echo !a!    /¨€¡Å¨€\ 
echo !a!    ~¡Ç~~¡Ç~
)
for /l %%a in (1,1,60) do (
set a=!a:~,-1!
ping /n 1 127.1 >nul
cls
echo !a!     ¡ñ¨q¡ð¨r  
echo !a!    /¨€¡Å¨€\ 
echo !a!    ~¡Ç~~¡Ç~
)
goto memu






set tmp1=%x_renwu1%           %y_renwu1%
set tmp2=%x_renwu2%           %y_renwu2%
set tmp3=%x_renwu3%           %y_renwu3%