#!/bin/bash

conf_dir="/etc/sysconfig/network-scripts/ifcfg-"
function getNetDev() {
	for i in $(ip link show|awk -F":" '{print $2}'|sed 's/ //g'|grep "^e.*")
	do
		if [ -f "${conf_dir}${i}" ]
		then
			if [ -z "$(cat "${conf_dir}${i}"|grep "^DNS1=")" ]
			then
				echo "DNS1=223.5.5.5" >>"${conf_dir}${i}"
			else
				sed -i 's/DNS1=.*/DNS1=223.5.5.5/g' "${conf_dir}${i}"
			fi
		fi
	done
}

function main() {
	getNetDev
}

main
