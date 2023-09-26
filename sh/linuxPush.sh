#!/bin/bash
:<<NOTES
脚本逻辑
1. dns分内外网
    生产正则： ^(192\.168|172\.28)\.[0-9]+\.[0-9]+$ 
        配置dns： 
            DNS1=192.168.99.8
            DNS2=192.168.100.22
    测试正则： ^(172\.18|172\.29|172\.30)\.[0-9]+\.[0-9]+$
        配置dns： 
            DNS1=172.18.100.8
            DNS2=192.168.100.22 #DNS不为空则不做修改

2. hostname
    获取以 e 开头的网卡的ip地址，并且地址符合此正则： (192\.168|172\.18|172\.28|172\.29|172\.30)\.[0-9]+\.[0-9]+
    将ip地址中的 “.” 替换为 "-" 尾部加域：".square.dns",例如：192.168.30.1 = 192-168-30-1.square.dns 写入本地hostname

3.yum源
    将 /etc/yum.repos.d/*.repo 文件移动到 /etc/yum.repos.d/*.repo.bak
    下载 wget http://172.29.241.165/CentOS-Base.repo 到 /etc/yum.repos.d/CentOS-Base.repo
    并更新缓存：
        yum clean all
        yum makecache

4.ivanti 安装
    下载：
        http://172.29.241.102/isec/isec.cer
        http://172.29.241.102/isec/ISecAgent-Centos7.tar
    解压：
        tar -xf ISecAgent-Centos7.tar
    执行安装:
        bash install.sh --host 172-29-241-102 --port 3121 --passphrase abcd@123 --issuer-certificate isec.cer --selected-policy Linux_Scan

--------------------
所有文件下载到：/tmp/pushTools
并留下日志：/tmp/pushTools/linuxSet.sh.log

NOTES

#获取不同环境的dns配置
getEnv() {
    currDns=
    #生产环境
    ip addr show|grep -E "(192\.168|172\.28)\.[0-9]+\.[0-9]+" >/dev/null&&(
        currDns=172.18.100.8
        serverHost="ip hostname"
        repoUrl=http://172.29.241.102/isec/CentOS-Base.repo
        iseccCerUrl=http://172.29.241.102/isec/isec.cer
        iseccAgentUrl=lhttp://172.29.241.102/isec/ISecAgent-Centos7.tar
        isecHostname=172-29-241-102.square.dns
        )
    #测试环境
    ip addr show|grep -E "(172\.18|172\.29|172\.30)\.[0-9]+\.[0-9]+" >/dev/null&&(
        currDns=172.18.100.8
        serverHost="ip hostname"
        repoUrl=http://172.29.241.102/isec/CentOS-Base.repo
        iseccCerUrl=http://172.29.241.102/isec/isec.cer
        iseccAgentUrl=lhttp://172.29.241.102/isec/ISecAgent-Centos7.tar
        isecHostname=172-29-241-102.square.dns
        )
}

#配置dns
setDns() {
    #写入dns到 所有网卡以 e开头的配置文件
	for i in $(ip link show|awk -F":" '{print $2}'|sed 's/ //g'|grep "^e.*")
	do
		if [ -f "${ipconfPath}${i}" ]
		then
            IPADDR=
            . ${ipconfPath}${i}
            getEnv ${IPADDR}
            if [ -n "$currDns" ]
            then
                if [ -n "$DNS1" ]
                then
                    sed -i "s/DNS1=.*/DNS1=${currDns}/g" "${ipconfPath}${i}"
                    flag=True
                else
                    echo "DNS1=${currDns}" >>"${ipconfPath}${i}"
                fi
            fi

			if [ -z "$(cat "${ipconfPath}${i}"|grep "^DNS2=")" ]
			then
				echo "DNS2=192.168.100.22" >>"${ipconfPath}${i}"
			fi
			lateNetDev=$i
		fi
	done

    #写入 /etc/resolv.conf
    resolvDnsStatus=$(head -n 1 ${resolvDns}|grep "^nameserver.*${currDns}$")
    if [ -z "${resolvDnsStatus}" ]
    then
        sed -i "1i\nameserver ${currDns}" "${resolvDns}"
        #echo "nameserver ${dns}" >>"${resolvDns}"
    fi

    if [ -n "flag" ]
    then
        echo setDns succeed [${currDns}]
        return 0
    else
        echo setDns failed
        return 1
    fi
}

