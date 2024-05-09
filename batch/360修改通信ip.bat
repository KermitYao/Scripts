@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
pushd "%~dp0"

set newIp=10.168.3.80:8080
set instPath="C:\Program Files (x86)\360\360safe\safemon\360tray.exe"
set startPath="C:\Program Files (x86)\360\360safe\360epp.exe"
set processList=360epp.exe 360qbus.exe 360Tray.exe

echo 检查是否安装360终端安全管理...
if not exist %instPath% (
    echo 未找到360安装目录,可能未正常安装,请联系相关人员。
    goto :endScript
)

echo 正在检查通信地址是否正确...
for /f "tokens=3" %%a in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\360Safe\360EntSecurity /v NewSrvIP 2^>nul ^|findstr /i "NewSrvIP"') do (
    if "%%a"=="%newIp%" (
        echo 当前通信地址正确无需更改: [%%a]
        goto :endScript
    ) else (
        echo 当前通信地址: [%%a]
    )
)


echo 开始修改通信地址,请在弹出的界面点解确定,以解除锁定...
%instPath% /disablesp 1
echo 修改新ip地址...
reg add HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\360Safe\360EntSecurity /v NewSrvIP /d "%newip%" /f &&echo ok||echo failed
echo 修改通讯ip地址
reg add HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\360Safe\360EntSecurity /v MsgSrvIP /d "%newip%" /f &&echo ok||echo failed

for %%a in (%processList%) do (
    taskkill /f /im %%a
)
echo 启动360进程...
ping /n 2 127.0.0.1 >nul
%startPath%

:endScript
echo end.
pause


