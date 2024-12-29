@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
pushd "%~dp0"
set instPath="C:\Program Files (x86)\360\360safe\safemon\360tray.exe"
set processList=360epp.exe 360qbus.exe 360Tray.exe gmMgr_USB.exe 360DocProtect.exe ZhuDongFangYu.exe eppservice.exe eppcontainer.exe pcit_hk.exe pcit_hk_x64.exe 360EDRSensor.exe naccltWidget.exe udisktoolui.exe

echo 检查是否安装360终端安全管理...
if not exist %instPath% (
    echo 未找到360安装目录,可能未正常安装,请联系相关人员。
    goto :endScript
)

echo 关闭自保,请手动确定...
%instPath% /disablesp 1

for %%a in (%processList%) do (
    taskkill /f /im %%a
)
start "" %instPath%
:endScript
echo end.
pause


