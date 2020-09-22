#!/bin/sh

initVar(){
    vmsCount=0
    getCount=0
    vmsCount=$(($(vim-cmd vmsvc/getallvms|wc -l)-1))
    ret=Null
    vmsAll="False"
    getVms="False"
    setVms="False"
    setVmsC="False"
    setVmsO="False"
}

getAll(){                                                                                                                                   
    vmsInfo=$(vim-cmd vmsvc/getallvms)
    echo "${vmsInfo}"|while read info                                                                                                                          
            do                                                                                                                                                 
                    if [ ${getCount} -gt 0 ]                                                                                                                 
                    then                                                                                                                     
                            echo ${info% *}                                                                                                                    
                            echo "    "$(vim-cmd vmsvc/power.getstate ${getCount}|grep 'Powered')                                                              
                    fi
                    let getCount++                                                                                                                                        
            done                              
}

#接受参数　$1 = id
getVms(){
	vInfo=$(vim-cmd vmsvc/power.getstate $1|grep 'Powered')
	vInfo=${vInfo#* }
	if [ "${vInfo}" == 'on' ]
	then
		return 0
	elif [ "${vInfo}" == 'off' ]
	then
		return 1
	else
		return 2
	fi
}

#接受参数　$1 = off|on ,$2 = id
setVms(){
	if [ "$1" == "off" ]||[ "$1" == "on" ];then
		if [ "$1" == "off" ];then
			getVms $2
			if [ $? == 1 ];then
				return 0
			else
				vim-cmd vmsvc/power.off $2 >/dev/null
				return 1
			fi
		elif [ "$1" == "on" ];then
			getVms $2
			if [ $? == 0 ];then
				return 0
			else
				vim-cmd vmsvc/power.on $2 >/dev/null
				return 1
			fi
                fi
	else
		return 3
	fi
}

getUsage(){
    echo "Usage:"
    echo "  $0 [-a ] [-g id] [-c|o id|a] [-h|?]"
    echo "说明:"
    echo "      [-a]     获取全部的虚拟机列表和状态."
    echo "      [-g id] 为获取指定的虚拟机的状态."
    echo "      [-c id|a] 为关闭指定的虚拟机,可选参数a则关闭所有虚拟机."
    echo "      [-o id|a] 为打开指定的虚拟机,可选参数o则打开所有虚拟机."
    echo "      [-h|?]   获取帮助信息."
    echo "      id 指的是虚拟机的序号,可以用 [-a] 参数查看id."
    exit 1
}

#接受参数 $@
setOpt(){
    while getopts 'ag:c:o:h' OPT; do
        case $OPT in
            a) vmsAll="True";;
            g) getVms="True"&&getVmsV="$OPTARG";;
            c) setVmsC="True"&&setVmsCV="$OPTARG";;
            o) setVmsO="True"&&setVmsOV="$OPTARG";;
            h) getUsage;;
            ?) getUsage;;
        esac
    done
}
initVar
setOpt $@

if [ "${vmsAll}" == "True" ];then
    getAll
elif [ "${getVms}" == "True" ];then
    getVms ${getVmsV}
    if [ $? == 0 ];then
        echo vmsID:${getVmsV} -- vmsState:on
    elif [ $? == 1 ];then
        echo vmsID:${getVmsV} -- vmsState:off
    else
        echo vmsID:${getVmsV} -- vmsState:错误.
    fi
elif [ "${setVmsC}" == "True" ];then
    #处理关闭参数为 a
    if [ "${setVmsCV}" == "a" ];then
        for i in $(seq ${vmsCount})
        do
            setVms off $i
            if [ $? == 0 ];then
                echo vmsID:$i -- vmsState:已关闭.
            elif [ $? == 1 ];then
                echo vmsID:$i -- vmsState:正在关闭.
            else
                echo vmsID:$i -- vmsState:错误.
            fi
        done
    else
    	setVms off "${setVmsCV}"
    	if [ $? == 0 ];then
        	echo vmsID:${setVmsCV} -- vmsState:已关闭.
    	elif [ $? == 1 ];then
        	echo vmsID:${setVmsCV} -- vmsState:正在关闭.
    	else
        	echo vmsID:${setVmsCV} -- vmsState:错误.
    	fi
    fi
elif [ "${setVmsO}" == "True" ];then
    #处理开启参数为 a
    if [ "${setVmsOV}" == "a" ];then
        for i in $(seq ${vmsCount})
        do
            setVms on $i
            if [ $? == 0 ];then
                echo vmsID:$i -- vmsState:已开启.
            elif [ $? == 1 ];then
                echo vmsID:$i -- vmsState:正在开启.
            else
                echo vmsID:$i -- vmsState:错误.
            fi    
        done
    else    
    	setVms on "${setVmsOV}"
    	if [ $? == 0 ];then
        	echo vmsID:${setVmsOV} -- vmsState:已开启.
    	elif [ $? == 1 ];then
    	    	echo vmsID:${setVmsOV} -- vmsState:正在开启.
    	else
  	      echo vmsID:${setVmsOV} -- vmsState:错误.
    	fi
    fi
else
    getUsage
fi
exit 0