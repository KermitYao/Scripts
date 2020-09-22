@echo off
ver|find "版本 5.">nul&&set sysStatus=True
if  "%sysStatus%"=="True" (
    echo 不被支持的系统!
    pause
    exit /b 0
)
set psfile=%temp%\pstmp.ps1
(
for /f "delims= skip=19" %%a in ('type %0') do (
	echo %%a
)
)>%psfile%
powershell -file %psfile% %*
del /q %psfile%
exit /b 0


:ps1
$pros = (Get-Process)
$prosMax = 20
write-host "$args"
for($n=1;$prosmax -gt $n;$n++)
{
    echo $n
}