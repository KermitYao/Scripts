::code by night cmd&xp
@echo off
title 压缩图片生成  # 当前目录:%cd%#
color 79
mode con: cols=75 lines=20
:memu
echo\
echo                             压缩图片生成
echo             ├┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬
echo             ├ 因为一些社区论坛,不能上传附件但可以贴图┤     
echo             ├         所以此工具应此而生             ┤
echo             ├     将经压缩的文件打包进图片里         ┤
echo             ├      生成的文件以图片形式存在          ┤
echo             ├ 使用时将后缀改为.RAR解压既是正常的文件 ┤
echo             ├             2013-4-19                  ┤
echo             ├┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┤
echo\
:memu_1
set img_path=
echo ^<你需要输入图片路径,可直接拖到此处^>
set /p img_path=:
if not defined img_path (
	echo 路径不能为空。
	echo --------------------------
	goto memu_1
	)
if not exist %img_path% (
	echo 路径不正确,请重新输入...
	echo --------------------------
	goto memu_1
	)
:memu_2
set rar_path=
echo ^<你需要输入压缩路径,可直接拖到此处^>
set /p rar_path=:
if not defined rar_path (
	echo 路径不能为空。
	echo --------------------------
	goto memu_2
	)
if not exist %rar_path% (
	echo 路径不正确,请重新输入...
	echo --------------------------
	goto memu_2
	)
cls
echo 图片路径【%img_path%】正确
echo 压缩路径【%rar_path%】正确
echo 输入无误,正在生成...
set file_num=0
call :operate  %img_path% %rar_path%
if exist "%cd%\New_Img_%file_num%.jpg" (
	echo 文件已生成【%cd%\New_Img_%file_num%.jpg】
	echo ------------------------------
	goto memu
)
echo 生成失败【错误未知】
echo ------------------------------
goto memu
:operate
(if not exist "%cd%\New_Img_%file_num%.jpg" (
copy /b %~fs1 + %~fs2 "%cd%\New_Img_%file_num%.jpg"
) else (
set /a file_num+=1
goto operate
))>nul 2>nul
goto :eof
