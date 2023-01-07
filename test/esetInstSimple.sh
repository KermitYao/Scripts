#!/bin/bash

:<<NOTES
----------------

NOTES


#此处设置用于下载文件的地址
agentPath="http://192.168.30.172/agentInst.sh"
productPath_efs="http://192.168.30.172/efs.x86_64_later.bin"
productPath_esets="http://files.yjyn.top:6080//ESET_Date/repository/com/eset/apps/business/es/linux/v4/4.5.16.0/esets_x86_64_enu.bin"
httpProxy="192.168.30.172:3128"

#临时文件存放目录
tempPath=/tmp/esetInstall
logPath="${tempPath}/$(basename $0).log"
test -d ${tempPath}||mkdir -p ${tempPath}
scriptDir="$(cd "$(dirname "$0")";pwd)"
logLevel="DEBUG"
userID=$(id -u)
testLine="---------------------------------"
#eset配置文件
eraDir="/opt/eset/RemoteAdministrator/Agent"
eraConfFile="/etc/opt/eset/RemoteAdministrator/Agent/config.cfg"
argsList="argsHelp argsAll argsAuto argsBefore argsAgent argsProduct argsUndoAgent argsUndoProduct argsConsole argsStatusInfo argsLog argsRemove argsGui argsUnpack argsProxy"

#已安装的软件版本如果小于此本版则进行覆盖安装,否则不进行安装(升级)
#版本号只计算两位，超过两位数会计算出错。
agentVersion=9.0
productVersion_efs=9.0
productVersion_esets=4.5

#安装最新版本杀毒的系统列表, 从 /etc/os-release 取 NAME 和 VERSION_ID 的值成对填入下面,已逗号分隔
instLaterSysList="CentOS Linux:7, Oracle Linux Server:8.0"

#-------- function --------

#开启http代理
enableProxy() {
    if [ -n ${httpProxy} ]
    then
        printLog $LINENO INFO enableProxy "开启代理."
        export http_proxy=${httpProxy}
        export https_proxy=${httpProxy}
    else
        printLog $LINENO ERROR enableProxy "并未设置代理服务器信息."
    fi

}

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

#获取产品版本;传入参数: $1 = 包类型 $2 = 软件名称
getProductVersion() {
    if [ "$1" = "deb" ]
    then
        currentProductVersion="$(dpkg-query --showformat='${Version}' --show "$2" 2>/dev/null)"
        echo ${currentProductVersion:0:1} | grep '[0-9]' >/dev/null || currentProductVersion="0.0001"
    elif [ "$1" = "rpm" ]
    then
        currentProductVersion="$(rpm --queryformat "%{VERSION}" -q "$2" 2>/dev/null)"
        echo ${currentProductVersion:0:1} | grep '[0-9]' >/dev/null || currentProductVersion="0.0001"
    else
        return 1
    fi
    return 99
}

