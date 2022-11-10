#!/bin/bash

:<<NOTES

::* 系统支持(实际支持应该支持大部分deb和rpm包管理的系统): centos7 |centos8 [en_US.UTF-8 locale is not present:localedef -i en_US -f UTF-8 en_US.UTF-8]| centos 6.5 | ubuntu 20.4 | kali [en_US.UTF-8 locale is not present]
::* 前置第三方组件 curl | wget | tee
::* 2022-03-08 脚本完成
::* 2022-06-09 修复无法正确验证安装状态
::* 2022-07-22 1.修复安装状态提示不准确， 2.修复agent安装总是提示用户输入配置信息的错误，3.修复获取状态时，产品版本无法显示的问题， 4.增加对非管理员权限运行的提示

快速使用:
	修改62行开始,设置每个版本文件的下载地址,然后双击打开脚本输入 a 开始自动安装


概述:
	此脚本目的为简化用户安装时的过程,能实现一件自动化安装补丁和eset产品,以及对于已经安装的计算机自动升级或跳过,同时增加了一些排错常用的的功能,用于帮助客户快速方便的诊断问题根源。

功能:
	1.自动根据不同系统,不同系统平台,不同软件版本,来安装和升级补丁、AGENT、杀毒产品
	2.可以手动选择需要安装和卸载的产品
	3.进入和退出安全模式
	4.读取eset产品安装时,写入系统事件日志,方便出现安装错误时,定位问题
	5.读取系统状态用于判断问题
	6.可以根据需求自定义命令行参数，达到双击脚本自动安装的目的,(通过 DEFAULT_ARGS 参数实现)
	7.默认双击打开脚本会出现一个选择界面（此界面的操作会有一定的交互能力）
	8.支持命令行参数,以便预控推送时静默安装

使用方法：
	1.需要提前预设每个版本文件的下载地址或者本地的文件路径(可以使用相对路径,这样可以放到u盘里安装)
		具体是通过下载安装，或是本地文件安装，可以通过一个参数控制 absStatus=True 
	2.可以使用参数 -h | -help 来查看支持的参数
	3.如果需要实现双击自动安装,可以设置 DEFAULT_ARGS, 例如: DEFAULT_ARGS= -a -s -u , 表示自动安装补丁、agent、杀毒产品,并且会显示出安装的状态,然后停留等待
	4.
		agentVersion=9.0
		productVersion_efs=9.0
		productVersion_esets=4.5
		以上三个参数标识了最新的版本,一般版本号和安装文件的版本保持一致.
		当计算机已经存在一个杀毒软件,如果低于以上版本则会自动升级,如果高于则跳过安装,如果计算机没有安装过杀毒软件则预设版本号为0
	6. 这个参数 agentConfPath 指定的文件,来自于gpo配置文件,这个文件和agent安装程序放在同一个目录,安装的时候就可以不用手动填写证书、密码等之类的东西，可以通过eset控制台生成
	7.脚本的运行需要root 权限
	9.安装的时候脚本会自动检测需要下载的对应版本,不会多下载的,所以如果没有 内核低于 3.10 的系统,完全可以不填写 esets 的文件下载地址;这样并不会影响使用
	10.想到了再写

NOTES


scriptVersion=1.2

# ----------user var-----------------

#开启此参数，命令行指定参数和gui选择将会失效;
#相当于强制使用命令行参数；
#如果不需要保持为空即可
#使用方法 ： DEFAULT="-o --agent -l --remove" , 与正常的cmd参数保持一致
DEFAULT_ARGS=""

#日志等级 DEBUG|INFO|WARNING|ERROR
logLevel="DEBUG"

#已安装的软件版本如果小于此本版则进行覆盖安装,否则不进行安装(升级)
#版本号只计算两位，超过两位数会计算出错。
agentVersion=9.0
productVersion_efs=9.0
productVersion_esets=4.5

