@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
pushd "%~dp0"
set instPath="C:\Program Files (x86)\360\360safe\safemon\360tray.exe"
set processList=360epp.exe 360qbus.exe 360Tray.exe gmMgr_USB.exe 360DocProtect.exe ZhuDongFangYu.exe eppservice.exe eppcontainer.exe pcit_hk.exe pcit_hk_x64.exe 360EDRSensor.exe naccltWidget.exe udisktoolui.exe

echo ����Ƿ�װ360�ն˰�ȫ����...
if not exist %instPath% (
    echo δ�ҵ�360��װĿ¼,����δ������װ,����ϵ�����Ա��
    goto :endScript
)

echo �ر��Ա�,���ֶ�ȷ��...
%instPath% /disablesp 1

for %%a in (%processList%) do (
    taskkill /f /im %%a
)
start "" %instPath%
:endScript
echo end.
pause


