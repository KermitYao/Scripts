#!/bin/bash

#######
#linux 版teamviewer 更换ＩＤ
#time 20171208
#code by ngrain@deepin.15.5
#######
pw=5698
read -s -p "请输入管理员密码:" pw

macstr=abcdef1234567890
macid=5c:e0:fc
for l in $(seq 1 3)
do
	macid=${macid}:$(echo ${macstr}|cut -c $((RANDOM%16+1)))$(echo ${macstr}|cut -c $((RANDOM%16+1)))
done
echo 更换 TeamViewer ID.
echo 当前地址　[$(ifconfig|grep -v 'grep'|grep 'thernet'|awk '{print $2}')] 更换为 [${macid}]
echo 程序将在以下时间后开始.
for l in {6..0}
do
	printf "$l  "
	sleep 1s
done
echo ""
nic=$(ifconfig|sed -n '1p'|awk '{printf $1}'|sed 's/://')
echo ${pw}|sudo -S ifconfig $nic down
echo ${pw}|sudo -S ifconfig $nic hw ether ${macid}
echo ${pw}|sudo -S ifconfig $nic up

echo ${pw}|sudo -S ifconfig $nic down
sleep 3s
echo ${pw}|sudo -S ifconfig $nic up

for v in `ps aux|grep 'teamviewer'|grep -v 'grep'|awk '{print $2}'`
do 
	echo ${pw}|sudo -S kill -9 $v
done
test  -d ~/.config/teamviewer && rm -rf ~/.config/teamviewer
sleep 1s
echo ${pw}|sudo -S /opt/teamviewer/tv_bin/teamviewerd -d&
/opt/teamviewer/tv_bin/TeamViewer&
echo 操作完成.
exit 0