#如果路径为本地可访问路径则不需要下载到本地,将直接调用安装；否则会下载到临时目录在使用绝对路径方式调用
#是否为本地路径或绝对可访问的路径
#可用参数: True|False
absStatus=False
if [ "x$absStatus" != "xTrue" ]
then
    #此处设置用于下载文件的地址
    agentPath="http://files.yjyn.top:6080//Company/YCH/EEAI/ESET/CLIENT/Agent/agent-linux-x86_64_later.sh"
    agentConfPath="https://yjyn.top:1443/Company/YCH/EEAI/ESET/CLIENT/Agent/None"
    productPath_efs="http://files.yjyn.top:6080//Company/YCH/EEAI/ESET/CLIENT/Server/efs.x86_64_later.bin"
    productPath_esets="http://files.yjyn.top:6080//ESET_Date/repository/com/eset/apps/business/es/linux/v4/4.5.16.0/esets_x86_64_enu.bin"
else
    #此处设置本地文件路径
    agentPath="bin/agent-linux-x86_64_later.sh"
    agentConfPath="bin/install_config.ini"
    productPath_efs="bin/efs.x86_64_later.bin"
    productPath_esets="bin/esets_x86_64_enu.bin"
fi

#安装开始前配置使用代理服务器，主要用于本机无互联网，可以通过代理服务器进行依赖更新之用； 不代理eset产品的流量
proxyHttp="demo.yjyn.top:3128"

#efs 本地控制台密码
productPasswd="eset1234."

# ----------user var-----------------


# ----------sys var----------------
#临时文件存放目录
tempPath=/tmp/esetInstall
test -d ${tempPath}||mkdir -p ${tempPath}
scriptDir="$(cd "$(dirname "$0")";pwd)"

testLine="---------------------------------"
srcArgs=$@

if [ "${DEFAULT_ARGS}" = "" ]
then
    args=$srcArgs
else
    args=$DEFAULT_ARGS
fi

logPath="${tempPath}/$(basename $0).log"

eraDir="/opt/eset/RemoteAdministrator/Agent"
eraConfFile="/etc/opt/eset/RemoteAdministrator/Agent/config.cfg"
argsList="argsHelp argsAll argsAuto argsBefore argsAgent argsProduct argsUndoAgent argsUndoProduct argsConsole argsStatusInfo argsLog argsRemove argsGui argsUnpack argsProxy"

userID=$(id -u)

# ----------sys var-----------------


# ----------function-----------------
getCuiHelp() {
cat <<EOF

    ESET server security install script for linux

Usage: $0 [options]

  -h,  --help            Print the help message
  -a,  --auto            Auto install Agent and Product
  -g,  --agent           Install Agent
  -p,  --product         Install Product
  -b,  --before          Install old version of Product (4.5)
  -n,  --undoAgent       Uninstall Agent
  -d,  --undoProduct     Uninstall Product
  -c,  --console         Enable local webconsole
  -s,  --status          Print status
  -l,  --log             Disable log show
  -r,  --remove          Remove temp file
  -o,  --proxy           Use http proxy
  -u,  --gui             Show information As Gui

		Example: $0 -g -p --gui

			Code by jianyu.yao @ centos 7.9, 2022-03-2, kermit.yao@qq.com

EOF
    return 0
}

getGuiHelp() {
guiStatus=True
cat <<EOF
 *****************************
 *
 *  ESET 终端安全安装脚本
 *
 * a. 自动安装 Agent + 安全产品
 * g. 安装 Agent 代理
 * p. 安装安全产品
 * n. 卸载 Agent 代理
 * d. 卸载安全产品
 * c. 开启安全产品的本地控制台
 * s. 检查状态
 * h. 显示命令行帮助
 *       kermit.yao@qq.com
 *****************************
EOF

	tempFlag=false
	while read -p '你的选择? < a|g|p|n|d|c|s|h >: ' guiArgs
	do
		echo "$guiArgs" | grep -E '^(a|g|p|b|n|d|c|s|h)$' >/dev/null 2>&1 && tempFlag=true
		if [ "x$tempFlag" = "xfalse" ]
		then
            printLog $LINENO WARNING getGuiArgs "Invalid input:[${guiArgs}]"
		else
			break
		fi
	done
    if [ ! "$guiArgs" = "" ]
    then
        args=-$guiArgs
    fi
    return 0
}

