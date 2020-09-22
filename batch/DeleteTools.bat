@echo off
mode con cols=25 lines=5
title Delete Tools
color 7f
if %1*==* goto exit
echo 正在执行删除,请稍后...
for /l %%a in (1,1,9) do (call :starts %%%%a)
echo.
echo 执行完成.
ping /n 2 127.0.1 >nul
pause>nul&exit
:starts
(echo Y|cacls %1 /p everyone:f /t>nul
rd /s/q \\?\%1
del /f/a/q/s \\?\%1)>nul 2>nul
goto :eof
:exit
echo.&echo 请拖入,不要直接打开...
echo.&echo 任意键退出...&pause>nul

