#!/bin/bash

:<<NOTES
::* 此脚本方便于360linux就版本的安装.

name: yaojianyu
mail: kermit.yao@qq.com

NOTES

# ----------sys var-----------------

eppUrlRpm="http://360epp.yjyn.top:8081/clinux-rpm/360EPP1383860355(360epp.yjyn.top_8084)-L.rpm"
eppUrlDeb="http://360epp.yjyn.top:8081/clinux-deb/360EPP1383860355(360epp.yjyn.top_8084)-L.deb"
scriptVersion=1.0

#配置临时文件目录
tempPath=./
test -d ${tempPath}||mkdir -p ${tempPath}

scriptDir="$(cd "$(dirname "$0")";pwd)"

userID=$(id -u)

#日志等级 DEBUG|INFO|WARNING|ERROR
logLevel="DEBUG"
logPath="${tempPath}/$(basename $0).log"

# ----------sys var-----------------

# ----------function-----------------
#获取包管理类型
getPackageType() {
    RPM_BASED=0
    DEB_BASED=0
    if [ -f /etc/os-release ]; then
        RPM_SYSTEMS='rhel centos fedora sles opensuse opensuse-tumbleweed opensuse-leap clearos ol amzn'
        id="$(grep '\<ID\>' /etc/os-release | cut -d = -f 2 | sed -e 's/^"//' -e 's/"$//')"
        for d in $RPM_SYSTEMS; do
            if [ x"$id" = x"$d" ]; then
                RPM_BASED=1
                break
            fi
        done
        if [ $RPM_BASED -eq 0 ]; then
            DEB_SYSTEMS='debian ubuntu linuxmint'
            for d in $DEB_SYSTEMS; do
                if [ x"$id" = x"$d" ]; then
                    DEB_BASED=1
                    break
                fi
            done
        fi
    elif [ -f /etc/redhat-release ] || [ -f /etc/centos-release ] || [ -f /etc/fedora-release ] || [ -f /etc/sles-release ] || [ -f /etc/SuSE-release ] || [ -f /etc/oracle-release ]; then
        RPM_BASED=1
    elif [ -f /etc/debian_version ]; then
        DEB_BASED=1
    fi
    
    if [[ "$RPM_BASED" = "0" && "$DEB_BASED" = "0" ]]
    then
        command -v rpm >/dev/null&& RPM_BASED=1
        command -v dpkg >/dev/null && DEB_BASED=1
    else
        return 1
    fi
    return 99
}

#文件下载;传入参数: $1 = url, $2 = filePath
fileDownload() {
    rm -f "$2"
    result=1
    (wget --connect-timeout 300 --no-check-certificate -O "$2" "$1" || curl --fail --connect-timeout 300 -k "$1" > "$2")&&result=0

    if [ "${result}" = "0" ]
    then
        return 0
    else
        return 1
    fi
    return 99
}

#打印日志输出; 传入参数: $1 = 行号, $2 = 消息类型 [DEBUG|INFO|WARNING|ERROR], $3 = 标题, $4 = 消息文本, $5 = 是否写入标准输出 [0|1], $6 = 是否写入日志文件 [0|1]
printLog() {

    case "$logLevel" in
        FALSE) logLevel="" ;; 
        DEBUG) logLevelList="DEBUG INFO WARNING ERROR";;
        INFO) logLevelList="INFO WARNING ERROR";;
        WARNING) logLevelList="WARNING ERROR";;
        ERROR) logLevelList="ERROR";;
        *) logLeveList="DEBUG INFO WARNING ERROR";;
    esac

    for level in $logLevelList
    do
        if [ "$level" = "$2" ]
        then
            if [ ! "$5" = "0" ]
            then
                echo "*$(date +%Y-%m-%d\ %H:%M:%S) - line.$1 - $2 - $3 - $4"
            fi
            if [ ! "$6" = "0" ]
            then
                echo "*$(date +%Y-%m-%d\ %H:%M:%S) - line.$1 - $2 - $3 - $4" >>$logPath
            fi
        fi
    done
}
# ----------function-----------------

main() {

	if [ "${userID}" != "0" ]
	then
		printLog $LINENO ERROR initCheck “你必须要以root身份运行此脚本,才能正常使用这些功能”
		return 99
	fi

	getPackageType
	if [ "${DEB_BASED}" = "1" ]
	then
		downUrl=${eppUrlDeb}
		instCli="dpkg -i "
		eppName=$(echo $downUrl|awk -F/ '{print $NF}'|grep -E '^360EPP[0-9]+(.+)-L\.deb') 
   else
		downUrl=${eppUrlRpm}
		instCli="rpm -ivh "
		eppName=$(echo $downUrl|awk -F/ '{print $NF}'|grep -E '^360EPP[0-9]+(.+)-L\.rpm')
	fi
	echo ${eppName}	
	if test -z "${eppName}"
	then
	    printLog $LINENO ERROR eppDowanload "无法获取到安装信息,请检查链接是否正确."
	    return 99
	fi

	printLog $LINENO INFO eppDowanload "下载 360epp 安装文件..."
    	fileDownload  "${downUrl}" "${tempPath}/${eppName}"
	if [ "$?" = "0" ] 
	then
		printLog $LINENO INFO eppDownload "360epp 下载完成,开始安装..."
		$instCli "${tempPath}/${eppName}"
		instState=$(s=$(ps -ef|grep -E '360safed|eppagent'|grep -v grep);echo $s|grep 360safed|grep eppagent)
		if test -n "${instState}"
		then
		    printLog $LINENO INFO eppInst "360epp 安装完成."
		else
		    printLog $LINENO ERROR eppInst "360epp 进程未能启动,请检查."
		    return 1
		fi
	else
		printLog $LINENO ERROR eppDownload "360epp 下载失败."
		return 1
	fi
	return 0
}

main
