#!/bin/bash
#mount smb
rootPasswd='5698'
mountPoint='/home/allen/dataCenter/'
mountSource='//192.168.16.81/DataCenter/FILE/_Ubackup' 
if [ "$1" == "-c" ];then
	echo ${rootPasswd}|sudo -S umount ${mountPoint}
else
	echo ${rootPasswd}|sudo -S mount.cifs ${mountSource} ${mountPoint} -o user=smbroot,pass=80235956,uid=1000
fi
exit 0
