#!/bin/bash
network=192.168.16

#this is by test network.
#
#9c543a
#2017-06-28 13.45
#by:ngrain@deepin
##################

details=true

test ! -d ~/Network/&&mkdir ~/Network &>/dev/null
for var in $(seq 1 254)
do
	ping -c 1 ${network}.${var}&>/dev/null&&echo ping -c 1 ${network}.${var} test.>~/Network/${network}.${var}&
done

while [ $(ps aux|grep 'ping -c 1 192.168.0'|wc -l) -gt 5 ]
do
	sleep 1s
done

[ "$2" = "false" ]&&details=false

printf '%7s   %15s  %17s\t  %s\n' $(echo State IP MAC HostName)
case $1 in
	"all")
	for var in $(seq 1 254)
	do
		if [ -f ~/Network/${network}.${var} ];then
			[ "${details}" = "true" ]&&netinfo=$(nmblookup -A ${network}.${var}|sed '1d')
			echo ${netinfo}|grep 'MAC Address' &>/dev/null
			if [ $? -eq 0 ];then
				mac=$(echo $netinfo|sed 's/^.*Address = //g')
				host=$(echo $netinfo|sed 's/<.*$//g')
			else
				mac=null
				host=null
			fi
			printf '%7s   %15s  %17s\t  %s\n' $(echo [True] ${network}.${var} ${mac} ${host})
		else
			mac=null
			host=null
			printf '%7s   %15s  %17s\t  %s\n' $(echo [False] ${network}.${var} ${mac} ${host})
		fi
	done
	;;
	"true")
	for var in $(seq 1 254)
	do
		if [ -f ~/Network/${network}.${var} ];then
			[ "${details}" = "true" ]&&netinfo=$(nmblookup -A ${network}.${var}|sed '1d')
			echo ${netinfo}|grep 'MAC Address' &>/dev/null
			if [ $? -eq 0 ];then
				mac=$(echo $netinfo|sed 's/^.*Address = //g')
				host=$(echo $netinfo|sed 's/<.*$//g')
			else
				mac=null
				host=null
			fi
			printf '%7s   %15s  %17s\t  %s\n' $(echo [True] ${network}.${var} ${mac} ${host})
		else
			tmp=tmp
		fi
	done
	;;
	"false")
	for var in $(seq 1 254)
	do
		if [ -f ~/Network/${network}.${var} ];then
			tmp=tmp
		else
			mac=null
			host=null
			printf '%7s   %15s  %17s\t  %s\n' $(echo [False] ${network}.${var} ${mac} ${host})
		fi
	done
	;;
	"")
	for var in $(seq 1 254)
	do
		if [ -f ~/Network/${network}.${var} ];then
			[ "${details}" = "true" ]&&netinfo=$(nmblookup -A ${network}.${var}|sed '1d')
			echo ${netinfo}|grep 'MAC Address' &>/dev/null
			if [ $? -eq 0 ];then
				mac=$(echo $netinfo|sed 's/^.*Address = //g')
				host=$(echo $netinfo|sed 's/<.*$//g')
			else
				mac=null
				host=null
			fi
			printf '%7s   %15s  %17s\t  %s\n' $(echo [True] ${network}.${var} ${mac} ${host})
		else
			mac=null
			host=null
			printf '%7s   %15s  %17s\t  %s\n' $(echo [False] ${network}.${var} ${mac} ${host})
		fi
	done
	;;
	*)
	echo "Usage: $0 {all|true|false} {true|false}" >&2
	;;
esac

rm -rf ~/Network >/dev/null 2>&1
exit 0



