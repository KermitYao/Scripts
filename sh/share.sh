#!/bin/sh
user=administrator
pw=Wanghua126126
up=5698
for var in  发货通知
do
	echo ${up}|sudo -S umount /mnt/$var >/dev/null
	echo ${up}|sudo -S rm -r /mnt/$var
	if [ ! -d /mnt/$var ];then
		echo ${up}|sudo -S mkdir /mnt/$var
		echo "[ok] mkdir files $var"
		if [ ! -e ~/Desktop/$var ];then
			ln -s /mnt/$var ~/Desktop/$var
			echo "[ok] ln file $var"
		fi
	fi
	echo ${up}|sudo -S mount -o username=${user},password=${pw} //192.168.0.3/$var /mnt/$var
	echo [ok] mount $var.
done
exit 0
