::kill QQEIM@kingsoft files.   �ɵ���ҵQQ�ļ����<��ɽ����>��
::2017.07.04

@echo off
set p1=C:\Program Files (x86)\kingsoft\Enterprise Security
set p2=KisService.exe KisTray.exe KPacket.exe uninst.exe uniuwiz.exe LSPRemover.exe LSPRemover.exe LogPicker.exe
md "%p1%"
for %%a in (%p2%) do echo y|cacls "%p1%\%%a" /p everyone:n
sc config kagentsvc start= disabled
sc config kbqsvc start= disabled
sc config KisService start= disabled
for %%a in (%p2%) do taskkill /f /t /im %%a
echo y|cacls "%p1%" /t /p everyone:n


echo ���ܿ��������˵���Ѿ������ˣ���Ҫ���ⱨ����Ϣ���������ζ��ѡ�

pause
