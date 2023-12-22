#linux script
#记录一些常用的shell脚本功能模块。

#获取mac地址
getMacAddress() {
	macNameList=$(ip link show|grep -E "^[0-9]+.*e.*:" |awk -F":" '{print $2}'|awk '$1=$1'|grep -E "^e")
	for name in $macNameList
	do
		macAddress=$(ip link show $name 2>/dev/null|grep "link/ether"|awk '{print $2}')
		macAddress=${macAddress//:/}
		macAddress=${macAddress// /}
		if [ -n "$macAddress" ]
		then
			if [ "$macAddress" != "ffffffffffff" ]
			then
				break
			fi
		fi
	done
}