#!/bin/bash

:<<NOTES

::* 系统支持(理论上和官方EPP支持一致;但是亦列出兼容系统. 部分功能需要已经安装EPP方可使用.): centos7 | centos8 | rocky linux 8.2
::* 前置第三方组件 curl | wget | tee

::* v1.0.1_20230507_beta
    1.初始脚本代码完成

::*********************************************************


快速使用:
	eppServerTools.sh -h

概述:
	此脚本用于简化360EPP控制台的安装升级以及维护操作

功能:
	1.自动下载安装和升级文件
	2.自动升级一个版本，到最新，升级到指定版本
	3.自动备份还原数据库
    4.自动修改管理员密码
    5.自动修改计算机ip地址
    6.进入常用容器内部
    7.清理安装环境，用于重新安装
	8.读取系统状态用于判断问题
	9.可以根据需求自定义命令行参数，达到脚本自动运行安装的目的,(通过 DEFAULT_ARGS 参数实现)
	10.默认不加参数打开脚本会出现一个选择界面（此界面的操作会有一定的交互能力）
	11.支持命令行参数,以便远程批量推送时静默安装
    12.支持代理下载
使用方法：
	1.需要提前预设每个版本文件的下载地址或者本地的文件路径(可以使用相对路径,这样可以放到u盘里安装)
		具体是通过下载安装，或是本地文件安装，可以通过一个参数控制 absStatus=True 
	2.可以使用参数 -h | -help 来查看支持的参数
	3.如果需要实现自动安装,可以设置 DEFAULT_ARGS, 例如: DEFAULT_ARGS= -a -s -u , 表示自动安装agent、杀毒产品,并且会显示出安装的状态,然后停留等待
	4.脚本的运行需要root 权限



---

docker exec -i cactus-web mysqldump --single-transaction ${ignore_tables} -h${dbHost} -ucactus -p${dbpwd} cactus >cactus_bak_${bak_time}.sql

docker exec -i cactus-web mysql --default-character-set=utf8 -h${dbHost} -ucactus -p${dbpwd}  cactus < $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql


cat /data/docker/cactus-web/system/safe-cactus/application/config/production/conf/db.json


