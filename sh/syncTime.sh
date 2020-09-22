#/bin/bash

#get time

syncTime=/var/log/syncTime.log
remoteTime=$(curl -kLs --connect-timeout 10 http://tools.yjyn.top:6081/gettime)

if [[ ${remoteTime} == 202* ]]
then
	date -s "${remoteTime}"
	echo "sync time:${remoteTime}"|tee -a ${syncTime}
else
	echo "sync time error-${remoteTime}-$(date)"|tee -a ${syncTime}
fi
exit



