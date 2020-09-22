#!/bin/bash
#rsync yjyn.top.
_date=`date`
_log='/var/log/rsync_dataCenter.log'
echo ---------- ${_date}---------- >>$_log
for files in Company Android Scripts ServerTools Tools
do
	if [ "$1" == "-d" ]
		then
			echo rsync -avz rsync@yjyn.top::backup/${files} /media/dataCenter/FILE/_Uback >>$_log
		else
			echo rsync -avz rsync@yjyn.top::backup/${files} /media/dataCenter/FILE/_Uback
	fi
done

echo ------------------------- >>$_log
exit

