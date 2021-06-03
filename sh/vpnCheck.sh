#/bin/bash

function getVpnStatus() {
	vpnStatusContent=$(expressvpn status  |head -n 1)
	if [[ "${vpnStatusContent}" =~ "Not connected" ]];then
		echo null
	elif [[ "${vpnStatusContent}" =~ "Unable to connect" ]];then
		echo error
	elif [[ "${vpnStatusContent}" =~ "Connected to" ]];then
		echo true
	else
		echo false
	fi

}



exitCode=0
vpnStatus=$(getVpnStatus)
echo Vpn status is ${vpnStatus}

if [ "${vpnStatus}" != "true" ];then
	expressvpn disconnect
	expressvpn connect
fi

vpnStatus=$(getVpnStatus)
echo ${vpnStatus}
if [ "${vpnStatus}" != "true" ];
then
	echo Connected to vpn is failed. 	
	exitCode=1
else
	echo Connected to vpn is successful.
fi

echo Operation done. -- Time: $(date)
exit ${exitCode}

