::code by night cmd&xp
@echo off
title ѹ��ͼƬ����  # ��ǰĿ¼:%cd%#
color 79
mode con: cols=75 lines=20
:memu
echo\
echo                             ѹ��ͼƬ����
echo             ���ЩЩЩЩЩЩЩЩЩЩЩЩЩЩЩЩЩЩЩЩ�
echo             �� ��ΪһЩ������̳,�����ϴ�������������ͼ��     
echo             ��         ���Դ˹���Ӧ�˶���             ��
echo             ��     ����ѹ�����ļ������ͼƬ��         ��
echo             ��      ���ɵ��ļ���ͼƬ��ʽ����          ��
echo             �� ʹ��ʱ����׺��Ϊ.RAR��ѹ�����������ļ� ��
echo             ��             2013-4-19                  ��
echo             ���ةةةةةةةةةةةةةةةةةةةة�
echo\
:memu_1
set img_path=
echo ^<����Ҫ����ͼƬ·��,��ֱ���ϵ��˴�^>
set /p img_path=:
if not defined img_path (
	echo ·������Ϊ�ա�
	echo --------------------------
	goto memu_1
	)
if not exist %img_path% (
	echo ·������ȷ,����������...
	echo --------------------------
	goto memu_1
	)
:memu_2
set rar_path=
echo ^<����Ҫ����ѹ��·��,��ֱ���ϵ��˴�^>
set /p rar_path=:
if not defined rar_path (
	echo ·������Ϊ�ա�
	echo --------------------------
	goto memu_2
	)
if not exist %rar_path% (
	echo ·������ȷ,����������...
	echo --------------------------
	goto memu_2
	)
cls
echo ͼƬ·����%img_path%����ȷ
echo ѹ��·����%rar_path%����ȷ
echo ��������,��������...
set file_num=0
call :operate  %img_path% %rar_path%
if exist "%cd%\New_Img_%file_num%.jpg" (
	echo �ļ������ɡ�%cd%\New_Img_%file_num%.jpg��
	echo ------------------------------
	goto memu
)
echo ����ʧ�ܡ�����δ֪��
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