setHosts() {

    if [ -f /etc/hosts ]
    then
        hostStatus=$(cat /etc/hosts | grep "^${serverHost}$")
        if [ -z "${hostStatus}" ]
        then
            echo ${serverHost} >>/etc/hosts
        fi
    else
        echo error - 未找到hosts文件
    fi
}

setHostname() {
    #获取以e开头的网卡网卡地址
    netdev=$(ip link show|grep -E "^[0-9]+.*e.*:" |awk -F":" '{print $2}'|awk '$1=$1')
    for d in $netdev
    do
        #获取第一个符合定义(前缀包含:192.168|172.18|172.28|172.29|172.30)的网卡地址
        ipaddr=$(ip address show $d|grep -E "inet.*(192\.168|172\.18|172\.28|172\.29|172\.30)\.[0-9]+\.[0-9]+"|awk '{print $2}'|awk -F'/' '{print $1}')
        
	if [ -n "$ipaddr" ]
        then
            break
        fi
    done

    if [ -n "$ipaddr" ]
    then
        #设置hostname
	    #echo ${ipaddr//./-} >/etc/hostname
        hostnamectl set-hostname ${ipaddr//./-}.square.dns
        sleep 3
        if [ "$(cat /etc/hostname)" == "${ipaddr//./-}.square.dns" ]
        then
            echo setHostname succeed [${ipaddr//./-}.square.dns]
            return 0
        else
            echo setHostname failed
            return 1
        fi
    else
        echo setHostname failed
        return 1
    fi
}

setYum() {
    test -d "${yumPath}/backup"||mkdir -p ${yumPath}/backup
    cd ${yumPath}
    for i in $(ls *.repo)
    do
        mv -f $i backup/$i.bak
    done
    fileDownload "${repoUrl}" "${tempPath}/CentOS-Base.repo"
    if [ $? -eq 0 ]
    then
	cp -f "${tempPath}/CentOS-Base.repo" "/etc/yum.repos.d/CentOS-Base.repo"
        yum clean all
        yum makecache
        echo setYum succeed
        return 0
    else
        echo setYum failed
        return 1
    fi
}


instIvanti() {
    fileDownload "${iseccCerUrl}" "${tempPath}/isec.cer"&&fileDownload "${iseccAgentUrl}" "${tempPath}/ISecAgent-Centos7.tar"
    if [ $? -eq 0 ]
    then
        cd $tempPath
        tar -xvf ISecAgent-Centos7.tar
        bash install.sh --host ${isecHostname} --port 3121 --passphrase abcd@123 --issuer-certificate isec.cer --selected-policy Linux_Scan
        echo instIvanti done
        return 0
    else
        echo instIvanti failed
        return 1
    fi
}

instMcafree() {
    fileDownload "http://172.29.241.102/isec/isec.cer" "${tempPath}\isec.cer"
    if [ $? -eq 0 ]
    then
        cd $tempPath
        tar -xvf ISecAgent-Centos7.tar
        bash install.sh --host 172-29-241-102 --port 3121 --passphrase abcd@123 --issuer-certificate isec.cer --selected-policy Linux_Scan
        echo instMcafree done
        return $?
    else
        echo instMcafree failed
        return 1
    fi
}

#文件下载;传入参数: $1 = url, $2 = filePath
fileDownload() {
    echo "$1 >> $2"
    rm -f "$2"
    result=1
    (wget --connect-timeout 50 --no-check-certificate -O "$2" "$1" || curl --fail --connect-timeout 50 -kL "$1" > "$2")&&result=0
    if [ "${result}" = "0" ]
    then
        return 0
    else
        return 1
    fi
    return 99
}


main() {
    if [ "$(id -u)" != "0" ]
    then
        echo Error,需要root权限
        return 1
    fi

    #临时文件存放目录
    tempPath=/tmp/pushTools
    test -d ${tempPath}||mkdir -p ${tempPath}
    scriptDir="$(cd "$(dirname "$0")";pwd)"
    logPath="${tempPath}/$(basename $0).log"
    ipconfPath="/etc/sysconfig/network-scripts/ifcfg-"
    resolvDns="/etc/resolv.conf"
    yumPath="/etc/yum.repos.d"

    getEnv|tee -a $logPath
    #setDns|tee -a $logPath
    setHostname |tee -a $logPath
    setYum|tee -a $logPath
    instIvanti|tee -a $logPath
}

main
