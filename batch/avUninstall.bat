@echo off

set avList= "360��ȫ��ʿ:360��ȫ��ʿ" "360ɱ��:360��ȫ��ʿ" "��Ѷ���Թܼ�:QQPCMgr" "���ް�ȫ���:HuorongSysdiag"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

echo ��ʼɨ���������ȫ���...
for %%a in (%avList%) do (
	for /f "delims=: tokens=1*" %%b in (%%a) do (
		for %%d in (%registryKey%) do (
			for /f "tokens=1-2*" %%e in ('reg query "%%~d\%%~c" /v %registryValue% 2^>nul') do (
				if not "%%~g"=="" (
					set avUninstallFlag=True
					echo ������%%b��ж�س���: %%~g
					start /b "avUninstall" "%%~g"
				)
			)
		)
	)
)

if "%avUninstallFlag%"=="" (
	echo �ű������,δɨ�赽������ȫ���.
) else (
	echo �ű������, ���ֶ����ж�س���ѡ�����ж��...
)


pause



