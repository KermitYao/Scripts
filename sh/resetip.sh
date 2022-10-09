#!/bin/bash
# ver: 1.1.1
# 用于自动对360epp IP地址进行修改
#
#
function resetip() {
	echo Configuring ip address...
	echo IP: ${ipAddr}
	echo GATEWAY: ${gateway}
	echo DNS: ${dns}
	nmcli connection modify ${netCard} ipv4.method manual ipv4.addresses ${ipAddr} ipv4.dns ${dns} ipv4.gateway ${gateway} autoconnect yes	
	echo Restarting the network...
	systemctl restart network
}


function resetDocker() {
	cd ${runPath}
	echo Uninstalling docker......
	docker-compose down
	sleep 5
	echo Installing docker...
	docker-compose up -d
}


function printHelp() {
  cat <<EOF
  Usage: $(basename $0) [options]
    
    -h, --help         	[optional] print this help message
    -i, --ip     	[optional] Set ip address
    -g, --gateway	[optional] Set gateway address
    -d, --dns		[optional] Set dns address
		Example:$(basename $0) -i "192.168.16.32/24" -g "192.168.16.1" -d "223.5.5.5" 
	
                kermit.yao@qq.com 2022-10-08
         
EOF

}

function getArgs()
{
    while test $# != 0
    do
        case "$1" in
            -h|--help)
            printHelp
            exit 0
        ;;
            -i|--ip)
            shift
            ipAddr=$1
        ;;
            -g|--gateway)
            shift
            gateway=$1
        ;;
	    -d|--dns)
	    shift
	    dns=$1
	;;
        *)
        echo "Unknown option \"$1\". Run '$(basename $0) --help' for usage information." >&2
        exit 1
        ;;
      esac
      shift
    done
}


function main() {
	runPath="/home/s/lcsd"
	netCard="enp0s3"
	ipAddr=
	gateway=
	dns="223.5.5.5"
	getArgs $@
	ipAddr=$(echo "${ipAddr}" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}")
	gateway=$(echo "${gateway}" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")
	dns=$(echo "${dns}" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")

	if [ -z "${ipAddr}" ];
	then
		echo The IP address format is incorrect. Please check...
		exit 1
	fi

	if [ -z "${gateway}" ];
	then
		echo The gateway address format is incorrect. Please check...
		exit 1
	fi


	if [ -z "${dns}" ];
	then
		echo The DNS address format is incorrect. Please check...
		exit 1
	fi

	resetip
	resetDocker
	reboot
}

main $@