#解析参数,传入参数: $1 = args
getArgs() {
argsStatus=1
    for arg in "$@"
    do
        case "$arg" in
            -h|--help) argsHelp=1;;
            -a|--auto) 
                argsAuto=1
                argsAgent=1
                argsProduct=1
                ;;
            -b|--before) argsBefore=1;;
            -g|--agent) argsAgent=1;;
            -p|--product) argsProduct=1;;
            -n|--undoAgent) argsUndoAgent=1;;
            -d|--undoProduct) argsUndoProduct=1;;
            -c|--console) argsConsole=1;;
            -s|--status) argsStatusInfo=1;;
            -l|--log) argsLog=1;;
            -r|--remove) argsRemove=1;;
            -o|--proxy) argsProxy=1;;
            -u|--gui) argsGui=1;;
            *) argsStatus=0
        esac
    done
for i in $argsList
do
    if [ "$i" = "1" ]
    then
        argsStatus=1
    fi
done

if [ $argsStatus -eq 1 ]
then
    return 0
else
    return 1
fi
}

#开启http代理
enableProxy() {
    if [ -n ${httpProxy} ]
    then
        printLog $LINENO INFO enableProxy "开启代理."
        http_proxy=${httpProxy}
        https_proxy=${httpProxy}
    else
        printLog $LINENO ERROR enableProxy "并未设置代理服务器信息."
    fi

}

