::kill QQEIM@kingsoft files.   干掉企业QQ的间谍，<金山助手>。
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


echo 你能看到这个就说明已经可以了，不要在意报错信息，懒得屏蔽而已。

pause