$(echo $(cat /data/docker/cactus-web/system/safe-cactus/application/config/production/conf/db.json) | sed "s# ##g"  | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"ip":".*?"' | awk -F '"' '{print $4}')


docker exec -i cactus-web mysql --default-character-set=utf8 -hmysql -ucactus -pfca577c33ad6da63  cactus < /data/docker/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql


docker exec -i cactus-web mysql -hmysql -ucactus -pfca577c33ad6da63  cactus < /data/docker/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql


docker image rm  $(docker images|awk  '{printf " %s",$3}')  #清理docker

通过检测网页自动下载升级版本




1.自动下载安装包 并获取 code码

2.自动下载升级包 & 自动升级 & 自动获取code 码

3.一些常用的状态检查获取

4.自动备份数据库, 自动还原数据库。

5.自动获取版本

6.自动进入数据库命令行

7.自动修改计算机ip地址

8.自动修改管理员密码

9.自动清理环境，完全卸载epp控制台





---


NOTES

scriptVersion=1.0.1

# ----------user var-----------------

#开启此参数，命令行指定参数和gui选择将会失效;
#相当于强制使用命令行参数；
#如果不需要保持为空即可
#使用方法 ： DEFAULT="-o --agent -l --remove" , 与正常的cmd参数保持一致
DEFAULT_ARGS=""

#日志等级 DEBUG|INFO|WARNING|ERROR
logLevel="DEBUG"

#安装文件下载目录
instUrlPath=https://yjyn.top:1443/Company/YCH/360/360EPP/360EPP_install/

#升级文件下载目录
updateUrlPath=https://yjyn.top:1443/Company/YCH/360/360EPP/360EPP_update/

codeInfoName="code.txt"


# ----------user var-----------------


# ----------sys var----------------
#临时文件存放目录
tempPath=/tmp/eppServerTools.sh
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

composeFile="/home/s/lcsd/docker-compose.yml"
instDir="/data/"


argsList="argHelp argStatusInfo argLog argClean argProxy argProxyValue argDown  argInstDownValue argUpgrade argUpgradeDownValue argBackupData argBackupDataValue argRestoreData argRestoreDataValue argModifyIp argModifyIpValue argSetpw argSetpwValue"

#argInstPkgDown=late argInst=list argInst=versionNumber
#argUpdatePkgDown=late argInst=list argInst=versionNumber
#argAutoUpdate=late argInst=list argInst=versionNumber
#argBackupDataValue=epp_server_mysql_backup_time.sql argBackupDataValue=自定义
#argRestoreDataValue=自定义
#安装最新版本杀毒的系统列表, 从 /etc/os-release 取 NAME 和 VERSION_ID 的值成对填入下面,以逗号分隔

userID=$(id -u)

# ----------sys var-----------------


# ----------function-----------------

getGuiHelp() {
guiStatus=True
cat <<EOF
 *****************************
 *
 *  ESET 终端安全安装脚本
 *
 * d. 下载最新安装包
 * u. 自动升级到最新版本
 * b. 备份数据库到当前目录
 * c. 清理环境(用于重新安装EPP)
 * s. 检查状态
 * h. 显示命令行帮助
 *       kermit.yao@qq.com
 *****************************
EOF

	tempFlag=false
	while read -p '你的选择? < d|u|b|c|s|h >: ' guiArgs
	do
		echo "$guiArgs" | grep -E '^(d|u|b|c|s|h)$' >/dev/null 2>&1 && tempFlag=true
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


getCuiHelp() {
cat <<EOF

    ESET server security install script for linux

Usage: $0 [options]

  -h,  --help                   打印帮助信息
  -d,  --download [l|ver]       下载安装或升级文件,可以指定l来获取版本列表,指定一个版本进行下载
  -u,  --upgrade [u|a|ver]      升级版本,u升级一个版本,a自动升级到最新,ver可以指定一个版本,将自动升级到对应的版本
  -b,  --backup [file]          备份数据库,如果未指定路径,将在当前目录下生成
  -r,  --restore file           还原数据库,通过指定一个文件路径来还原数据库
  -c,  --clean                  清理安装环境(卸载所有已安装的EPP组件)
  -m,  --modify                 修改系统EPPip地址
  -s,  --status                 打印状态信息
  -l,  --log                    关闭日志显示
  -p,  --proxy ip:port          指定一个代理用于网络中转
  --setpw [password]            强制修改管理员密码
  -g,  --gui                    脚本不会自动推出

		Example: $0 -d l -b /tmp/epp_20230604.sql -s -gui -p "192.168.6.99:3128"

			Code by kermit.yao @ centos 7.6, 2023-06-4, kermit.yao@qq.com

EOF
    return 0
}



#检查参数是否正确, $1 = 检查类型,f = file, s = string; $2 = 参数; $3 = 参数的值; $4 = 匹配字符;$5 = 默认值
checkArgs() {
    echo $1 - $2 - $3 - $4 - $5
    #f = files, s = string
    if [ -z "$5" ]
    then
        if [  -z "$3" ]
        then
            echo 参数 [$2] 必须指定一个参数.
            return 1
        fi

        echo "$3" | grep "^-">/dev/null&& echo 参数 [$2] 必须指定一个正确的参数.&&return 1

	
        if [ "$1" = "f" ]
        then
            if [ ! -e "$3" ]
            then
                echo 参数 [$2] 的值 [$3] 出现错误,路径不存在.
                return 1
            fi
        else
	    tmp=$(echo "$4"|grep "$3">/dev/null&&echo True)
            if [ ! "${tmp}" == "True" ]
            then
                echo 参数 [$2] 的值 [$3] 出现错误,无法匹配有效参数.
                return 1
            fi
 	    tmp=
         fi
        return 0
    else
        if [  -z "$3" ]
        then
            return 98
        fi

        echo "$3" | grep "^-">/dev/null&&return 98

	
        if [ "$1" = "f" ]
        then
            if [ ! -e "$3" ]
            then
                echo 参数 [$2] 的值 [$3] 出现错误,路径不存在.
                return 1
            fi
        else
	    tmp=$(echo "$4"|grep "$3">/dev/null&&echo True)
            if [ ! "${tmp}" == "True" ]
            then
                echo 参数 [$2] 的值 [$3] 出现错误,无法匹配有效参数.
                return 1
            fi
 	    tmp=
         fi
    fi
    return 0
}


#解析参数,传入参数: $1 = args
getArgs() {
    argsStatus=1
    while test $# != 0
    do
        case "$1" in
            -h|--help) argsHelp=1;;
            -d|--download) 
                argDown=1
		argInstDownValueDefault=l
                shift
                checkArgs s -d "$1" "l" "$argInstDownValueDefault"
                if [ $? = 0 ]
                then
                    argInstDownValue=$1
                fi

                if [ $? = 98 ]
                then
                    argInstDownValue=$argInstDownValueDefault
                    shift $(($#+2))
                fi
                ;;
            -u|--upgrade)
                argUpgrade=1
                shift
                argUpgradeDownValueDefault=l
                checkArgs s -u "$1" "$1" "argUpgradeDownValueDefault"
                if [ $? = 0 ]
                then
                    argUpgradeDownValue=$1
                fi
                
                if [ $? = 98 ]
                then
                    argUpgradeDownValueDefault=$argUpgradeDownValueDefault
                    shift $(($#+2))
                fi
                ;;

            -b|--backup)
                argBackupData=1
                shift
                argBackupDataValueDefault=
                checkArgs f -b "$(dirname $1)" "$1" "$argBackupDataValueDefault"
                if [ $? = 0 ]
                then
                    argBackupDataValue=$1
                fi

                if [ $? = 98 ]
                then
                    argBackupDataValue=$argBackupDataValueDefault
                    shift $(($#+2))
                fi
		;;
            -r|--restore)
                argRestoreData=1
                shift
                checkArgs f -b "$1"
                if [ $? = 0 ]
                then
                    argRestoreDataValue=$1
                fi
                ;;
            -m|--modify)
                argModifyIp=1
                shift
                checkArgs s -m "$1" "$1"
                if [ $? = 0 ]
                then
                    argModifyIpValue=$1
                fi
            	;;
            -c|--clean) argClean=1;;
            -s|--status) argStatusInfo=1;;
            -l|--log) argLog=1;;
            -p|--proxy)
                argProxy=1
                shift
                argProxyValueDefault=
                checkArgs s -p "$1" "$1" "$argProxyValueDefault"
                if [ $? = 0 ]
                then
                    argProxyValue=$1
                fi
                
                if [ $? = 98 ]
                then
                   argProxyValue=$argProxyValueDefault
                   shift $(($#+2))
                fi
                ;;
            --setpw)
                argSetpw=1
                shift
                argSetpwValueDefault="360Epp1234.default"
                checkArgs s --setpw "$1" "$1" "$argSetpwValueDefault"
		res=$?
                if [ $res = 0 ]
                then
                    argSetpwValue=$1
                fi

                if [ $res = 98 ]
                then
                   argSetpwValue="${argSetpwValueDefault}"
                   shift $(($#+2))
                fi
                ;;
           *) argsStatus=0
        esac
        shift
    done

    for i in $argsList
    do
	tmp=$(eval echo \${$i})
        if [ ! -z "$tmp" ]
        then
            argsStatus=1
            echo $i = ${tmp}
        fi
        tmp=
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
    if [ -n ${argProxyValue} ]
    then
        printLog $LINENO INFO enableProxy "开启代理."
        export http_proxy=${argProxyValue}
        export https_proxy=${argProxyValue}
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

    if [ "$2" = "efs" ]
    then
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
    else
        if [ -f  "/opt/eset/esets/sbin/esets_daemon" ]
        then
            currentProductVersion="4.5"
        fi
    fi
}

getInstStatus() {
    instStatus=True
    command -v docker>/dev/null||instStatus=False
    command -v docker-compose>/dev/null||instStatus=False
    test -f /data/docker/cactus-web/system/version||instStatus=False
    filterContainerList="cactus-nginx lcsd-nginx-1 cactus-web mysql cactus-newtransserver"
    nowContainerList=$(docker inspect -f {{.Name}} $(docker ps|awk '{print $1}'|grep -v CONTAINER))
    for fc in $filterContainerList
    do
        flag=1
        for nc in $nowContainerList
        do
            if [ "/$fc" = "$nc" ]
            then
                #echo match - $nc
                flag=0
            fi
        done
        if [ "$flag" = "1" ]
        then
            break
        fi
    done
    
    return $flag
}

#修改EPP管理员密码
setpw() {
    getInstStatus
    if [ $? = 0 ]
    then
        docker exec -it cactus-web php /home/q/system/safe-cactus/application/script/ResetPassword.php
	return $?
    fi

    return 1
}

#文件下载;传入参数: $1 = url, $2 = filePath
fileDownload() {
    rm -f "$2"
    result=1
    (wget --connect-timeout 100 --no-check-certificate -O "$2" "$1" || curl --fail --connect-timeout 100 -k "$1" > "$2")&&result=0

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

    #获取需要安装的产品类型: esets|efs
    getProductType
    #如果 -b 参数被指定,则安装旧版本.
    if [ "${argsBefore}" = "1" ]
    then
        productType=esets
    fi

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
    echo hostname: $(hostname)
    echo ip list: $(hostname -I)
    echo "包管理: ${packageType}"
    echo "内核信息: $(uname -a)"

	if [ -f /etc/os-release ]
	then
		releaseVersion=$(cat /etc/os-release |grep '^ID='|awk -F= '{print $2}'&&cat /etc/os-release |grep '^VERSION_ID='|awk -F= '{print $2}')
	fi
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

    getInstStatus
    echo is - $?
    exit 0
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
        enableProxy ${httpProxy}
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

    if [ $argSetpw = 1 ]
    then
        setpw
        if [ $? = 0 ]
        then
            printLog $LINENO INFO setPassword “已成功重置密码”
        else
            printLog $LINENO WARNING setPassword “重置密码失败.”
        fi
    fi

    #移除临时文件
    if [ "${argsRemove}" = "1" ]
    then
        printLog $LINENO INFO removeTempDir "删除临时文件."
        echo "${tempPath}/*"
        test -d "${tempPath}" && [ "$(echo "${tempPath}" | awk -F/ '{print $2}')" = "tmp" ] && rm -f ${tempPath}/*.{ini,sh,deb,rpm,ca,cert,bin}
    fi

    #获取系统状态
    if [ "${argsStatusInfo}" = "1" ]
    then
        printLog $LINENO INFO getStatus "打印环境状态..."
        printStatus | tee -a "${logPath}"
    fi
}

main
exit $?






















#!/bin/bash

check_update(){
    echo "开始检测升级环境:"
    upUser=$(whoami)
    if [ "$upUser" != "root" ]
    then
        echo "upgrade user not root!"
        return 1
    fi

    arch=$(hostnamectl | grep 'Kernel' | grep 'x86_64')
    if [ "$arch" = "" ]
    then
        echo "arch: $arch not supported!"
        return 1
    fi

    compose_file=/home/s/lcsd/docker-compose.yml
    has_mysql=$(grep 'cactus-mysql' ${compose_file} | grep -v '#' || echo "false")
    has_web=$(grep 'cactus-web' ${compose_file} | grep -v '#' || echo "false")
    if [[ "$has_mysql" != "false" && "$has_web" = "false" ]]
    then
        echo "================================="
        echo " => 注意: 当前升级分离部署mysql服务!"
        echo "================================="
    fi

    if [[ "$has_mysql" = "false" && "$has_web" != "false" ]]
    then
        echo "================================="
        echo " => 注意: 当前升级分离部署web服务!"
        echo "================================="
    fi

    return 0
}

before_update(){
    script_dir=$tmp_dir/safe-cactus/ext/cactus-web/script

    if [ ! -d $script_dir ]
    then
        return 0
    fi

    is_before=$(ls $script_dir | grep '.sh' | grep 'before_db_' || echo "false")
    if [ "$is_before" = "false" ]
    then
        return 0
    fi

    compose_file=/home/s/lcsd/docker-compose.yml
    has_mysql=$(grep 'cactus-mysql' ${compose_file} | grep -v '#' || echo "false")
    if [ "$has_mysql" = "false" ]
    then
        return 0
    fi

    echo "前置服务升级:"
    export tmp_dir=$tmp_dir
    if [ -d $script_dir ]
    then
        for sh_script in $(ls $script_dir | grep '.sh' | grep 'before_db_')
        do
            echo " run $sh_script :"
            /bin/sh ${script_dir}/${sh_script} gotoend
            if [ "$?" != "0" ]
            then
                echo "    error: $? ... "
            fi
            /bin/rm -rf ${script_dir}/${sh_script}
            echo "    ok..."
        done
    fi

    return 0
}

splic_update(){
    echo "提取升级文件:"
    ARCHIVE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0;}' $0)
    mkdir -p $tmp_dir
    tail -n+$ARCHIVE $0 | tar --no-same-owner -C $tmp_dir -xz
    if [ "$?" != "0" ]
    then
        echo "提取升级文件失败!"
        rm -rf $tmp_dir
        return 1
    fi

    before_update
    if [ "$?" = "1" ]
    then
        return 1
    fi

    return 0
}

stop_super(){
    while true
    do
        dk_status=$(docker exec -i cactus-web supervisorctl status)
        web_status=$(echo $dk_status | grep 'Error response from daemon')
        is_start=$(echo $dk_status | grep 'supervisor.sock')
        if [[ "$web_status" = "" && "$is_start" = "" ]]
        then
            break
        fi
        sleep 10
    done
    docker exec -i cactus-web /usr/bin/supervisorctl stop all
    
    return 0
}

end_update(){
    compose_file=/home/s/lcsd/docker-compose.yml
    echo "===================================================="
    echo "重启epp服务[1-3]:"
    echo " 1 - 停止应用docker服务:"
    docker-compose -f ${compose_file} down
    echo "----------------------------------------------------"
    echo " 2 - 重启宿主机docker:"
    systemctl restart docker
    if [ "$?" = "0" ]
    then
        echo " 2 - 重启宿主机docker完成"
        echo "----------------------------------------------------"
        echo " 3 - 重新启动应用docker服务:"
        docker-compose -f ${compose_file} up -d
        echo " 3 - 重启完成"
        echo "----------------------------------------------------"
        sleep 10

    else
        echo "重启宿主机docker失败，请手动依次执行下列命令进行重启:"
        echo "systemctl restart docker"
        echo "docker-compose -f ${compose_file} up -d"
    fi

    echo "升级完成"
    return 0
}

back_db(){
    dbHost=$1
    dbpwd=$2
    bak_time=$3

    if [[ "$dbHost" = "" || "$dbpwd" = "" ]]
    then
        echo "备份DB参数错误!"
        return 1
    fi

    ignore_tables="--ignore-table=cactus.log_report_kb_leak_statistics --ignore-table=cactus.log_report_kb_detail_statistics --ignore-table=cactus.360exthost_quarant_log"
    ignore_tables="${ignore_tables} --ignore-table=cactus.360exthost_360sdmgr_setting_log --ignore-table=cactus.kb_total_history --ignore-table=cactus.monitor_info"
    ignore_tables="${ignore_tables} --ignore-table=cactus.360exthost_pluginmgr_log --ignore-table=cactus.360edr_hotpatch_log --ignore-table=cactus.360leakfix_system_log"
    ignore_tables="${ignore_tables} --ignore-table=cactus.360leakfix_system --ignore-table=cactus.360exthost_softmgr --ignore-table=cactus.360exthost_softmgr_log"

    if [ ! -f cactus_bak_${bak_time}.sql ]
    then
        echo "备份mysql数据库..."
        docker exec -i cactus-web mysqldump --single-transaction ${ignore_tables} -h${dbHost} -ucactus -p${dbpwd} cactus >cactus_bak_${bak_time}.sql
    fi

    return 0
}

main()
{
    echo "===================================================="
    echo "开始升级360EPP管控中心"
    echo "----------------------------------------------------"
    check_update
    if [ "$?" = "1" ]
    then
        exit 1
    fi

    bak_time=$(date +%Y%m%d%H%M%S)
    export bak_time=$bak_time
    tmp_dir=/opt/epp-up-$(date +%Y%m%d%H%M%S)
    compose_file=/home/s/lcsd/docker-compose.yml
    msecret=n
    has_mysql=$(grep 'cactus-mysql' ${compose_file} | grep -v '#' || echo "false")
    if [[ "$has_mysql" != "false" && ! -d /data/docker/cactus-web ]]
    then
        # 分离部署的mysql
        splic_update
        echo "清理临时升级文件:"
        rm -rf $tmp_dir
        end_update
        exit 0
    fi

    if [ ! -f /data/docker/cactus-web/system/safe-cactus/version ]
    then
        echo "upgrade version file not found!"
        exit 1
    fi

    script_name=$0
    upver=$(echo $script_name | awk -F 'updatepkg' '{print $NF}' | tr -cd "[0-9+].[0-9+].[0-9+].[0-9+]\-[0-9+].[0-9+].[0-9+].[0-9+]" | sed -r 's#^\.+##' | sed -r 's#\.+$##')
    start_version=$(echo $upver | awk -F '-' '{print $1}')
    end_version=$(echo $upver | awk -F '-' '{print $2}')
    now_version=$(grep 'sv=' /data/docker/cactus-web/system/safe-cactus/version  | sed "s#sv=##" | tr -cd "[0-9+].[0-9+].[0-9+].[0-9+]\-[0-9+].[0-9+].[0-9+].[0-9+]")
    if [[ "$now_version" = "" || "$start_version" = "" || "$end_version" = "" ]]
    then
        echo "upgrade version not found!"
        exit 1
    fi
    is_newnac=$(echo "$end_version 10.0.0.06200" | tr " " "\n" | sort -rV | head -n 1 | grep "$end_version" || echo 'false')
    echo "升级从 $start_version 到 $end_version, 当前版本: $now_version"

    min_version=$(echo "$start_version $now_version" | tr " " "\n" | sort -V | head -n 1)
    max_version=$(echo "$end_version $now_version" | tr " " "\n" | sort -rV | head -n 1)
    if [[ "$start_version" != "$now_version" && "$end_version" != "$now_version" ]]
    then
        if [[ "$min_version" = "$now_version" || "$now_version" = "$max_version" ]]
        then
            echo "not supported upgrade version: $now_version"
            exit 1
        fi
    fi
    echo "----------------------------------------------------"
    echo "环境检测完成, 提取升级文件和升级授权文件, 请稍等..."

    base_dir=/data/docker
    mkdir -p $tmp_dir
    ARCHIVE=$(awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0;}' $0)
    tail -n+$ARCHIVE $0 | tar --no-same-owner -C $tmp_dir -xz
    if [ "$?" != "0" ]
    then
        echo "提取升级文件失败!"
        rm -rf $tmp_dir
        exit 1
    fi

    if [ -d $tmp_dir/safe-cactus/ext/eppenv ]
    then
        sn=$(cat $tmp_dir/safe-cactus/ext/eppenv/README)
        echo "1.请输入SN号为: $sn 的安装授权码:"
        while true
        do
            read -r code
            dd if=$tmp_dir/safe-cactus/ext/eppenv/${sn}.sec |openssl enc -aes-256-cbc -d -k ${code} -md md5 |tar zxf - | echo "0"
            if [[ ! -f eppenv ]]
            then
                echo "EPP [SN: ${sn}] 授权码错误，请重新输入:"
            else
                echo "提取授权文件完成, 升级授权完成..."
                break
            fi
        done
        mv eppenv $tmp_dir/safe-cactus/ext/eppenv/
    fi

    echo "----------------------------------------------------"
    echo "提取服务配置:"
    dbpwd=""
    dbHost=""
    server_ip=""
    cdb=$base_dir/cactus-web/system/safe-cactus/application/config/production/conf/db.json
    if [ -f $cdb ]
    then
        dbpwd=$(echo $(cat cat /data/docker/cactus-web/system/safe-cactus/application/config/production/conf/db.json) | sed "s# ##g" | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}'| grep -Po '"password":".*?"'| awk -F '"' '{print $4}')
        dbHost=$(echo $(cat $cdb) | sed "s# ##g"  | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"ip":".*?"' | awk -F '"' '{print $4}')
        server_ip=$(echo $(cat $cdb) | sed "s# ##g" | grep -Po '"local_server":".*?"' | awk -F '"' '{print $4}' )
    fi
cat /data/docker/cactus-web/system/safe-cactus/application/config/production/conf/db.json
    if [ "$dbpwd" = "" ]
    then
        dbpwd="3fed7751744b8b59"
    fi

    if [ "$dbHost" = "" ]
    then
        dbHost="mysql"
    fi

    if [[ "$server_ip" = "" && -f $base_dir/cascade-server/application-test.yml ]]
    then
        server_ip=$(cat $base_dir/cascade-server/application-test.yml | grep "current_ip" | sed "s# ##g" | awk -F ':' '{print $2}')
    fi

    if [ "$server_ip" = "" ]
    then
        server_ip=$(docker exec -i cactus-web mysql -h${dbHost} -ucactus -p${dbpwd} -e "select value from cactus.setting where name='msgsrvip' limit 1"| grep -v Warn | grep -v grep | grep ':'|awk '{print $2}'|awk -F':' '{print $1}')
        if [ "$?" != "0" ]
        then
            echo "[ERROR] mysql -h${dbHost} -ucactus -p${dbpwd} connect mysql failed, please check mysql health and network!"
            exit 1
        fi
    fi
    echo "提取配置完成, 当前服务器IP: $server_ip"
    echo $server_ip > server_ip.log
    is_local_mysql=$(grep 'image' ${compose_file} | grep 'mysql' | grep -v '#' || echo 0 )

    #if [ -f $base_dir/cactus-web/system/safe-cactus/application/script/sh/Migrate.sh ]
    #then
    #    back_db "$dbHost" $dbpwd "$bak_time"
    #    echo "1.2 安装 migrate 记录..."
    #    docker exec -i cactus-web sh /home/q/system/safe-cactus/application/script/sh/Migrate.sh install
    #fi

    before_update

    echo "----------------------------------------------------"
    echo "停止cactus-web容器中 supervisor 进程:"
    stop_super

    echo "----------------------------------------------------"
    bak_dir=$base_dir/cactus-web/system/safe-cactus-$bak_time
    echo "备份safe-cactus: $bak_dir"
    mv $base_dir/cactus-web/system/safe-cactus $bak_dir
    echo "备份safe-cactus 完成, 准备升级文件"

    mv $tmp_dir/safe-cactus $base_dir/cactus-web/system/
    rm -rf $tmp_dir
    echo "升级文件准备完成, 开始升级:"

    if [ -f $base_dir/cactus-web/system/safe-cactus/ext/eppenv/eppenv ]
    then
        echo "升级运行授权文件..."
        cp $base_dir/cactus-web/system/eppenv $base_dir/cactus-web/system/eppenv-$bak_time
        /bin/cp $base_dir/cactus-web/system/safe-cactus/ext/eppenv/eppenv $base_dir/cactus-web/system/
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql ]
    then
        back_db "$dbHost" $dbpwd "$bak_time"

        echo "开始升级mysql数据库:"
        is_sign=$(grep '__HOST_IP__' $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql| grep -v grep)
        if [ "$is_sign" != "" ]
        then
            sign_salt=$(echo "$(date +%s%N)85$RANDOM"  | md5sum | cut -c 1-32)
            key_salt=$(echo "$(date +%s%N)69$RANDOM"  | md5sum | cut -c 1-32)
            cnd_salt=$(echo "$(date +%s%N)cdn87$RANDOM"  | md5sum | cut -c 1-32)
            sed -i "s/__C_SIGN_SALT__/$sign_salt/g" $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql
            sed -i "s/__C_KEY_SALT__/$key_salt/g" $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql
            sed -i "s/__CDN_KEY__/$cnd_salt/g" $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql
            sed -i "s/__HOST_IP__/$server_ip/g" $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql
        fi
        docker exec -i cactus-web mysql --default-character-set=utf8 -h${dbHost} -ucactus -p${dbpwd}  cactus < $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/mysql/update.sql
        if [ "$?" != "0" ]
        then
            echo "[ERROR] 升级mysql数据库失败! 请联系专业人员处理"
        else
            echo "升级mysql数据库完成!"
        fi
    fi

    bak_cdb=$bak_dir/application/config/production/conf/db.json
    echo "----------------------------------------------------"
    if [ -f $bak_cdb ]
    then
        echo "设置db.json..."
        newconf=$(grep 'clickhouse' $cdb )
        oldconf=$(grep 'clickhouse' $bak_cdb)
        ck_pass="d1afdb00a5939afe"
        ck_df_pass="2cb0f8dd1afdb00a"
        if [[ "$newconf" != "" && "$oldconf" = "" ]]
        then
            #dbUser=$(echo $(cat $bak_cdb) | sed "s# ##g" | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}'| grep -Po '"username":".*?"'| awk -F '"' '{print $4}')
            dbpwd=$(echo $(cat $bak_cdb) | sed "s# ##g" | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}'| grep -Po '"password":".*?"'| awk -F '"' '{print $4}')
            dbHost=$(echo $(cat $bak_cdb) | sed "s# ##g"  | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"ip":".*?"' | awk -F '"' '{print $4}')
            dbPort=$(echo $(cat $bak_cdb) | sed "s# ##g"  | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"port":".*?"' | awk -F '"' '{print $4}')
            local_mac=$(echo $(cat $bak_cdb) | sed "s# ##g" | grep -Po '"local_mac":".*?"' | awk -F '"' '{print $4}')
            #rds_ip=$(echo $(cat $bak_cdb) | sed "s# ##g"  | grep -Po '"redis":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"ip":".*?"' | awk -F '"' '{print $4}')
            #rds_prot=$(echo $(cat $bak_cdb) | sed "s# ##g"  | grep -Po '"redis":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"port":".*?"' | awk -F '"' '{print $4}')
            rds_pass=$(echo $(cat $bak_cdb) | sed "s# ##g"  | grep -Po '"redis":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"password":".*?"' | awk -F '"' '{print $4}')

            sed -i "s#__HOST_IP__#${server_ip}#" $cdb
            sed -i "s#__HOST_MAC__#${local_mac}#" $cdb
            sed -i "s#\"mysql\",#\"${dbHost}\",#g" $cdb
            sed -i "s#3306#${dbPort}#g" $cdb
            sed -i "s#3fed7751744b8b59#${dbpwd}#g" $cdb
            sed -i "s#34aca5f40#${rds_pass}#g" $cdb

            ck_ip='cactus-clickhouse'
            if [ "${dbHost}" != "mysql" ]; then
                ck_ip=${dbHost}
            fi

            ck_df_pass=$(echo "${uuid}-$(date +%Y%m%d)-3604" | md5sum | cut -c 2-20)
            ck_pass=$(echo "$dbpwd" | md5sum | cut -c 3-21 )

            sed -i "s#__CK_HOST__#${ck_ip}#" $cdb
            sed -i "s#__CK_USER__#cactus#" $cdb
            sed -i "s#__CK_PASSWORD__#${ck_pass}#" $cdb
            sed -i "s#__CK_PORT_MYSQL__#9004#" $cdb
            sed -i "s#__CK_PORT_CK__#9000#" $cdb
        else
            ck_ip=$(echo $(cat $bak_cdb) | sed "s# ##g"  | grep -Po '"clickhouse":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"ip":".*?"' | awk -F '"' '{print $4}')
            dbHost=$(echo $(cat $bak_cdb) | sed "s# ##g"  | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"ip":".*?"' | awk -F '"' '{print $4}')
            /bin/cp -rf $bak_cdb $cdb

            ck_mysql=$(grep 'port_mysql' $cdb )
            if [ "$ck_mysql" = "" ]
            then
                ck_mysql_fix=$(grep 'port_' $cdb | grep -v 'port_ck' | awk -F '"' '{print $2}')
                if [ "$ck_mysql_fix" != "" ]
                then
                    sed -i "s#$ck_mysql_fix#port_mysql#" $cdb
                fi
            fi
        fi
    fi

    if [ -d $bak_dir/cert ]
    then
        echo "恢复证书文件..."
        if [ ! -d $base_dir/cactus-web/system/safe-cactus/cert ]
        then
            mkdir $base_dir/cactus-web/system/safe-cactus/cert
        fi
        /bin/cp -r $bak_dir/cert/* $base_dir/cactus-web/system/safe-cactus/cert/
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/ext/rsa_creator ]
    then
        echo "更新证书文件..."
        if [ ! -d $base_dir/cactus-web/system/safe-cactus/cert ]
        then
            mkdir $base_dir/cactus-web/system/safe-cactus/cert
        fi
        if [ -f $base_dir/cactus-web/system/safe-cactus/cert/auth_priv_prod.pem ]
        then
            /bin/rm -rf $base_dir/cactus-web/system/safe-cactus/cert/auth_priv_prod.pem
        fi
        if [ -f $base_dir/cactus-web/system/safe-cactus/cert/auth_pub_prod.pem ]
        then
            /bin/rm -rf $base_dir/cactus-web/system/safe-cactus/cert/auth_pub_prod.pem
        fi
        $base_dir/cactus-web/system/safe-cactus/ext/rsa_creator rsa -o $base_dir/cactus-web/system/safe-cactus/cert/auth_priv_prod.pem -po $base_dir/cactus-web/system/safe-cactus/cert/auth_pub_prod.pem
    fi

    if [ -d $bak_dir/application/data/licenses ]
    then
        echo "恢复licenses文件..."
        rm -rf $base_dir/cactus-web/system/safe-cactus/application/data/licenses
        /bin/cp -r $bak_dir/application/data/licenses $base_dir/cactus-web/system/safe-cactus/application/data/
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/application/script/sh/Migrate.sh ]
    then
        back_db "$dbHost" $dbpwd "$bak_time"
        echo "升级 migrate 记录 ..."
        docker exec -i cactus-web sh /home/q/system/safe-cactus/application/script/sh/Migrate.sh migrate
        
        if [ "$?" != "0" ]
        then
            echo -e "\033[31m [ERROR] upgrade migrate error \033[0m"
            echo -e "\033[31m [ERROR] 升级后请手动尝试执行： \033[0m"
            echo -e "\033[31m [ERROR]    docker exec -i cactus-web sh /home/q/system/safe-cactus/application/script/sh/Migrate.sh migrate  \033[0m"
        fi
    fi

    if [ "$msecret" = "y" ]
    then
        echo "----------------------------------------------------"
        echo "更新 mysql | redis password..."
        mysql_root_pass=$(echo "${uuid}-$(date +%Y%m%d)-3606" | md5sum | cut -c 1-16)
        mysql_pass=$(echo "${uuid}-$(date +%Y%m%d)-3605" | md5sum | cut -c 1-16)
        redis_pass=$(echo "${uuid}-$(date +%Y%m%d)-3609" | md5sum | cut -c 1-9)

        old_mysql_root_pass=$(grep 'MYSQL_ROOT_PASSWORD' ${compose_file} | awk -F ' ' '{print $2}')
        old_redis_pass=$(grep 'requirepass' ${compose_file} | awk -F ' ' '{print $5}')

        echo "update safe-cactus config (mysql|redis) password..."
        sed -ir "s#${dbpwd}#${mysql_pass}#g" $base_dir/cactus-web/system/safe-cactus/application/config/production/conf/db.json
        sed -ir "s#${old_redis_pass}#${redis_pass}#g" $base_dir/cactus-web/system/safe-cactus/application/config/production/conf/db.json

        echo "update mysql server user password..."
        echo "set password for root@localhost=password('${mysql_root_pass}');" > sec.sql
        echo "set password for cactus@'%'=password('${mysql_pass}');" >> sec.sql
        echo "flush privileges;" >> sec.sql

        use_mysql_root_pass=$old_mysql_root_pass
        if [ "$old_mysql_root_pass" = "1234567" ]
        then
            use_mysql_root_pass="887cc0fb48f9"
        fi

        docker exec -i mysql mysql -uroot -p${use_mysql_root_pass} < sec.sql

        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "back docker-compose.yml..."
            cp ${compose_file} ${compose_file}.$bak_time
        fi

        echo "update redis password...."
        sed -ir "s#YSQL_ROOT_PASSWORD: ${old_mysql_root_pass}#YSQL_ROOT_PASSWORD: ${mysql_root_pass}#" ${compose_file}
        sed -ir "s#requirepass ${old_redis_pass}#requirepass ${redis_pass}#" ${compose_file}

        docker-compose -f ${compose_file} up -d
        echo "wait 20s, service start..."
        sleep 20
        
        dbpwd=$mysql_pass
    fi

    echo "----------------------------------------------------"
    if [ -f $base_dir/cactus-web/system/safe-cactus/ext/clean_lcs_log.cron ]
    then
        echo "升级 clean_lcs_log.cron..."
        cp -f $base_dir/cactus-web/system/safe-cactus/ext/clean_lcs_log.cron /etc/cron.d/ && chmod 644 /etc/cron.d/clean_lcs_log.cron
    fi

    is_up_docker_compose="n"
    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/cascade-server ]
    then
        echo "备份级联文件..."
        cp -rf $base_dir/cascade-server $base_dir/cascade-server.$bak_time

        echo "升级级联文件 ..."
        sed -i "s/current_ip: 127.0.0.1/current_ip: $server_ip/g" $base_dir/cactus-web/system/safe-cactus/ext/cascade-server/application-test.yml
        rm -rf $base_dir/cascade-server/*
        cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cascade-server/* $base_dir/cascade-server/

        if [ -f $base_dir/cactus-web/system/safe-cactus/ext/docker-compose.yml ]
        then
            sec_ect=$(grep 'cascade-server' $base_dir/cactus-web/system/safe-cactus/ext/docker-compose.yml | grep -v grep)
            if [ ! -z "$sec_ect" ]
            then
                echo "update docker-compose.yml ..."
                cp ${compose_file} ${compose_file}.$bak_time
                cas_compose_data=$(fgrep 'SNAPSHOT.jar' ${compose_file}  | grep -v grep)
                sed -i "s#${cas_compose_data}#${sec_ect}#"  ${compose_file} 
                is_up_docker_compose="y"
            fi
        fi

        if [ -f $base_dir/cascade-server/start.sh ]
        then
            if [ ! -f ${compose_file}.$bak_time ]
            then
                cp ${compose_file} ${compose_file}.$bak_time
            fi

            cascade_start=$(cat ${compose_file} | grep '/home/q/cascade-server/lib/cascade-service' | grep -v grep | awk -F 'entrypoint:' '{print $2}')
            if [ "$cascade_start" != "" ]
            then
                sed -ir "s#${cascade_start}#/bin/sh -c '/bin/sh /home/q/cascade-server/start.sh && /bin/bash'#" ${compose_file}
            fi
            #sed -ir "s#java -jar -Dspring.profiles.active=test -Dakmc.cascade.base_dir=/home/q/cascade-server/ -Dspring.config.additional-location=file:/home/q/cascade-server/,file:/home/q/conf/db.json /home/q/cascade-server/lib/cascade-service-1.0.0.2200-SNAPSHOT.jar#/bin/sh -c '/bin/sh /home/q/cascade-server/start.sh && /bin/bash'#" ${compose_file}
        fi
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/docker-cascade ]
    then
        if [ -d $base_dir/cactus-web/system/safe-cactus/ext/docker-cascade/cascade-server ]
        then
             echo "备份级联文件..."
            /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/docker-cascade/cascade-server $base_dir/
        fi

        sed -i "s/current_ip: 127.0.0.1/current_ip: $server_ip/g" $base_dir/cascade-server/application-test.yml

        is_has=$(grep 'cactus-cascade' ${compose_file})
        if [ "$is_has" = "" ]
        then
            echo "升级级联文件 ..."
            echo "bakup to ${compose_file}.$bak_time"
            cp ${compose_file} ${compose_file}.$bak_time

            netline=$(grep -n 'networks:' ${compose_file}|awk -F':' '{print $1}')
            netbeforeline=$(expr $netline - 1)
            sed -i "${netbeforeline}r $base_dir/cactus-web/system/safe-cactus/ext/docker-cascade/docker-compose.yml.cascade" ${compose_file}
            sed -i "s#VolumesBase#$base_dir#g" ${compose_file}
            docker load --input $base_dir/cactus-web/system/safe-cactus/ext/docker-cascade/cactus-cascade_v1.1.tar

            is_up_docker_compose="y"
        fi
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/docker ]
    then
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "备份 docker-compose.yml 文件..."
            cp ${compose_file} ${compose_file}.$bak_time
        fi

        if [ -d $base_dir/cactus-web/system/safe-cactus/ext/docker/images ]
        then
            echo "加载docker镜像:"
            for image_line in $(ls $base_dir/cactus-web/system/safe-cactus/ext/docker/images | grep tar)
            do
                is_ck=$(echo $image_line | grep 'clickhouse')
                if [[ "$is_ck" != "" && "$ck_ip" != "cactus-clickhouse" ]]
                then
                    continue
                fi

                is_mysql=$(echo $image_line | grep 'mysql')
                if [[ "$is_mysql" != "" && "$dbHost" != "mysql" ]]
                then
                    continue
                fi

                echo "$image_line"
                docker load -i $base_dir/cactus-web/system/safe-cactus/ext/docker/images/$image_line
                
                load_image_name=$(echo "$image_line" | awk -F '_' '{print $1}')
                load_image_ver=$(echo "$image_line" | awk -F '_' '{print $2}' | awk -F '.tar' '{print $1}')
                attr_image="$load_image_name:$load_image_ver"
                old_image=$(cat ${compose_file} | grep "image:" | grep "$load_image_name" | head -1 | awk -F '/' '{print $3}')
                if [ "$old_image" != "" ]
                then
                    echo "update $old_image to $attr_image"
                    sed -ir "s#$old_image#$attr_image#g" ${compose_file}
                    sed -ir "s#cloud-ee/$attr_image#epp-images/$attr_image#g" ${compose_file}
                fi
            done
        fi

        docker_files=$base_dir/cactus-web/system/safe-cactus/ext/docker/files
        if [ -d $docker_files ]
        then
            for image_files in $(ls $docker_files)
            do
                if [[ "$image_files" = "cactus-clickhouse" && "$ck_ip" != "cactus-clickhouse" ]]
                then
                    continue
                fi

                if [ -d $base_dir/$image_files ]
                then
                    echo "备份docker服务文件: $image_files "
                    if [ "$image_files" != "cactus-naceng" ]
                    then
                        if [ "$image_files" = "cactus-mysql" ]
                        then
                            if [ -f $docker_files/cactus-mysql/my.conf ]
                            then
                                echo "备份mysql配置文件:"
                                /bin/cp -rf $base_dir/cactus-mysql/my.conf $base_dir/cactus-mysql/my.conf.${bak_time}
                                echo "  ok.."
                                echo "升级mysql配置文件:"
                                /bin/cp -rf $docker_files/cactus-mysql/my.conf $base_dir/cactus-mysql/my.conf
                                echo " ok.."
                            fi
                        else
                            mv $base_dir/$image_files $base_dir/${image_files}.${bak_time}
                        fi
                    else
                        if [ "$is_newnac" != "false" ]
                        then
                            mv $base_dir/$image_files $base_dir/${image_files}.${bak_time}
                        fi
                    fi
                fi

                if [ -d $docker_files/$image_files ]
                then
                    if [ "$image_files" != "cactus-naceng" ]
                    then
                        echo "升级docker服务文件: $image_files"
                        /bin/cp -rfp $docker_files/$image_files $base_dir/
                    else
                        if [ ! -d $base_dir/cactus-naceng ]
                        then
                            echo "升级docker服务文件: $image_files"
                            /bin/cp -rfp $docker_files/$image_files $base_dir/
                        fi
                    fi
                fi

                if [ "$image_files" = "cactus-clickhouse" ]
                then
                    if [ -f ${DockerVolumesBasePath}/cactus-clickhouse/conf/users.xml ]; then
                        sed -i "s/2cb0f8dd1afdb00a/${ck_df_pass}/" ${base_dir}/cactus-clickhouse/conf/users.xml
                        sed -i "s/d1afdb00a5939afe/${ck_pass}/" ${base_dir}/cactus-clickhouse/conf/users.xml
                    fi
                fi

                if [ "$image_files" = "cascade-server" ]
                then
                    image_files="cactus-cascade"
                    sed -i "s/current_ip: 127.0.0.1/current_ip: $server_ip/g" $base_dir/cascade-server/application-test.yml
                fi

                cimage_file=$base_dir/cactus-web/system/safe-cactus/ext/docker/docker-compose.yml.$image_files
                if [ -f $cimage_file ]
                then
                    is_load=$(grep "$image_files" ${compose_file})
                    if [ "$is_load" = "" ]
                    then
                        echo "update docker-compose.yml for $image_files"
                        if [ "$is_local_mysql" = "0" ]
                        then
                            isDependMysql=$(grep 'cactus-mysql' ${cimage_file} | grep -v '#')
                            if [ "$isDependMysql" != "" ]
                            then
                                dependOnNum=$(grep -v '#' ${cimage_file} | grep -A2 'depends_on' | grep -c ' - ')
                                if [ "$dependOnNum" = "1" ]
                                then
                                    dependOn=$(grep 'depends_on' ${cimage_file} | grep -v '#')
                                    dos=$(echo ${dependOn})
                                    sed -ri "s/${dos}/#${dos}/" ${cimage_file}
                                fi
                                dms=$(echo ${isDependMysql})
                                sed -ri "s/${dms}/#${dms}/" ${cimage_file}
                            fi

                            mysqlline=$(grep -n '- cactus-mysql' ${cimage_file}| grep -v '#' | awk -F':' '{print $1}')
                            mysqlbeforeline=$(expr $mysqlline - 1)
                            sed -i "${mysqlline}r/-l/#-/" ${compose_file}
                            sed -i "${mysqlbeforeline}r/- cactus-mysql/#- cactus-mysql/" ${compose_file}
                        fi

                        netline=$(grep -n 'networks:' ${compose_file}|awk -F':' '{print $1}')
                        netbeforeline=$(expr $netline - 1)
                        sed -i "${netbeforeline}r ${cimage_file}" ${compose_file}
                        sed -i "s#VolumesBase#$base_dir#g" ${compose_file}

                        has_cacade_img=$(grep 'CactCascadeName' ${compose_file})
                        if [ "$has_cacade_img" != "" ]
                        then
                            cascade_img=$(grep 'epp-images/cactus-cascade' ${compose_file}  | head -n1 | awk '{print $2}')
                            sed -i "s#CactCascadeName#${cascade_img}#g" ${compose_file}
                        fi
                    fi
                fi
            done
        fi

        ngx_file=$base_dir/cactus-web/system/safe-cactus/ext/docker/docker-compose.yml.cactus-nginx
        if [ -f $ngx_file ]; then
            is_load=$(grep "cactus-nginx" ${compose_file})
            if [ "$is_load" = "" ]; then
                echo "update docker-compose.yml for cactus-nginx"
                https_port=$(grep -A20 'container_name: cactus-web' ${compose_file} | grep ':443"' | tr -d '"' | tr -d '-' | tr -d ' ' | awk -F ':' '{print $1}')
                if [ "$https_port" = "" ]; then
                    https_port=443
                fi
                http_port=$(grep -A20 'container_name: cactus-web' ${compose_file} | grep ':80"' | tr -d '"' | tr -d '-' | tr -d ' ' | awk -F ':' '{print $1}')
                if [ "$http_port" = "" ]; then
                    http_port=8081
                fi

                sed -ir '/container_name: cactus-web/,//{s/- "8082:8082"/#- "8082:8082"/}' ${compose_file}
                sed -ir 's/- "'${https_port}':443"/#- "'${https_port}':443"/' ${compose_file}
                sed -ir 's/- "'${http_port}':80"/#- "'${http_port}':80"/' ${compose_file}

                netline=$(grep -n 'networks:' ${compose_file}|awk -F':' '{print $1}')
                netbeforeline=$(expr $netline - 1)
                sed -i "${netbeforeline}r ${ngx_file}" ${compose_file}
                ngx_img=$(echo $base_dir/cactus-web/system/safe-cactus/ext/docker/images/cactus-nginx_*.tar)
                ngx_img_name=$(echo "$ngx_img" | awk -F '/' '{print $NF}' | sed  's#_#:#' | sed 's#.tar##')
                sed -ir "s#CactNginxName#r.addops.soft.360.cn/epp-images/${ngx_img_name}#" ${compose_file}
                sed -ir "s#VolumesBase#$base_dir#g" ${compose_file}
                sed -i "s/WEB_HTTPS_PORT/${https_port}/" ${compose_file}
                sed -i "s/WEB_HTTP_PORT/${http_port}/" ${compose_file}
            fi
        fi

        is_up_docker_compose="y"
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/script ]
    then
        is_compose_up=$(ls $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/script | grep '.sh' | grep 'service_compose_')
        if [ "$is_compose_up" != "" ]
        then
            echo "----------------------------------------------------"
            echo "执行服务自定义升级SH文件:"
            for sh_script in $(ls $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/script | grep '.sh' | grep 'service_compose_')
            do
                echo " run $sh_script :"
                /bin/sh $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/script/$sh_script gotoend
                if [ "$?" != "0" ]
                then
                    echo "    error: $? ... "
                else
                    echo "    ok..."
                fi
            done
            echo "----------------------------------------------------"
            is_up_docker_compose="y"
        fi
    fi

    has_mysql=$(grep 'cactus-mysql' ${compose_file} | grep -v '#' || echo "false")
    if [ "$has_mysql" != "false" ]
    then
        is_up_mysql_tz=$(grep -A10 'container_name: mysql' ${compose_file} | grep 'TZ: Asia/Shanghai' )
        if [ "$is_up_mysql_tz" = "" ]
        then
            echo "upgrade docker compose TZ:"
            line=$(grep -nA15 'container_name: mysql' ${compose_file} | grep 'MYSQL_ROOT_PASSWORD' | awk -F '-' '{print $1}')
            if [ "$line" != "" ]
            then
                line_data="########            TZ: Asia/Shanghai"
                sed -i "${line} a ${line_data}" ${compose_file}
                sed -ir "s/########//" ${compose_file}
                echo "[SUCC] mysql TZ up success"
            else
                echo "[FAIL] mysql TZ up failed"
            fi
            is_up_docker_compose="y"
        fi
    fi

    if [ "$end_version" = "10.0.0.04113" ]
    then
        isUp=$(grep '8022:22' ${compose_file} | grep -v "#" | grep -v "grep" )
        if [ "$isUp" != "" ]
        then
            sed -ir 's/- "8022:22"/#- "8022:22"/' ${compose_file}
        fi

        isUpCascade=$(grep '36444:36444' ${compose_file} | grep -v "#" | grep -v "grep")
        isUpCascadeG=$(grep '36093:36093' ${compose_file} | grep -v "#" | grep -v "grep")
        if [[ "$isUpCascade" != "" || "$isUpCascadeG" != "" ]]
        then
            sed -ir '/container_name: cactus-cascade/,//{s/ports/#ports/}' ${compose_file}
            sed -ir 's/- "36093:36093"/#- "36093:36093"/' ${compose_file}
            sed -ir 's/- "36094:36094"/#- "36094:36094"/' ${compose_file}
            sed -ir 's/- "36444:36444"/#- "36444:36444"/' ${compose_file}
        fi

        is_up_docker_compose="y"
    fi

    if [ "$end_version" = "10.0.0.05000" ]
    then
        echo "更新镜像仓库:"
        for images_info in $(docker images -a | fgrep cloud-ee | awk '{print $3"---"$1":"$2}' | sed "s#cloud-ee#epp-images#g" | sed "s#jre8#cactus-cascade#")
        do
            image_id=$(echo "$images_info" | awk -F '---' '{print $1}')
            image_name_tag=$(echo "$images_info" | awk -F '---' '{print $2}')
            image_name=$(echo "$image_name_tag" | awk -F ':' '{print $1}')
            image_tag=$(echo "$image_name_tag" | awk -F ':' '{print $2}')
            image_has=$(docker images | grep "$image_name" | grep "$image_tag" | grep -v grep)
            if [ "$image_has" = "" ]
            then
                echo "tag: $image_id $image_name_tag"
                docker tag $image_id $image_name_tag
            fi
        done
        # 把docker-compose中的镜像，改名
        sed -i "s#cloud-ee#epp-images#g" ${compose_file}
        sed -i "s#jre8#cactus-cascade#g" ${compose_file}

        # cascade 更新改名方式
        old_cascade_start=$(grep 'java -jar -Dspring.profiles.active=test' ${compose_file} | grep -v grep | awk -F 'entrypoint:' '{print $2}')
        if [ "$old_cascade_start" != "" ]
        then
            sed -ri "s#${old_cascade_start}# /bin/sh -c '/bin/sh /home/q/cascade-server/start.sh \&\& /bin/bash'#" ${compose_file}
        fi

        qconf_status=$(grep -A 1 'cascade-server:/home' ${compose_file} | grep '/home/q/conf')
        if [ "$qconf_status" = "" ]
        then
            cascade_line=$(grep -n 'cascade-server:/home' ${compose_file} | awk -F ':' '{print $1}')
            qconf_line=$(expr $cascade_line + 1)
            sed -i "${qconf_line}i ########    - VolumesBase/cactus-web/system/safe-cactus/application/config/production/conf:/home/q/conf" ${compose_file}
            sed -i 's/########/        /' ${compose_file}
            sed -i "s#VolumesBase#$base_dir#g" ${compose_file}
        fi

        is_up_docker_compose="y"
    fi

    isUpNewtrans=$(grep "cactus-newtransserver/etc/config.ini" ${compose_file})
    if [ "$isUpNewtrans" = "" ]
    then
        echo "更新 docker-compose.yml, 升级 cactus-newtransserver 配置"
        sed -ir "s#cactus-newtransserver:/docker#cactus-newtransserver:/docker\n            - /data/docker/cactus-newtransserver/etc/config.ini:/etc/config.ini#" ${compose_file}
        is_up_docker_compose="y"
    fi

    isUpCascade=$(grep '36444:36444' ${compose_file} | grep -v "#" | grep -v "grep")
    if [ "$isUpCascade" != "" ]
    then
        echo "更新 docker-compose.yml, 关闭端口:36444 "
        sed -ir 's/- "36444:36444"/#- "36444:36444"/' ${compose_file}
        is_up_docker_compose="y"
    fi

    isUpCascadeG=$(grep '36094:36094' ${compose_file} | grep -v "#" | grep -v "grep")
    if [ "$isUpCascadeG" != "" ]
    then
        echo "更新 docker-compose.yml, 关闭端口:36094 "
        sed -ir 's/- "36094:36094"/#- "36094:36094"/' ${compose_file}
        is_up_docker_compose="y"
    fi

    isUpSeccPord=$(grep '36025:36025' ${compose_file} | grep -v "#" | grep -v "grep")
    if [ "$isUpSeccPord" != "" ]
    then
        echo "更新 docker-compose.yml, 关闭端口:36025 "
        sed -ir '/container_name: seccscan/,//{s/ports/#ports/}' ${compose_file}
        sed -ir 's/- "36025:36025"/#- "36025:36025"/' ${compose_file}
        is_up_docker_compose="y"
    fi

    has_storage=$(grep 'cactus-web/storage' ${compose_file})
    if [ "$has_storage" = "" ]
    then
        echo "更新 docker-compose.yml, 升级 cactus-web/storage "
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "备份 ${compose_file}.$bak_time"
            /bin/cp -r ${compose_file} ${compose_file}.$bak_time
        fi
        sed -ri '/storage:\/data\/storage/d' ${compose_file}
        sed -ri '/supervisord.d\/?:\/etc\/supervisord.d/{h;s#/data/docker/.+$#/data/docker/cactus-web/storage:/data/storage#;x;G}' ${compose_file}
        is_up_docker_compose="y"
    fi

    large_port=$(grep -A 20 'container_name: cactus-web' ${compose_file} | grep -v grep | grep 'ip_local_port_range')
    if [ "$large_port" = "" ]
    then
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "备份 ${compose_file}.$bak_time"
            /bin/cp -r ${compose_file} ${compose_file}.$bak_time
        fi
        echo "更新 docker-compose.yml, 升级 cactus-web ip_local_port_range "
        envNum=$(grep -n -A 20 'container_name: cactus-web' ${compose_file} | grep -v grep | grep 'environment' | awk -F '-' '{print $1}')
        sed -ir "${envNum}s/environment:/sysctls:\n            net.ipv4.ip_local_port_range: \"10000    65000\"\n        environment:/" ${compose_file}
        is_up_docker_compose="y"
    fi

    has_ngx=$(grep 'container_name: cactus-nginx' ${compose_file} | grep -v grep)
    if [ "$has_ngx" != "" ]
    then
        large_ngx_port=$(grep -A 20 'container_name: cactus-nginx' ${compose_file} | grep -v grep | grep 'ip_local_port_range')
        if [ "$large_ngx_port" = "" ]
        then
            if [ ! -f ${compose_file}.$bak_time ]
            then
                echo "备份 ${compose_file}.$bak_time"
                /bin/cp -r ${compose_file} ${compose_file}.$bak_time
            fi
            echo "更新 docker-compose.yml, 升级 cactus-nginx ip_local_port_range "
            envNum=$(grep -n -A 20 'container_name: cactus-nginx' ${compose_file} | grep -v grep | grep 'environment' | awk -F '-' '{print $1}')
            sed -ir "${envNum}s/environment:/sysctls:\n            net.ipv4.ip_local_port_range: \"10000    65000\"\n        environment:/" ${compose_file}
            is_up_docker_compose="y"
        fi
    fi

    web_core=$(grep 'container_name: cactus-web' -n -A 5 ${compose_file} | grep 'core: 0' | grep -v 'grep')
    if [ "$web_core" = "" ]
    then
        echo "更新 docker-compose.yml, 升级 cactus-web core "
        /bin/cp -rf ${compose_file} ${compose_file}.web.$bak_time
        core_line=$(grep 'container_name: cactus-web' -n5 ${compose_file} | grep "command" | grep -v 'grep' | awk -F'-' '{print $1}')
        core_data="UUUUUUUU       ulimits:\n            core: 0"
        sed -i "${core_line} a $core_data" ${compose_file}
        sed -i "s#UUUUUUUU# #" ${compose_file}
        is_up_docker_compose="y"
    fi

    is_up_docker_compose_clean="n"
    disable_nsqadmin=$(grep 'nsqadmin:' ${compose_file}  | grep -v "#" | grep -v grep)
    if [ "$disable_nsqadmin" != "" ]
    then
        echo "更新 docker-compose.yml, 升级 nsqadmin "
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "bakup to ${compose_file}.$bak_time"
            /bin/cp -r ${compose_file} ${compose_file}.$bak_time
        fi
        cat ${compose_file} | sed  '/nsqadmin:/,/^\s*$/{s/^/#/}' | sed -r 's/^[\s#]+$//'  > /home/s/lcsd/docker-compose_new.yml
        mv ${compose_file} ${compose_file}.disable_nsqadmin.$bak_time
        mv /home/s/lcsd/docker-compose_new.yml ${compose_file}
        is_up_docker_compose_clean="y"
        is_up_docker_compose="y"
        echo "ok"
    fi

    nofile="UUUUUUUU    nofile:\n                soft: 102400\n                hard: 102400"
    nolimit="UUUUUUUU       ulimits:\n            core: 0\n    nofile:\n                soft: 102400\n                hard: 102400"
    isUp=$(grep -A10 'container_name: cactus-web' ${compose_file} | grep 'nofile' || echo "false")
    if [ "$isUp" = "false" ]; then
        echo "更新 docker-compose.yml, 升级 web ulimit "
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "bakup to ${compose_file}.$bak_time"
            /bin/cp -r ${compose_file} ${compose_file}.$bak_time
        fi
        line=$(grep -nA20 'container_name: cactus-web' ${compose_file}  | grep core | awk -F '-' '{print $1}')
        sed -i "${line} a ${nofile}" ${compose_file}
        sed -i "s#UUUUUUUU#        #" ${compose_file}
        is_up_docker_compose="y"
        echo "ok"
    fi

    isUpcas=$(grep -7 'container_name: cactus-cascade' ${compose_file} | grep 'nofile' || echo "false")
    if [ "$isUpcas" = "false" ]; then
        echo "更新 docker-compose.yml, 升级 cactus-cascade ulimit "
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "bakup to ${compose_file}.$bak_time"
            /bin/cp -r ${compose_file} ${compose_file}.$bak_time
        fi
        line=$(grep -n7 'container_name: cactus-cascade' ${compose_file}  | grep core | awk -F '-' '{print $1}')
        if [ "$line" = "" ]; then
            line=$(grep -n 'container_name: cactus-cascade' ${compose_file} | awk -F ':' '{print $1}')
            sed -i "${line} a ${nolimit}" ${compose_file}
        else
            sed -i "${line} a ${nofile}" ${compose_file}
        fi
        sed -i "s#UUUUUUUU#        #" ${compose_file}
        is_up_docker_compose="y"
        echo "ok"
    fi

    isUpsec=$(grep -7 'container_name: seccscan' ${compose_file} | grep 'nofile' || echo "false")
    if [ "$isUpsec" = "false" ]; then
        echo "更新 docker-compose.yml, 升级 seccscan ulimit "
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "bakup to ${compose_file}.$bak_time"
            /bin/cp -r ${compose_file} ${compose_file}.$bak_time
        fi
        line=$(grep -n7 'container_name: seccscan' ${compose_file}  | grep core | awk -F '-' '{print $1}')
        if [ "$line" = "" ]; then
            line=$(grep -n 'container_name: seccscan' ${compose_file} | awk -F ':' '{print $1}')
            sed -i "${line} a ${nolimit}" ${compose_file}
        else
            sed -i "${line} a ${nofile}" ${compose_file}
        fi
        sed -i "${line} a ${nofile}" ${compose_file}
        sed -i "s#UUUUUUUU#        #" ${compose_file}
        is_up_docker_compose="y"
        echo "ok"
    fi

    isUpsecurity=$(grep -7 'container_name: cactus-security' ${compose_file} | grep 'nofile' || echo "false")
    if [ "$isUpsecurity" = "false" ]; then
        echo "更新 docker-compose.yml, 升级 cactus-security ulimit "
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "bakup to ${compose_file}.$bak_time"
            /bin/cp -r ${compose_file} ${compose_file}.$bak_time
        fi
        line=$(grep -n7 'container_name: cactus-security' ${compose_file}  | grep core | awk -F '-' '{print $1}')
        if [ "$line" = "" ]; then
            line=$(grep -n 'container_name: cactus-security' ${compose_file} | awk -F ':' '{print $1}')
            sed -i "${line} a ${nolimit}" ${compose_file}
        else
            sed -i "${line} a ${nofile}" ${compose_file}
        fi
        sed -i "s#UUUUUUUU#        #" ${compose_file}
        is_up_docker_compose="y"
        echo "ok"
    fi

    isUpnaceng=$(grep -7 'container_name: naceng' ${compose_file} | grep 'nofile' || echo "false")
    if [ "$isUpnaceng" = "false" ]; then
        echo "更新 docker-compose.yml, 升级 naceng ulimit "
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "bakup to ${compose_file}.$bak_time"
            /bin/cp -r ${compose_file} ${compose_file}.$bak_time
        fi
        line=$(grep -n7 'container_name: naceng' ${compose_file}  | grep core | awk -F '-' '{print $1}')
        if [ "$line" = "" ]; then
            line=$(grep -n 'container_name: naceng' ${compose_file} | awk -F ':' '{print $1}')
            sed -i "${line} a ${nolimit}" ${compose_file}
        else
            sed -i "${line} a ${nofile}" ${compose_file}
        fi
        sed -i "s#UUUUUUUU#        #" ${compose_file}
        is_up_docker_compose="y"
        echo "ok"
    fi

    isUpecb=$(grep -7 'container_name: cactus-ecbclient' ${compose_file} | grep 'nofile' || echo "false")
    if [ "$isUpecb" = "false" ]; then
        echo "更新 docker-compose.yml, 升级 cactus-ecbclient ulimit "
        if [ ! -f ${compose_file}.$bak_time ]
        then
            echo "bakup to ${compose_file}.$bak_time"
            /bin/cp -r ${compose_file} ${compose_file}.$bak_time
        fi
        line=$(grep -n7 'container_name: cactus-ecbclient' ${compose_file}  | grep core | awk -F '-' '{print $1}')
        if [ "$line" = "" ]; then
            line=$(grep -n 'container_name: cactus-ecbclient' ${compose_file} | awk -F ':' '{print $1}')
            sed -i "${line} a ${nolimit}" ${compose_file}
        else
            sed -i "${line} a ${nofile}" ${compose_file}
        fi
        sed -i "s#UUUUUUUU#        #" ${compose_file}
        is_up_docker_compose="y"
        echo "ok"
    fi

    if [ "$is_up_docker_compose" = "y" ]
    then
        echo "更新容器服务..."
        if [ "$is_up_docker_compose_clean" = "y" ]
        then
            docker-compose -f ${compose_file} up -d --remove-orphans
        else
            docker-compose -f ${compose_file} up -d
        fi

        stop_super
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/lcs ]
    then
        echo "备份 lcs 服务: $base_dir/lcs.$bak_time"
        /bin/cp -r $base_dir/lcs $base_dir/lcs.$bak_time
        echo "升级 lcs 服务..."
        #/bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/lcs/* $base_dir/lcs/
        if [ -f $base_dir/cactus-web/system/safe-cactus/ext/lcs/conf/tconf.ini ]
        then
            # upgrade pc_typeid
            new_typeid=$(grep 'pc_typeid' $base_dir/cactus-web/system/safe-cactus/ext/lcs/conf/tconf.ini)
            if [ "$new_typeid" != "" ]
            then
                old_typeid_line=$(grep -n 'pc_typeid' $base_dir/lcs/conf/tconf.ini | awk -F ':' '{print $1}')
                if [ "$old_typeid_line" != "" ]
                then
                    sed -i "${old_typeid_line}d" $base_dir/lcs/conf/tconf.ini
                    sed -i "/product_combo_typeid/a\\${new_typeid}" $base_dir/lcs/conf/tconf.ini
                fi
            fi
        fi
        docker-compose -f ${compose_file} restart lcs nginx
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/start.sh ]
    then
        echo "升级 cactus-web start.sh ..."
        #docker exec -it cactus-web ln -s /home/q/system/cab_decode/jre/bin/java /usr/bin/
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/start.sh $base_dir/cactus-web/
        echo "ok"
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/process/cascade/agent/conf/conf.yaml ]
    then
        echo "更新 cactus agent 配置 ..."
        sed -i "s/NEED_REPLACE_CACTUS_WEB_IP/$server_ip/g" $base_dir/cactus-web/system/safe-cactus/process/cascade/agent/conf/conf.yaml
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/process/bin/agent/release.toml ]
    then
        echo "更新 monitor 配置 ..."
        sed -i "s/__HOST_IP__/$server_ip/g" $base_dir/cactus-web/system/safe-cactus/process/bin/agent/release.toml
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/dl.360safe.com ]
    then
        echo "----------------------------------------------------"
        echo "升级客户端文件:"
        echo "升级 dl.360safe.com 文件..."
        dl_bak_dir=$base_dir/cactus-web/system/dl.360safe.com-$bak_time
        mkdir $dl_bak_dir
        /bin/cp -r $base_dir/cactus-web/system/dl.360safe.com/* $dl_bak_dir/
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/dl.360safe.com/* $base_dir/cactus-web/system/dl.360safe.com/
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/sdup.360.cn ]
    then
        echo "升级 sdup.360.cn 文件..."
        dl_bak_dir=$base_dir/cactus-web/system/sdup.360.cn-$bak_time
        mkdir $dl_bak_dir
        /bin/cp -r $base_dir/cactus-web/system/sdup.360.cn/* $dl_bak_dir/
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/sdup.360.cn/* $base_dir/cactus-web/system/sdup.360.cn/
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/sdup.qihucdn.com ]
    then
        echo "升级 sdup.qihucdn.com 文件..."
        dl_bak_dir=$base_dir/cactus-web/system/sdup.qihucdn.com-$bak_time
        mkdir $dl_bak_dir
        /bin/cp -r $base_dir/cactus-web/system/sdup.qihucdn.com/* $dl_bak_dir/
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/sdup.qihucdn.com/* $base_dir/cactus-web/system/sdup.qihucdn.com/
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/nginx ]
    then
        nginx_bak_dir=$base_dir/cactus-web/nginx.$bak_time
        echo "备份nginx配置: $nginx_bak_dir"
        /bin/cp -rf $base_dir/cactus-web/nginx $nginx_bak_dir
        echo "升级nginx配置..."
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/nginx/* $base_dir/cactus-web/nginx/

        if [ ! -d $base_dir/cactus-web/logs/download.microsoft.com/web ]
        then
            mkdir -p $base_dir/cactus-web/logs/download.microsoft.com/web
            mkdir -p $base_dir/cactus-web/logs/download.microsoft.com/app
        fi

        if [ ! -d $base_dir/cactus-web/logs/archive.kylinos.cn/web ]
        then
            mkdir -p $base_dir/cactus-web/logs/archive.kylinos.cn/web
            mkdir -p $base_dir/cactus-web/logs/archive.kylinos.cn/app
        fi
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/nginx ]
    then

        lcs_nginx_bak_dir=$base_dir/nginx.$bak_time
        echo "备份 lcsd nginx 配置: $lcs_nginx_bak_dir"
        /bin/cp -rf $base_dir/nginx $lcs_nginx_bak_dir
        echo "升级 lcsd nginx 配置 ..."
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/nginx/* $base_dir/nginx/
    fi

    echo "检测标准redis最大内存:"
    redisMaxMem=$(grep 'maxmemory ' $base_dir/cactus-redis/conf/redis.conf | grep -v '#' | awk '{print $2}')
    if [ "$redisMaxMem" != "4194304k" ]; then
        echo "检测完毕，开始升级:"
        sed -i "s#$redisMaxMem#4194304k#g" $base_dir/cactus-redis/conf/redis.conf
    fi
    echo "ok..."

    if [ -f $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/supervisord.d/cactus_admin.ini ]
    then
        super_bak_dir=$base_dir/cactus-web/supervisord.d.$bak_time
        echo "备份supervisor配置: $super_bak_dir"
        /bin/cp -rf $base_dir/cactus-web/supervisord.d $super_bak_dir
        echo "升级supervisor配置 ..."
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/supervisord.d/cactus_admin.ini $base_dir/cactus-web/supervisord.d/cactus_admin.ini
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/crontab ]
    then
        echo "升级crontab ..."
        /bin/cp -rf $base_dir/cactus-web/system/crontab $base_dir/cactus-web/system/crontab.bak.$bak_time
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/crontab $base_dir/cactus-web/system/crontab
        docker exec -i cactus-web /bin/cp /home/q/system/crontab /var/spool/cron/root
        docker exec -i cactus-web chmod 600 /var/spool/cron/root
        docker exec -i cactus-web sh -c "ps -ef | grep crond | grep -v grep | awk '{print \\$2}' | xargs kill && /usr/sbin/crond"
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/cactus_logrotate ]
    then
        echo "升级cactus_logrotate..."
        /bin/cp -rf $base_dir/cactus-web/system/cactus_logrotate $base_dir/cactus-web/system/cactus_logrotate.bak.$bak_time
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/cactus_logrotate $base_dir/cactus-web/system/cactus_logrotate
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/cab_decode ]
    then
        echo "升级cab_decode ..."
        /bin/cp -rf $base_dir/cactus-web/system/cab_decode $base_dir/cactus-web/system/cab_decode.$bak_time
        if [ -d $base_dir/cactus-web/system/cab_decode/jre ]
        then
            /bin/rm -rf $base_dir/cactus-web/system/cab_decode/jre
        fi
        /bin/cp -rf $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/system/cab_decode $base_dir/cactus-web/system/
    fi

    echo "----------------------------------------------------"
    if [ -d $bak_dir/application/data/client ]
    then
        echo "恢复client文件..."
        rm -rf $base_dir/cactus-web/system/safe-cactus/application/data/client
        /bin/cp -r $bak_dir/application/data/client $base_dir/cactus-web/system/safe-cactus/application/data/
    fi

    if [ -d $bak_dir/public/aptlog/ ]
    then
        echo "恢复aptlog文件..."
        mv $bak_dir/public/aptlog/ $base_dir/cactus-web/system/safe-cactus/public/
    fi

    if [ -d $base_dir/cactus-web/system/libdown/olddir ]; then
        echo "清理libdown历史升级文件..."
        rm -rf $base_dir/cactus-web/system/libdown/olddir/*
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/monitor_agent_install.sh ]
    then
        echo "升级monitor服务..."
        /bin/cp $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/monitor_agent_install.sh $base_dir/cactus-web/monitor_agent_install.sh
        /bin/sh $base_dir/cactus-web/monitor_agent_install.sh -t web -i ${server_ip} -S 127.0.0.1 -l 127.0.0.1:8080
    fi

    if [ -f $base_dir/cactus-web/system/dl.360safe.com/secdzqz/software/index.db ]
    then
        echo "升级软件管家库..."
        docker exec -i cactus-web sh 'cd /home/q/system/safe-cactus/process/bin/cactus && ./cactus tool -c conf/conf.yaml loadCloudSoft --file=/home/q/system/dl.360safe.com/secdzqz/software/index.db'
    fi

    if [ -d $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/script ]
    then
        is_has_up_sh=$(ls $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/script | grep '.sh' | grep -v 'before_db_' | grep -v 'service_compose_')
        if [ "$is_has_up_sh" != "" ]
        then
            echo "----------------------------------------------------"
            echo "执行临时sh文件:"
            for sh_script in $(ls $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/script | grep '.sh' | grep -v 'before_db_' | grep -v 'service_compose_')
            do
                echo " run $sh_script :"
                /bin/sh $base_dir/cactus-web/system/safe-cactus/ext/cactus-web/script/$sh_script gotoend
                if [ "$?" != "0" ]
                then
                    echo "    error: $? ... "
                else
                    echo "    ok..."
                fi
            done
            echo "----------------------------------------------------"
        fi
    fi

    if [ -f $base_dir/cactus-naceng/cmc-server/update.sh ]; then
        echo "===== nac 服务升级 ====="
        docker exec -i naceng sh /home/q/phenix/cmc-server/update.sh
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/application/script/sh/ClientUpgradePackage.sh ]; then
        echo "===== 客户端记录升级 ====="
        docker exec -i cactus-web sh /home/q/system/safe-cactus/application/script/sh/ClientUpgradePackage.sh
    fi

    pcbmip_version=$(echo "10.0.0.04999 $end_version" | tr " " "\n" | sort -rV | head -n 1)
    if [ "$pcbmip_version" = "10.0.0.04999" ]; then
        docker exec -it cactus-web /usr/local/bin/php /home/q/system/safe-cactus/application/script/ConvertPluginBitMap.php
    fi
 
    if [ -f $base_dir/cactus-web/system/safe-cactus/application/script/Upgrade.php ]; then
        echo "===== 升级 proxy config ====="
        docker exec -it cactus-web /usr/local/bin/php /home/q/system/safe-cactus/application/script/Upgrade.php
    fi

    if [ -f $base_dir/cactus-web/system/safe-cactus/application/script/ServiceUpgrade.php ]; then
        echo "===== 记录升级版本 ====="
        docker exec -it cactus-web /usr/local/bin/php /home/q/system/safe-cactus/application/script/ServiceUpgrade.php --f $start_version --t $end_version --s $script_name
        if [ "$?" != "0" ]; then
            echo "upgrade version 失败，请手动执行: docker exec -it cactus-web /usr/local/bin/php /home/q/system/safe-cactus/application/script/ServiceUpgrade.php --f $start_version --t $end_version --s $script_name"
        fi
    fi

    #echo "----------------------------------------------------"
    #echo "重启内部服务:"
    #docker exec -it cactus-web /usr/bin/supervisorctl reload

    #docker exec -it cactus-web /home/q/system/safe-cactus/fpm.sh restart
    #if [ $? != 0 ]
    #then
    #    echo "重启fpm失败，请手动执行: docker exec -it cactus-web /home/q/system/safe-cactus/fpm.sh restart"
    #fi
    
    echo "清理临时升级文件:"
    rm -rf $base_dir/cactus-web/system/safe-cactus/ext
    rm -rf $tmp_dir
    if [ "$?" = "0" ]
    then
        echo "ok"
    fi

    end_update
    exit 0
}
main "$@"# This line must be the last line of the file
__ARCHIVE_BELOW__