#开启efs产品web控制台
enableGui() {
    if [ -f "/opt/eset/efs/sbin/setgui" ]
    then
        /opt/eset/efs/sbin/setgui -p eset1234. -r -e >>"${logPath}"
        return $?
    else
        return 1
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

#传入参数: $1 = 产品名称, $2 = 类型 [s|p]
productUninstall() {
    if [ "$2" = "s" ]
    then
        /bin/sh /opt/eset/esets/lib/pkg/preuninstall remove
        rm -rf /opt/eset/esets
    else
        ${uninstallCommand} $1
    fi
}

readUserInput()
{
	#read host and port
	tempFlag=false
	while read -p "Host name: " hostname
	do
		test -n "$hostname" >/dev/null 2>&1 && tempFlag=true
		if [ "x$tempFlag" == "xfalse" ]
		then
			echo
            printLog $LINENO WARNING readUserInput "无效输入:[内容不能为空!]"
		else
			break
		fi
	done

	tempFlag=false
	while read -p "Host port <default:2222>: " port
	do
		test -n "$port" || port='2222'
		echo "$port" | grep -E '^[0-9]{1,5}$' >/dev/null 2>&1 && tempFlag=true
		if [ "x$tempFlag" == "xfalse" ]
		then
            printLog $LINENO WARNING readUserInput "无效输入:[${port}]"
		else
			break
		fi
	done

	#read user and password
	read -p "User name <default:Administrator>: " username
	test -n "$username" || username="Administrator"
	tempFlag=false
	while read -s -p "Password: " password
	do
		test -n "$password" >/dev/null 2>&1 && tempFlag=true
		if [ "x$tempFlag" == "xfalse" ]
		then
			echo
            printLog $LINENO WARNING readUserInput "无效输入:[内容不能为空!]"
		else
			break
		fi
	done
	
	webPort="2223"

	tempArgsList="hostname port username password webPort"
	for i in $tempArgsList
	do
		test -n "${!i}" || return 9
	done
	return 0
}

#传入参数: $1 = 文件路径
getConfValue()
{
	if test -f "$1"
	then
        head -n 20 $1 | grep 'ERA_AGENT_PROPERTIES' >/dev/null 2>&1 || return 1
		localConfPath="${tempPath}/eraConfig.ini"
		grep  -v '\[ERA_AGENT_PROPERTIES\]' "$1" | sed 's/\r//' > $localConfPath
		. $localConfPath
		localCertPath="${tempPath}/localCert.cert"
		echo $P_CERT_CONTENT | base64 -d > $localCertPath
		if test -n "$P_CERT_AUTH_CONTENT"
		then
			localCaPath="${tempPath}/localCa.ca"
        	echo "$P_CERT_AUTH_CONTENT" | base64 -d > $localCaPath
		fi
	else
		return 1
	fi
}

#安装agent;传入参数: $1 = 文件路径, $2 = 类型(cert or password) 
installAgent()
{
	if [ "x$2" == "xcert" ]
	then
		/bin/sh $1 \
		--skip-license \
		--hostname "$P_HOSTNAME" \
		--port "$P_PORT" \
		--cert-path "$localCertPath" \
		--cert-password "env:P_CERT_PASSWORD"\
		--cert-password-is-base64 \
		--initial-static-group "$P_INITIAL_STATIC_GROUP" \
	   	--disable-imp-program \
		$(test -n "$localCaPath" && echo --cert-auth-path "$localCaPath")\
   		$(test -n "$P_CUSTOM_POLICY" && echo --custom-policy "$P_CUSTOM_POLICY")\
		$(test -n "$P_PROXY_HTTP_HOSTNAME" && test -n "$P_PROXY_HTTP_PORT" && echo --proxy-hostname "$P_PROXY_HTTP_HOSTNAME" --proxy-port "$P_PROXY_HTTP_PORT") 
		return $?
	else
		/bin/sh $1 \
		--skip-license \
		--hostname=$hostname \
		--port=$port \
		--webconsole-user=$username \
		--webconsole-password="pass:$password" \
		--webconsole-port=2223 \
		--cert-auto-confirm
		return $?
	fi
	return 99
}

#卸载agent
uninstallAgent()
{
    exitCode=1
    if [ -f $1 ] 
    then
    /bin/sh $1
    exitCode=$?
    fi
    return $exitCode
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
    if [ "$(echo "$sysVersion 3.10"|awk '{if($1 >= $2) print 1}')" = "1" ]
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

    releaseVersion=$(cat /etc/os-release |grep '^ID='|awk -F= '{print $2}'&&cat /etc/os-release |grep '^VERSION_ID='|awk -F= '{print $2}')
    echo 发行版本: ${releaseVersion//'"'}
    echo 内核安装信息:
    $searchCommand *kernel*
    echo "脚本参数: ${args}"
    if [ -n "${eraName}" ] && [ -n "${productName}" ]
    then
        echo "************** 软件安装正常 **************"
    else
        echo "************** 软件安装异常 **************"
    fi
}

# --------------func-------------------------

#脚本入口点
main() {
    if [ "$args" = "" ]
    then
        getGuiHelp
    fi
    if [ ! "$args" = "" ]
    then
        getArgs $args
        if [ $? != 0 ]
        then
            printLog $LINENO WARNING main "Invalid input:[${args}]"
            echo "Use [--help] to print infomation for help."
        fi
    else
        printLog $LINENO WARNING main "参数无效,退出当前脚本."
        return 99
    fi

    #关闭日志打印
    if [ "${argsLog}" = "1" ]
    then
        logLevel="FALSE"
    fi

    #打印帮助信息 
    if [ "$argsHelp" = "1" ]
    then
        printLog $LINENO INFO main "打印帮助信息."
        getCuiHelp
        exit 0
    fi

    #开启http 代理
    if [ "${argsProxy}" = "1" ]
    then
        enableProxy ${proxyHttp} | tee -a "${logPath}"
    fi

    #卸载 Agent
    if [ "$argsUndoAgent" = "1" ]
    then
        printLog $LINENO WARNING uninstallAgent "卸载 Agent."
        if [ "${userID}" = "0" ]
            then
            if [ ! -f "${eraDir}/setup/uninstall.sh" ]
            then 
                printLog $LINENO INFO uninstallAgent "Agent 未安装,无需卸载."
            else
                uninstallAgent "${eraDir}/setup/uninstall.sh"
                if [ "$?" = "0" ]
                then
                    printLog $LINENO INFO uninstallAgent "Agent 卸载成功."
                else
                    printLog $LINENO ERROR uninstallAgent "Agent 卸载失败."
                fi
            fi
        else
             printLog $LINENO ERROR uninstallAgent “你必须要以root身份运行此脚本,才能正常使用这些功能”
        fi
    fi

    #卸载 Product
    if [ "${argsUndoProduct}" = "1" ]
    then
        printLog $LINENO INFO uninstallProduct "卸载安全产品..."
        if [ "${userID}" = "0" ]
        then
            sysVersion="$(uname -r | awk -F. 'OFS="." {print $1,$2}')"
            if [ "${argsBefore}" = "1" ]
            then
                sysVersion=0
            fi
            getPackageType
            if [ "$DEB_BASED" = "1" ]
            then
                packageType="deb"
                installCommand="apt-get install -y"
                uninstallCommand="dpkg -P"

            elif [ "$RPM_BASED" = "1" ]
            then
                packageType="rpm"
                installCommand="yum install -y"
                uninstallCommand="rpm -e"
            else
                packageType="unknown"
            fi
            
            if [ "$(echo "$sysVersion 3.10"|awk '{if($1 >= $2) print 1}')" = "1" ]
            then
                installMode="p"
                getProductVersion "${packageType}" "efs"
            else
                installMode="s"
                getProductVersion  "${packageType}" "esets"
            fi
            productUninstall "efs" "${installMode}"
            if [ "$?" = "0" ]
            then
                printLog $LINENO INFO uninstallProduct "卸载安全产品成功."
            else
                printLog $LINENO INFO uninstallProduct "卸载安全产品失败."
            fi
        else
            printLog $LINENO ERROR uninstallProduct “你必须要以root身份运行此脚本,才能正常使用这些功能”
        fi
    fi

    #安装 Agent
    if [ "$argsAgent" = "1" ]
    then
        printLog $LINENO INFO agentInstall "开始处理 Agent 安装..."
        if [ "${userID}" = "0" ]
        then
            getConfEra "${eraConfFile}"
            test -z "${eraVersion}" && eraVersion=0
            tempAgentVersion="$(echo ${agentVersion} | awk -F. 'OFS="." {print $1,$2}')"
            tempEraVersion="$(echo ${eraVersion} | awk -F. 'OFS="." {print $1,$2}')"

            if [ "$(echo "$tempAgentVersion $tempEraVersion"|awk '{if($1 > $2) print 1}')" = "1" ]
            then
                if [ "$absStatus" = "True" ]
                then
                    printLog $LINENO DEBUG agentInstall "使用本地配置文件安装 Agent."
                    localAgentPath="${scriptDir}/${agentPath}"
                    localAgentConfPath="${scriptDir}/${agentConfPath}"
                else
                    printLog $LINENO INFO agentDowanload "下载 Agent 安装文件..."
                    fileDownload  "${agentPath}" "${tempPath}/agent.sh"
                    if [ "$?" = "0" ]
                    then
                        printLog $LINENO DEBUG installAgent "Agent 下载成功"
                        localAgentPath="${tempPath}/agent.sh"
                        agentDownStatus=0
                        printLog $LINENO INFO installAgent "下载 Agent 配置文件中..."
                        fileDownload "${agentConfPath}" "${tempPath}/agentConf.ini"
                        if [ "$?" = "0" ]
                        then
                            printLog $LINENO DEBUG installAgent "Agent 配置文件下载成功"
                            localAgentConfPath="${tempPath}/agentConf.ini"
                        else
                            printLog $LINENO WARNING installAgent "Agent 配置文件下载失败"
                        fi

                    else
                        printLog $LINENO ERROR installAgent "Agent 下载失败"
                    fi
                fi
            
                if [ "${agentDownStatus}" = "0" ]
                then
                    printLog $LINENO INFO installAgent "读取 Agent 配置文件"
                    echo "${localAgentConfPath}"
                    getConfValue "${localAgentConfPath}"
                    if [ "$?" = "0" ]
                    then
                        printLog $LINENO INFO installAgent "通过配置文件安装 Agent"
                        installAgent "${localAgentPath}" cert
                        if [ "$?" = "0" ]
                        then
                            printLog $LINENO INFO installAgent "Agent 安装状态是:[成功]"
                        else
                            printLog $LINENO INFO installAgent "Agent 安装状态是:[失败]"
                        fi
                    else
                        printLog $LINENO WARNING readConfiguratin "读取用户输入信息,以安装 Agent"
                        readUserInput
                        echo
                        printLog $LINENO INFO installAgent "通过用户输入参数来安装 Agent."
                        installAgent "${localAgentPath}" password
                        if [ "$?" = "0" ]
                        then
                            printLog $LINENO INFO installAgent "Agent 安装状态是:[成功]"
                        else
                            printLog $LINENO INFO installAgent "Agent 安装状态是:[失败]"
                        fi
                    fi
                fi
            else
                printLog $LINENO INFO installAgent "当前已安装的 Agent 版本大于或者等于需要安装的版本."
            fi
        else
            printLog $LINENO ERROR installAgent “你必须要以root身份运行此脚本,才能正常使用这些功能”
        fi
    fi 

    #安装 Product
    if [ "${argsProduct}" = "1" ]
    then
        printLog $LINENO INFO productInstall "开始处理安全产品安装..."
        if [ "${userID}" = "0" ]
        then
            arch=$(uname -m)
            if $(echo "$arch" | grep -E "^(x86_64|amd64)$" > /dev/null 2>&1)
            then
                sysVersion="$(uname -r | awk -F. 'OFS="." {print $1,$2}')"
                if [ "${argsBefore}" = "1" ]
                then
                    sysVersion=0
                fi

                [ "${argsBefore}" = "1" ] && sysVersion="0"

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
                if [ "$(echo "$sysVersion 3.10"|awk '{if($1 >= $2) print 1}')" = "1" ]
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

                    if [ "$(echo "${installProductVersion} ${currentProductVersion}"|awk '{if($1 > $2) print 1}')" = "1" ]
                    then

                        if [ "$absStatus" != "True" ]
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
                        else
                            localProductPath=${scriptDir}/${tempProductPath}
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
    fi

    #开启本机 web console
    if [ "${argsConsole}" = "1" ]
    then
        printLog $LINENO INFO enableGui "开启 EFS 本机控制台管理界面."
        if [ "${userID}" = "0" ]
        then
            enableGui
            if [ "$?" = "0" ]
            then
                printLog $LINENO INFO enableGui "开启 EFS 本机控制台管理界面成功."
            else
                printLog $LINENO WARNING enableGui "开启 EFS 本机控制台管理界面失败."
            fi
        else
            printLog $LINENO ERROR enableGui “你必须要以root身份运行此脚本,才能正常使用这些功能”
        fi
    fi

    #获取系统状态
    if [ "${argsStatusInfo}" = "1" ]
    then
        printLog $LINENO INFO getStatus "打印环境状态..."
        printStatus | tee -a "${logPath}"

    fi

    #移除临时文件
    if [ "${argsRemove}" = "1" ]
    then
        printLog $LINENO INFO removeTempDir "删除临时文件."
        echo "${tempPath}/*"
        test -d "${tempPath}" && [ "$(echo "${tempPath}" | awk -F/ '{print $2}')" = "tmp" ] && rm -f ${tempPath}/*
    fi

}

main
exit $?