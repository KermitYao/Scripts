@echo off
cd /d %~dp0

for /f "usebackq tokens=1 delims=:" %%a in (`findstr -n "^###" %0`) do (if not DEFINED skip set skip=%%a)
powershell -c "Get-Content '%~0' | Select-Object -Skip %skip% | Out-String | Invoke-Expression"

pause
exit
###