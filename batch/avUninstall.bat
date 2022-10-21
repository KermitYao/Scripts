@echo off

set avList= "360安全卫士:360安全卫士" "360杀毒:360安全卫士" "腾讯电脑管家:QQPCMgr" "火绒安全软件:HuorongSysdiag"
set registryKey="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
set registryValue="UninstallString"

echo 开始扫描第三方安全软件...
for %%a in (%avList%) do (
	for /f "delims=: tokens=1*" %%b in (%%a) do (
		for %%d in (%registryKey%) do (
			for /f "tokens=1-2*" %%e in ('reg query "%%~d\%%~c" /v %registryValue% 2^>nul') do (
				if not "%%~g"=="" (
					set avUninstallFlag=True
					echo 启动【%%b】卸载程序: %%~g
					start /b "avUninstall" "%%~g"
				)
			)
		)
	)
)

if "%avUninstallFlag%"=="" (
	echo 脚本已完成,未扫描到启动安全软件.
) else (
	echo 脚本已完成, 请手动点击卸载程序选项进行卸载...
)


pause



