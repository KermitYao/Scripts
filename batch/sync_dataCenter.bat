::����ͬ���������ĺͱ���������һ���ԣ�����������ΪԴ��

@echo off
set _log="%windir%\Logs\sync_dataCenter.log"
echo -----------------%date% %time%----------------->>%_log%
net use \\192.168.31.81 /user:smbroot 80235956
xcopy /ydec \\192.168.31.81\dataCenter\FILE\_Ubackup Y:\_Uback >>%_log%  2>&1
net use \\192.168.31.81 /delete
echo --------------------------------------------------->>%_log%
exit