#获取era配置;传入参数: $1 = era配置文件路径, $2 = 安全产品配置文件路径
getConfEra() 
{
	if [ -f $1 ]
	then
		eraInstallDir=$(grep "ProgramInstallDir=" $1 2>/dev/null | awk -F= '{print $2}')
		eraName=$(grep "ProductName=" $1 2>/dev/null | awk -F= '{print $2}')
		eraVersion=$(grep "ProductVersion=" $1 2>/dev/null | awk -F= '{print $2}')
		eraLogDir=$(grep "ProgramLogsDir=" $1 2>/dev/null | awk -F= '{print $2}')
		eraRemoteHost=$(grep "<li>.*Remote host:.*</li>" ${eraLogDir}/status.html 2>/dev/null | awk -F '[:><]' '{print $8}'|sed 's/ //g')
    fi
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

#解包 efs 安装文件
unpackEfs() {
    if [ -f "$1" ]
    then
        pushd ${tempPath} >/dev/null
        printLog $LINENO INFO unpackEfsProduct "解包 efs 安装文件..."
        packageName=$(/bin/sh "$1" -n -y | grep -E "^efs-.*\.${packageType}")
        popd >null
        return 0
    else
        return 1
    fi
    return 99

}

#安全产品安装;传入参数: $1 = 文件路径, $2 = 类型([s|p]) 
productInstall() {
    getPackageType
    if [ "$DEB_BASED" = "1" ]
    then
        packageType="deb"
        installCommand="apt-get install -y"
        uninstallCommand="dpkg -r"

    elif [ "$RPM_BASED" = "1" ]
    then
        packageType="rpm"
        installCommand="yum install -y"
        uninstallCommand="rpm -e"
    else
        packageType="unknown"
    fi

    if [ "$2" = "s" ]
    then
        $installCommand glibc.i686 ed
        sh "$1" --skip-license
        return $?
    else
        unpackEfs "$1"
        
        if [ -f "${tempPath}/${packageName}" ]
        then
            $installCommand ${tempPath}/${packageName}
            return $?
        else
            return 1
        fi
    fi
    return 99
}

getProductType() {
	productType=esets
	if [ -f /etc/os-release ]
	then
		. /etc/os-release
		currentVersion="$NAME:$VERSION_ID"
	else
		currentVersion="!@#$%)(*&^"
	fi

	for i in {1..100}
	do
		s=$(echo $instLaterSysList|cut -d"," -f$i)
		if [ -z "$s" ]
		then
			break
		fi
		matchResult=$(echo $s|grep "$currentVersion")
		if [ -n "$matchResult" ]
		then
			productType=efs
			break
		fi
	done
    echo In getPRoductType, matchResult:$matchResult
}

printStatus() {
    getPackageType
    if [ "$DEB_BASED" = "1" ]
    then
        packageType="deb"
        installCommand="apt-get install -y"
        uninstallCommand="dpkg -r"
        searchCommand="dpkg -l"
    elif [ "$RPM_BASED" = "1" ]
    then
        packageType="rpm"
        installCommand="yum install -y"
        uninstallCommand="rpm -e"
        searchCommand="rpm -qa"
    else
        packageType="unknown"
    fi

    getConfEra ${eraConfFile}
    echo "Agent name: ${eraName}"
    echo "Agent version: ${eraVersion}"
    echo "Agent directory: ${eraInstallDir}"
    echo "Agent hostname: ${eraRemoteHost}"
    sysVersion="$(uname -r | awk -F. 'OFS="." {print $1,$2}')"
    tmpSysVersion=

    #获取需要安装的产品类型: esets|efs
    getProductType
    if [ "$productType" = "efs" ]
    then
        if [ -f  "/opt/eset/efs/sbin/startd" ]
        then
            getProductVersion "${packageType}" "efs"
            productName="efs"
            productDirectory="/opt/eset/efs"
            currentProductVersion="$(echo "${currentProductVersion}" | awk -F. 'OFS="." {print $1,$2}')"
        fi
    else
        if [ -f  "/opt/eset/esets/sbin/esets_daemon" ]
        then
            productName="esets"
            productDirectory="/opt/eset/eset"
            currentProductVersion="4.5"
        fi
    fi
    
    echo ${testLine}
    echo "Product name: ${productName}"
    echo "Product version: ${currentProductVersion}"
    echo "Prodcut directory: ${productDirectory}"

    echo ${testLine}
    echo "包管理: ${packageType}"
    echo "内核信息: $(uname -a)"
	if [ -f /etc/os-release ]
	then
		releaseVersion=$(cat /etc/os-release |grep '^ID='|awk -F= '{print $2}'&&cat /etc/os-release |grep '^VERSION_ID='|awk -F= '{print $2}')
	fi
    echo 发行版本: ${releaseVersion//'"'}
    echo 内核安装信息:
    $searchCommand *kernel*
    if [ -n "${eraName}" ] && [ -n "${productName}" ]
    then
        echo "************** 软件安装正常 **************"
    else
        echo "************** 软件安装异常 **************"
    fi
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

#-------- function --------

#脚本入口点
main() {

    #开启http 代理
	enableProxy

    #安装 Agent
	printLog $LINENO INFO agentInstall "开始安装 agent..."

    printLog $LINENO INFO agentInstall "开始下载 agent 安装文件: [${agentPath}]"
    fileDownload  "${agentPath}" "${tempPath}/agent.sh"
    if [ "$?" = "0" ]
    then
        printLog $LINENO DEBUG agentDowanload "agent下载成功"
        localAgentPath="${tempPath}/agent.sh"
    else
        printLog $LINENO ERROR agentDowanload "agent下载失败."
    fi

	/bin/bash ${localAgentPath}
	if [ ! "$?" = "0" ]
    then
		printLog $LINENO ERROR agentInstall "agent 安装失败."
	fi

    #安装 Product

	printLog $LINENO INFO productInstall "开始处理安全产品安装..."
	if [ "${userID}" = "0" ]
	then
		#判断平台是否支持
		arch=$(uname -m)
		if $(echo "$arch" | grep -E "^(x86_64|amd64)$" > /dev/null 2>&1)
		then

			#获取包类型
			getPackageType
			if [ "$DEB_BASED" = "1" ]
			then
				packageType="deb"
				installCommand="apt-get install -y"
				uninstallCommand="dpkg -r"

			elif [ "$RPM_BASED" = "1" ]
			then
				packageType="rpm"
				installCommand="yum install -y"
				uninstallCommand="rpm -e"
			else
				packageType="unknown"
			fi

			#获取需要安装的产品类型: esets|efs
			getProductType
			if [ "$productType" = "efs" ]
			then
				tempProductPath=${productPath_efs}
				installMode="p"
				installProductVersion="$(echo "${productVersion_efs}" | awk -F. 'OFS="." {print $1,$2}')"
				getProductVersion ${packageType} efs
				currentProductVersion="$(echo "${currentProductVersion}" | awk -F. 'OFS="." {print $1,$2}')"
			else
				tempProductPath=${productPath_esets}
				installMode="s"
				installProductVersion="$(echo "${productVersion_esets}" | awk -F. 'OFS="." {print $1,$2}')"
				getProductVersion  ${packageType} esets
				currentProductVersion="$(echo "${currentProductVersion}" | awk -F. 'OFS="." {print $1,$2}')"
				
			fi

			test -z "${installProductVersion}" && installProductVersion=0
			if [ "${RPM_BASED}${DEB_BASED}" != "00" ]
			then 
				#判断是否已经安装
				if [ "$(echo "${installProductVersion} ${currentProductVersion}"|awk '{if($1 > $2) print 1}')" = "1" ]
				then
					printLog $LINENO INFO productDowanload "开始下载安全产品安装文件: [${tempProductPath}]"
					fileDownload  "${tempProductPath}" "${tempPath}/product.bin"
					if [ "$?" = "0" ]
					then
						printLog $LINENO DEBUG productDowanload "安全产品下载成功"
						localProductPath="${tempPath}/product.bin"
					else
						printLog $LINENO ERROR productDowanload "安全产品下载失败."
					fi

					if [ -s "${localProductPath}" ]
					then
						printLog $LINENO INFO installProduct "开始安装安全产品..."
						productInstall "${localProductPath}" "${installMode}"
						if [ "$?" = "0" ]
						then
							printLog $LINENO INFO installProduct "安全产品安装成功."
						else
							printLog $LINENO ERROR installProduct "安全产品安装失败."
						fi
					else
						printLog $LINENO WARNING installProduct "未找到安装文件."
					fi
				else
					printLog $LINENO INFO installProduct "当前已安装的安全产品版本大于或者等于需要安装的版本."
				fi
			else
				printLog $LINENO WARNING installProduct "无法确定当前系统的包管理工具."
			fi
		else
			printLog $LINENO WARNING installProduct "此脚本不支持当前系统平台: $arch ."
		fi
	else
		printLog $LINENO ERROR installProduct “你必须要以root身份运行此脚本,才能正常使用这些功能”
	fi

    #移除临时文件
    printLog $LINENO INFO removeTempDir "删除临时文件."
    echo "${tempPath}/*"
    test -d "${tempPath}" && [ "$(echo "${tempPath}" | awk -F/ '{print $2}')" = "tmp" ] && rm -f ${tempPath}/*

    #获取系统状态
    printLog $LINENO INFO getStatus "打印环境状态..."
    printStatus
}

main
exit $?