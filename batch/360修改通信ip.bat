@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
pushd "%~dp0"

set newIp=10.168.3.80:8080
set instPath="C:\Program Files (x86)\360\360safe\safemon\360tray.exe"
set startPath="C:\Program Files (x86)\360\360safe\360epp.exe"
set processList=360epp.exe 360qbus.exe 360Tray.exe

echo ����Ƿ�װ360�ն˰�ȫ����...
if not exist %instPath% (
    echo δ�ҵ�360��װĿ¼,����δ������װ,����ϵ�����Ա��
    goto :endScript
)

echo ���ڼ��ͨ�ŵ�ַ�Ƿ���ȷ...
for /f "tokens=3" %%a in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\360Safe\360EntSecurity /v NewSrvIP 2^>nul ^|findstr /i "NewSrvIP"') do (
    if "%%a"=="%newIp%" (
        echo ��ǰͨ�ŵ�ַ��ȷ�������: [%%a]
        goto :endScript
    ) else (
        echo ��ǰͨ�ŵ�ַ: [%%a]
    )
)


echo ��ʼ�޸�ͨ�ŵ�ַ,���ڵ����Ľ�����ȷ��,�Խ������...
%instPath% /disablesp 1
echo �޸���ip��ַ...
reg add HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\360Safe\360EntSecurity /v NewSrvIP /d "%newip%" /f &&echo ok||echo failed
echo �޸�ͨѶip��ַ
reg add HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\360Safe\360EntSecurity /v MsgSrvIP /d "%newip%" /f &&echo ok||echo failed

for %%a in (%processList%) do (
    taskkill /f /im %%a
)
echo ����360����...
ping /n 2 127.0.0.1 >nul
%startPath%

:endScript
echo end.
pause


