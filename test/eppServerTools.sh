#!/bin/bash

:<<NOTES

::* 系统支持(理论上和官方EPP支持一致;但是亦列出兼容系统. 部分功能需要已经安装EPP方可使用.): centos7 | centos8 | rocky linux 8.7
::* 前置第三方组件 curl | wget | tee
::## 在线脚本 (l="https://gitee.com/KermitYao/Scripts/raw/master/test/eppServerTools.sh";e=e.sh;wget -O "$e" "$l" || curl -kL "$l" > "$e")&&sudo sh e.sh -s 

::* v1.0.1_20230507_beta
    1.初始脚本代码完成

::* v1.1.0_20230718_beta
    2.完善整体框架,第一个完整版本完成.

::* v1.1.1_20230731_beta
    1.修改了一些微不足道的内容

::* v1.2.1_20230913_beta
    1.修复 在未安装epp的情况下升级报错问题
    2.更新 将环境清理从之间的删除docker容器和镜像修改为通过docker-compose down 方式清理


::*********************************************************


快速使用:
	eppServerTools.sh -h

概述:
	此脚本用于简化360EPP控制台的安装升级以及维护操作

功能:
	1.自动下载升级文件
	2.自动升级一个版本、升级到最新、升级到指定版本
	3.自动备份数据库
    4.自动还原数据库
    5.清理安装环境
    6.自动修改计算机ip地址
    7.修改管理管理员密码
    8.主机加固
    9.获取最新版本安装包
	10.进入mysql
	11.可以根据需求自定义命令行参数，达到脚本自动运行安装的目的,(通过 DEFAULT_ARGS 参数实现)
	12.默认不加参数打开脚本会出现一个选择界面（此界面的操作会有一定的交互能力）
	13.支持命令行参数,以便远程批量推送时静默安装
    14.支持代理下载

使用方法：
	1.可以使用参数 -h | -help 来查看支持的参数
	2.脚本的运行需要root 权限

NOTES

scriptVersion=v1.2.1_20230913_beta

# ----------user var-----------------

#日志等级 DEBUG|INFO|WARNING|ERROR
logLevel="DEBUG"

#安装文件下载目录
instUrlPath=https://yjyn.top:1443/Company/YCH/360/360EPP/360EPP_install

#升级文件下载目录
updateUrlPath=https://yjyn.top:1443/Company/YCH/360/360EPP/360EPP_update

codeInfoName="code.txt"


# ----------user var-----------------


# ----------sys var----------------
#临时文件存放目录
tempPath=/tmp/360eppTools
test -d ${tempPath}||mkdir -p ${tempPath}
scriptDir="$(cd "$(dirname "$0")";pwd)"

testLine="---------------------------------"
srcArgs="$@"

logPath="${tempPath}/$(basename $0).log"
composeFile="/home/s/lcsd/docker-compose.yml"
instDir="/data"
baseDir=$instDir/docker
productName="360终端安全管理系统"
argsList="argHelp argStatusInfo argLog argClean argProxy argProxyValue argDown  argDownValue argUpgrade argUpgradeValue argBackupData argBackupDataValue argRestoreData argRestoreDataValue argModifyIp argModifyIpValue argSetpw argSetpwValue  argForce argExec argExecValue argGetInstPkg argSetSafe argVersion"

userID=$(id -u)

# ----------sys var-----------------


# ----------function-----------------


getCuiHelp() {
cat <<EOF

    360EPP tools script for linux

Usage: $0 [options]

  -h,  --help                   打印帮助信息
  -d,  --download [l|ver]       下载升级文件,可以指定l来获取版本列表,指定一个版本进行下载
  -u,  --upgrade [u|a|ver]      升级版本,u升级一个版本,a自动升级到最新,ver可以指定一个版本,将自动升级到对应的版本
  -b,  --backup [file]          备份数据库,如果未指定路径,将在当前目录下生成
  -r,  --restore file           还原数据库,通过指定一个文件路径来还原数据库
  -c,  --clean                  清理安装环境(卸载所有已安装的EPP组件)
  -m,  --modify                 修改系统EPPip地址
  -s,  --status                 打印状态信息
  -l,  --log                    关闭日志显示
  -p,  --proxy ip:port          指定一个代理用于网络中转
  --setpw                       强制修改管理员密码
  --setSafe                     主机加固
  --getInstPkg                  获取最新版本安装包
  -e,  --exec [sql command]     执行mysql命令或者进入mysql
  -g,  --gui                    脚本不会自动退出
  -f,  --force                  某些情况下不会询问,强制执行.
  -v,  --version                打印当前版本

		Example: $0 -d l -b /tmp/epp_20230604.sql -s -gui -p "192.168.6.99:3128" -e "show databases;"

			Code by kermit.yao @ centos 7.6, 2023-07-18, kermit.yao@qq.com

EOF
    return 0
}

#解析参数,传入参数: $1 = "$@"
getArgs() {
    argsStatus=1
    while test $# != 0
    do
        case "$1" in
            -h|--help) argHelp=1;;
            -d|--download) 
                argDown=1
		        argDownValueDefault=l
                tmpVar=$(echo "$2" | grep "^-")
                if [ -n "$tmpVar" ]
                then
                    argDownValue=$argDownValueDefault
                elif [ -z "$2" ]
                then
                    argDownValue=$argDownValueDefault
                else
                    argDownValue=$2
                fi
                ;;

            -u|--upgrade)
                argUpgrade=1
                argUpgradeValueDefault=u
                tmpVar=
                tmpVar=$(echo "$2" | grep "^-")
                if [ -n "$tmpVar" ]
                then
                    argUpgradeValue=$argUpgradeValueDefault
                elif [ -z "$2" ]
                then
                    argUpgradeValue=$argUpgradeValueDefault
                else
                    argUpgradeValue=$2
                fi
                ;;

            -b|--backup)
                argBackupData=1
                argBackupDataValueDefault=
                tmpVar=
                tmpVar=$(echo "$2" | grep "^-")
                if [ -n "$tmpVar" ]
                then
                    argBackupDataValue=$argBackupDataValueDefault
                elif [ -z "$2" ]
                then
                    argBackupDataValue=$argBackupDataValueDefault
                else
                    argBackupDataValue=$2
                fi
		        ;;
            -r|--restore)
                argRestoreData=1
                tmpVar=
                tmpVar=$(echo "$2" | grep "^-")
                if [ -n "$tmpVar" ]
                then
                    argRestoreDataValue=
                elif [ -z "$2" ]
                then
                    argRestoreDataValue=
                else
                    argRestoreDataValue=$2
                fi
                ;;
            -m|--modify)
                argModifyIp=1
                argModifyIpValue=$1
            	;;
            -c|--clean) argClean=1;;
            -s|--status) argStatusInfo=1;;
            -l|--log) argLog=1;;
            -p|--proxy)
                argProxy=1
                argProxyValueDefault=
                argProxyValue=$argProxyValueDefault
                tmpVar=
                tmpVar=$(echo "$2" | grep "^-")
                if [ -n "$tmpVar" ]
                then
                    argProxyValue=
                elif [ -z "$2" ]
                then
                    argProxyValue=
                else
                    argProxyValue=$2
                fi
                ;;
            --setpw)
                argSetpw=1
                argSetpwValueDefault="360Epp1234.default"
                tmpVar=
                tmpVar=$(echo "$2" | grep "^-")
                if [ -n "$tmpVar" ]
                then
                    argSetpwValue=$argSetpwValueDefault
                elif [ -z "$2" ]
                then
                    argSetpwValue=$argSetpwValueDefault
                else
                    argSetpwValue=$2
                fi
                ;;
            --setSafe) argSetSafe=1;;
            --getInstPkg) argGetInstPkg=1;;
            -e|--exec) 
                argExec=1
                argExecValueDefault=
                tmpVar=
                tmpVar=$(echo "$2" | grep "^-")
                if [ -n "$tmpVar" ]
                then
                   argExecValue=$argSetpwValueDefault
                elif [ -z "$2" ]
                then
                    argExecValue=$argSetpwValueDefault
                else
                   argExecValue=$2
                fi
                
                ;;
            -f|--force) argForce=1;;
            -v|--version) argVersion=1;;
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
            #echo $i = ${tmp}
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
    if [ -n "${argProxyValue}" ]
    then
        printLog $LINENO INFO enableProxy "开启代理."
        export http_proxy=${argProxyValue}
        export https_proxy=${argProxyValue}
    else
        printLog $LINENO ERROR enableProxy "并未设置代理服务器信息."
    fi
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

#获取code信息
function getCodeInfo() {
    #清空变量
    ver=
    code=
    sn=
    md5=
    name=
    verAllInfo=
    if [[ -f "$1" && ! -z "$2" ]]
    then
        ver=$(cat $1 | sed 's/ //g' |sed -n '/\['$2'.*\]/,/\[.*\]/p'|awk -F':' '/ver/ {print $2}')
        code=$(cat $1 | sed 's/ //g' |sed -n '/\['$2'.*\]/,/\[.*\]/p'|awk -F':' '/code/ {print $2}')
        sn=$(cat $1 | sed 's/ //g' |sed -n '/\['$2'.*\]/,/\[.*\]/p'|awk -F':' '/sn/ {print $2}')
        md5=$(cat $1 | sed 's/ //g' |sed -n '/\['$2'.*\]/,/\[.*\]/p'|awk -F':' '/md5/ {print $2}')
        name=$(cat $1 | sed 's/ //g' |sed -n '/\['$2'.*\]/,/\[.*\]/p'|awk -F':' '/name/ {print $2}')
        verAllInfo=$ver:$code:$sn:$md5:$name
        return 0
    else
        return 1
    fi
}

function getCodeArry() {

    #下载版本信息
    fileDownload "$1" "$2" >/dev/null 2>&1

    if [ ! $? -eq 0 ]
    then
        echo 版本信息下载失败.
        return 1
    fi

    instInfoArry=
    tmpNum=0
    if [ ! -f "$2" ]
    then
        return 0
    fi

    for i in $(cat "$2" | grep -E '^\[.*\]' | sed  's/\[//g;s/\]//g'|awk -F'_' '{print $1}')
    do  
        getCodeInfo "$2" $i
        if [ $?!=1 ]
        then
            if [ -n "${verAllInfo}" ]
            then
                instInfoArry[$tmpNum]=$verAllInfo
                tmpNum=$[$tmpNum + 1]
            fi
        fi
    done
    if [ -n "${instInfoArry}" ]
    then
        return 0
    else
        return 1
    fi
}

setSafe() {

    #禁用root远程登录
    printf "禁用root远程登录 "
    if [ -f '/etc/ssh/sshd_config' ]
    then
        cat /etc/ssh/sshd_config|grep '^PermitRootLogin.*no'  >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #关闭DNS反向解析
    printf "关闭DNS反向解析 "
    if [ -f '/etc/ssh/sshd_config' ]
    then
        cat /etc/ssh/sshd_config|grep '^UseDNS.*no' >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i 's/.*UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #开启密码过期时间
    printf "开启密码过期时间 60 天 "
    if [ -f '/etc/login.defs' ]
    then
        cat /etc/login.defs|grep '^PASS_MAX_DAYS.*60' >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i 's/.*PASS_MAX_DAYS.*/PASS_MAX_DAYS 60/g' /etc/login.defs
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #开启密码长度 9 位
    printf "开启密码长度 9 位 "
    if [ -f '/etc/login.defs' ]
    then
        cat /etc/login.defs|grep '^PASS_MIN_LEN.*9' >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i 's/.*PASS_MIN_LEN.*/PASS_MIN_LEN  9/g' /etc/login.defs
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #开启密码尝试次数  3 次
    printf "开启密码尝试次数 3 次 "
    if [ -f '/etc/pam.d/system-auth' ]
    then
        lineNum=$(cat /etc/pam.d/sshd |grep -n "^auth"|head -n1|awk -F: '{print $1}')
        cat /etc/pam.d/system-auth|grep '^auth.*required.*pam_tally2.so.*' >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i "$lineNum i\auth    required    pam_tally2.so   onerr=fail deny=3 unlock_time=600 even_deny_root root_unlock_time=600" /etc/pam.d/sshd
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #新建用户
    cat /etc/passwd|grep "360epp" >/dev/null || useradd 360epp 
    if [ $? -eq 0 ]
    then
        printf '修改密码为： 360Epp1234.'
        echo "360Epp1234." |passwd --stdin 360epp >/dev/null
        if [ $? -eq 0 ]
        then
            echo 成功.
            #添加 sudo 权限
            printf "添加 sudo 权限 "
            if [ -f '/etc/sudoers' ]
            then
                cat /etc/sudoers|grep '^360epp.*ALL=(.*).*' >/dev/null
                if [ $? -ne 0 ]
                then
                    echo '360epp   ALL=(ALL)   ALL' >>/etc/sudoers
                    if [ $? -ne 0 ]
                    then
                        echo 失败,配置过程失败.
                    else
                        echo 成功.
                    fi
                else
                    echo 成功.
                fi
            else
                echo 失败,配置文件未找到.
            fi
        else
            echo 密码修改失败
        fi
    else
        echo 创建用户失败
    fi

}

getSecureInfo() {
    tmpNum=0
    secuTmpPath="$tempPath/secuTmpUserList5q.txt"
    lastb|tail -n 5000 >$secuTmpPath
    secuUserList=$(cat $secuTmpPath|grep "-"|awk '{print $1}')
    secuUserListNoRePeat=$(cat $secuTmpPath|grep "-"|awk '{print $1}'|sort -u)
    for i in $secuUserListNoRePeat
    do
        loginUserArry[$tmpNum]="$i:$(echo $secuUserList|tr ' ' '\n'|grep -w "^$i"|wc -l)"
        tmpNum=$[$tmpNum + 1]
    done
    tmpNum=0
    for i in $(echo ${loginUserArry[*]}|tr ' ' '\n'|sort -t ':' -k 2nr -k 1r)
    do
        loginUserArry[$tmpNum]=$i
        tmpNum=$[$tmpNum + 1]
    done
    #echo 数组长度: ${#loginUserArry[@]}
    #echo 数组内容: ${loginUserArry[@]:0:10}
}

getInstStatus() {
    instStatus=True
    cdb=$baseDir/cactus-web/system/safe-cactus/application/config/production/conf/db.json
    dbpwd=""
    dbHost=""
    server_ip=""
    command -v docker >/dev/null||instStatus=False
    command -v docker-compose >/dev/null||instStatus=False
    test -f $baseDir/cactus-web/system/safe-cactus/version||instStatus=False
    filterContainerList="cactus-nginx lcsd-nginx-1 cactus-web mysql cactus-newtransserver"
    if [ "$instStatus" == "False" ]
    then
        return 1
    fi
    nowContainerList=$(docker inspect -f {{.Name}} $(docker ps|awk '{print $1}'|grep -v CONTAINER))
    for fc in $filterContainerList
    do
        instStatus=False
        for nc in $nowContainerList
        do
            if [ "/$fc" = "$nc" ]
            then
                #echo match - $nc
                instStatus=True
            fi
        done
        if [ "$instStatus" = "False" ]
        then
            break
        fi
    done

    if [ "$instStatus" == "True" ]
    then
        if [ -f $cdb ]
        then
            dbUser='cactus'
            dbPwd=$(echo $(cat $baseDir/cactus-web/system/safe-cactus/application/config/production/conf/db.json) | sed "s# ##g" | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}'| grep -Po '"password":".*?"'| awk -F '"' '{print $4}')
            dbHost=$(echo $(cat $cdb) | sed "s# ##g"  | grep -Po '"mysql":{.*?}' | grep -Po '"master":{.*?}' | grep -Po '"ip":".*?"' | awk -F '"' '{print $4}')
            serverIp=$(echo $(cat $cdb) | sed "s# ##g" | grep -Po '"local_server":".*?"' | awk -F '"' '{print $4}' )
        fi
    else
        return 1
    fi
    if [[ "$serverIp" == "" && -f $base_dir/cascade-server/application-test.yml ]]
    then
        serverIp=$(cat $baseDir/cascade-server/application-test.yml | grep "current_ip" | sed "s# ##g" | awk -F ':' '{print $2}')
    fi
    if [ -f $baseDir/cactus-web/system/safe-cactus/version ]
    then
        nowVersion=$(grep 'sv=' $baseDir/cactus-web/system/safe-cactus/version  | sed "s#sv=##" | tr -cd "[0-9+].[0-9+].[0-9+].[0-9+]\-[0-9+].[0-9+].[0-9+].[0-9+]")
    fi
}

getTmpVer() {
    tmpVer=
    tmpCode=
    tmpSn=
    tmpMd5=
    tmpName=
    if [ -n "$1" ]
    then
        # $1 = ver, $2 = code, $3 = sn, $4 = md5, $5 = name
        #echo ${instInfoArry[-1]}|awk -F':' '{print $5}'
        tmpVer=$(echo $1|awk -F':' '{print $1}')
        tmpCode=$(echo $1|awk -F':' '{print $2}')
        tmpSn=$(echo $1|awk -F':' '{print $3}')
        tmpMd5=$(echo $1|awk -F':' '{print $4}')
        tmpName=$(echo $1|awk -F':' '{print $5}')
        return 0
    else
        return 1
    fi
}

getVersionFull() {
    echo ${1//./}

}

upgradeFileDown() {
    if [ -z "$1" ]
    then
        printLog $LINENO ERROR upgradeFileDown "传入参数有误."
    elif [ "$1" == "l" ]
    then
        getCodeArry "${updateUrlPath}/${codeInfoName}" "${tempPath}/update_${codeInfoName}"
        if [ $? -eq 0 ]
        then
            echo $testLine
            echo
            for i in ${instInfoArry[@]}
            do
                getTmpVer $i
                if [ $? -eq 0 ]
                then
                    echo     "$tmpVer:$tmpName:$tmpCode"
                fi
            done
            echo
            echo 下载升级文件使用: $0 -d 版本号
            echo 版本号可以是完整的版本号如: $tmpVer, 或者版本的最后一部分也可以,如: $(echo $tmpVer|cut -d '.' -f 4)
            echo $testLine
            return 0
        else
            printLog $LINENO ERROR upgradeFileDown "获取升级文件列表失败."
            return 1
        fi
    else
        echo "$1"| grep -E ".*[0-9]+$" >/dev/null
        if [ $? -eq 0 ]
        then
            getCodeArry "${updateUrlPath}/${codeInfoName}" "${tempPath}/update_${codeInfoName}"
            if [ $? -eq 0 ]
            then
                tmpFlag=
                for i in ${instInfoArry[@]}
                do
                    getTmpVer $i
                    if [ $? -eq 0 ]
                    then
                        echo $tmpVer| grep -E ".*${1}$" >/dev/null
                        if [ $? -eq 0 ]
                        then
                            tmpFlag=1
                            echo $testLine
                            echo
                            echo  "    版本: $tmpVer"
                            echo  "    code: $tmpCode"
                            echo  "      sn: $tmpSn"
                            echo  "     MD5: $tmpMd5"
                            echo "下载路径: ${tempPath}/$tmpName"
                            echo
                            echo $testLine
                            printLog $LINENO INFO upgradeFileDown "开始下载升级安装包..."
                            fileDownload "${updateUrlPath}/$tmpName" "${tempPath}/$tmpName"
                            if [ $? -eq 0 ]
                            then
                                printLog $LINENO INFO upgradeFileDown "检查文件完整性."
                                localMd5=$(md5sum "${tempPath}/$tmpName" | cut -d ' ' -f 1)
                                if [ "$tmpMd5" == "$localMd5" ]
                                then
                                    printLog $LINENO INFO upgradeFileDown "MD5对比一致,文件下载正常"
                                else
                                    printLog $LINENO INFO upgradeFileDown "MD5对比不一致,文件下载异常"
                                    return 1
                                fi
                            else
                                printLog $LINENO ERROR upgradeFileDown "下载升级包失败,请检查网络."
                                return 1
                            fi
                        fi
                    fi
                done
                if [ "$tmpFlag" != "1" ]
                then
                    printLog $LINENO ERROR upgradeFileDown "未找到指定的版本: [ $1 ],请使用以下命令获取版本列表: $0 -d l"
                    return 1
                fi
            else
                printLog $LINENO ERROR upgradeFileDown "获取版本列表失败"
                return 1
            fi
        else
            printLog $LINENO ERROR upgradeFileDown "版本输入有误,请检查: [ ${1} ]."
            return 1
        fi
    fi
}

upgradeVersion() {
    if [ "$1" == "u" ]
    then
        upgradeVersionNext
        if [ $? -eq 0 ]
        then
            return 0
        else
            return 1
        fi

    elif [ "$1" == "a" ]
    then
        nowVersionFull=0
        lateVersionFull=1
        while true
        do
            upgradeVersionNext
            if [ $? -eq 0 ]
            then
                if [ $nowVersionFull -ge $lateVersionFull ]
                then
                    printLog $LINENO INFO upgradeVersion "已经更新到最新版本."
                    break
                fi
            else
                printLog $LINENO ERROR upgradeVersion "版本更新出现错误,请联系相关人员."
                return 1
            fi
        done
        return 0

    else
        echo "$1"| grep -E ".*[0-9]+$" >/dev/null
        if [ $? -eq 0 ]
        then
            getCodeArry "${updateUrlPath}/${codeInfoName}" "${tempPath}/update_${codeInfoName}"
            if [ $? -eq 0 ]
            then
                tmpFlag=
                for i in ${instInfoArry[@]}
                do
                    getTmpVer $i
                    if [ $? -eq 0 ]
                    then
                        echo $tmpVer| grep -E ".*${1}$" >/dev/null
                        if [ $? -eq 0 ]
                        then
                            tmpFlag=1
                            userVersion=$tmpVer
                            break
                        fi
                    fi
                done
                if [ "$tmpFlag" != "1" ]
                then
                    printLog $LINENO WARNING upgradeVersion "未找到指定的版本: $1,请使用以下命令获取版本列表: $0 -d l"
                    return 1
                fi
            else
                printLog $LINENO WARNING upgradeVersion "获取版本列表失败."
                return 1
            fi
        else
            printLog $LINENO WARNING upgradeVersion "输入的版本号错误"
            return 1
        fi

        nowVersionFull=0
        userVersionFull=${userVersion//./}
        while true
        do
            upgradeVersionNext
            if [ $? -eq 0 ]
            then
                if [ $nowVersionFull -ge $userVersionFull ]
                then
                    printLog $LINENO INFO upgradeVersion "已经更新到指定版本."
                    break
                fi
            else
                printLog $LINENO ERROR upgradeVersion "版本更新出现错误,请联系相关人员."
                return 1
            fi
        done
    fi
    return 0
}

upgradeVersionNext() {
    getInstStatus
    if [ $instStatus == False ]
    then
        printLog $LINENO INFO versionNext "未安装EPP控制台,或已损坏."
        return 1
    fi
    nowVersionFull=${nowVersion//./}
    getCodeArry "${updateUrlPath}/${codeInfoName}" "${tempPath}/update_${codeInfoName}"
    if [ $? -eq 0 ]
    then
        getTmpVer ${instInfoArry[-1]}
        if [ $? -eq 0 ]
        then
            lateVersionFull=${tmpVer//./}
        fi
        if [ $nowVersionFull -ge $lateVersionFull ]
        then
            printLog $LINENO INFO versionNext "已是最新版本,无需更新."
            return 0
        else
            #寻找可升级的版本
            for i in ${instInfoArry[@]}
            do
                tmpFlag=0
                getTmpVer $i
                nameVersion=$(echo ${tmpName}|sed 's/\.sh//g;s/updatepkg\.//g;s/\.//g')
                startVersionFull=$(echo ${nameVersion}|cut -d '-' -f 1)
                endVersionFull=$(echo ${nameVersion}|cut -d '-' -f 2)
                if [ $nowVersionFull -ge $startVersionFull ] && [ $nowVersionFull -lt $endVersionFull ]
                then
                    tmpFlag=1
                    endVersion=$(echo ${tmpName}|sed 's/\.sh//g;s/updatepkg\.//g'|cut -d '-' -f 2)
                    break
                fi
            done
            if [ "$tmpFlag" == "0" ]
            then
                printLog $LINENO WARNING versionNext "未能找到匹配的可升级版本,请联系相关人员."
                return 1
            else

                if [ "$argForce" != "1" ]
                then
                    echo 
                    echo "当前版本: ${nowVersion}, 升级后版本: $endVersion"
                    echo
                    printf '\33[5m \33[33m以上操作无法恢复,如果您不知道会造成什么后果,请立即退出!!!\033[0m\n'
                    echo
                    read -p '确定执行此操作? < yes/no >: ' input
                    if [ "${input}" != "yes" ]
                    then
                        return 7
                    fi
                fi

                echo -e "升级版本: ${nowVersion} > $endVersion, MD5:${tmpMd5}"
                printLog $LINENO INFO versionNext "开始下载升级包..."
                fileDownload "${updateUrlPath}/$tmpName" "${tempPath}/$tmpName"
                if [ $? -eq 0 ]
                then
                    printLog $LINENO INFO versionNext "安装包下载完成."
                    printLog $LINENO INFO versionNext "检查文件完整性."
                    localMd5=$(md5sum "${tempPath}/$tmpName" | cut -d ' ' -f 1)
                    if [ "$tmpMd5" == "$localMd5" ]
                    then
                        printLog $LINENO INFO versionNext "MD5对比一致,文件下载正常"
                        printLog $LINENO INFO versionNext "开始升级版本..."
                        echo ${tmpCode}|sh ${tempPath}/$tmpName | tee -a "${logPath}"
                        getInstStatus
                        nowVersionFull=${nowVersion//./}
                        if [ "${nowVersionFull}" -eq "$endVersionFull" ]
                        then
                            return 0
                        else
                            return 1
                        fi
                    else
                        printLog $LINENO ERROR versionNext "MD5对比不一致,文件下载异常"
                        return 1
                    fi
                else
                    printLog $LINENO ERROR versionNext "下载安装包失败,请检查网络."
                    return 1
                fi
            fi
        fi
    else
        echo 获取版本列表失败
        return 1
    fi
}

#清理EPP安装环境
cleanEnv() {
	command -v docker >/dev/null
	if [ $? -eq 0 ]
	then
:<<NOTES
        printLog $LINENO INFO cleanEnv "清理 docker 容器"
		containerList=$(docker container ls -aq)
		if [ -n "$containerList" ]
		then
			docker container stop $containerList
			docker container rm $containerList
		fi

        printLog $LINENO INFO cleanEnv "清理 docker 镜像"
		imagesList=$(docker image ls -aq)
		if [ -n "$imagesList" ]
		then
			docker image rm $imagesList
		fi

		#卸载docker组件
        printLog $LINENO INFO cleanEnv "卸载docker组件"
		systemctl stop docker
		rpm -e $(rpm -qa docker*)
NOTES

        #清理docker-compose目录
        printLog $LINENO INFO cleanEnv "清理docker-compose容器"
        dockerComposePath="/home/s"
        if [ -f $dockerComposePath/lcsd/docker-compose.yml ]
        then
            docker-compose -f $dockerComposePath/lcsd/docker-compose.yml down
            sleep 1
            rm -rf $dockerComposePath
        fi
	else
		echo docker 未安装
        printLog $LINENO WARNING cleanEnv "docker 未安装"
	fi


	#清理docker数据目录
    printLog $LINENO INFO cleanEnv "清理 docker 目录"
	#rm -rf /data/docker /data/var_lib_docker /data/monitor
    rm -rf /data/docker /data/monitor
}

execSql() {
    dbHost=$1
    dbPwd=$2

    if [[ "$dbHost" = "" || "$dbPwd" = "" ]]
    then
        printLog $LINENO ERROR execSql "数据库参数错误!"
        return 1
    fi

    if [ -n "$argExecValue" ]
    then
        docker exec -it cactus-web mysql --default-character-set=utf8 -h${dbHost} -ucactus -p${dbPwd} -e "$argExecValue"
        printLog $LINENO DEBUG execSql "docker exec -it cactus-web mysql --default-character-set=utf8 -h${dbHost} -ucactus -p${dbPwd} -e $argExecValue" 0
    else
        docker exec -it cactus-web mysql --default-character-set=utf8 -h${dbHost} -ucactus -p${dbPwd}
        printLog $LINENO DEBUG execSql "docker exec -it cactus-web mysql --default-character-set=utf8 -h${dbHost} -ucactus -p${dbPwd}" 0
    fi
    return $?
}

restoreDB() {
    dbHost=$1
    dbPwd=$2
    restoreName=$3

    if [[ "$dbHost" = "" || "$dbPwd" = "" || "$restoreName" = "" ]]
    then
        printLog $LINENO ERROR restoreDB "数据库参数错误!"
        return 1
    fi

    backupCheck "$restoreName"
    if [ "$?" != "0" ]
    then
        printLog $LINENO ERROR restoreDB "还原数据失败,指定的数据库内容错误."
        return 1
    fi
    if [ -f "$restoreName" ]
    then
        printf "正在还原mysql数据库\033[5m ... \033[0m"
        docker exec -i cactus-web mysql --default-character-set=utf8 -h${dbHost} -ucactus -p${dbPwd}  cactus < "$restoreName"
        printf "\r正在还原mysql数据库 ...\n"
    fi
    return $?
}

backupDB() {
    dbHost=$1
    dbPwd=$2
    backupName=$3

    if [[ "$dbHost" = "" || "$dbPwd" = "" || "$backupName" = "" ]]
    then
        printLog $LINENO ERROR backupDB "数据库参数错误!"
        return 1
    fi

    ignore_tables="--ignore-table=cactus.log_report_kb_leak_statistics --ignore-table=cactus.log_report_kb_detail_statistics --ignore-table=cactus.360exthost_quarant_log"
    ignore_tables="${ignore_tables} --ignore-table=cactus.360exthost_360sdmgr_setting_log --ignore-table=cactus.kb_total_history --ignore-table=cactus.monitor_info"
    ignore_tables="${ignore_tables} --ignore-table=cactus.360exthost_pluginmgr_log --ignore-table=cactus.360edr_hotpatch_log --ignore-table=cactus.360leakfix_system_log"
    ignore_tables="${ignore_tables} --ignore-table=cactus.360leakfix_system --ignore-table=cactus.360exthost_softmgr --ignore-table=cactus.360exthost_softmgr_log"

    if [ ! -f "$backupName" ]
    then
        printf "正在备份mysql数据库\033[5m ... \033[0m"
        docker exec -i cactus-web mysqldump --single-transaction ${ignore_tables} -h${dbHost} -ucactus -p${dbPwd} cactus >$backupName
        printf "\r正在备份mysql数据库 ...\n"
    fi

    backupCheck "$backupName"
    return $?
}

#检查数据库是否正确
backupCheck() {
    if [ -f "$1" ]
    then
        backupCheck=$(head -n 6 $1|grep "mysql"|grep "cactus")
        if [ -n "$backupCheck" ]
        then
            return 0
        fi
    else
        return 1
    fi

    return 1
}

#修改EPP管理员密码
setpw() {
    getInstStatus
    if [ $? = 0 ]
    then
        eppPwdInfo=$(docker exec -it cactus-web php /home/q/system/safe-cactus/application/script/ResetPassword.php)
        eppPwdInfo=$(echo $eppPwdInfo|grep "："|awk '{print $2}')
	    return $?
    fi

    return 1
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

    #是否已安装EPP控制台
    getInstStatus
    if [ $? -eq 0 ]
    then
        echo "$productName安装状态: 正常"
    else
        echo "$productName安装状态: 异常"
    fi

    echo "$productName安装版本: $nowVersion"
    echo "安装IP: $serverIp"

    echo "数据库账号密码:$dbUser/$dbPwd"
    echo "容器列表状态:"
    if [ "$instStatus" == "True" ]
    then
        for i in $nowContainerList
        do
            #echo -e "name:$i \t\t\t\t\t status:$(docker inspect -f {{.State.Status}} $i) \t\t\t port:$(docker inspect -f {{.HostConfig.PortBindings}}  $i)"
            status=$(docker inspect -f {{.State.Status}} $i)
            port=$(docker inspect -f {{.HostConfig.PortBindings}}  $i)
            printf "\t容器:%-30s 状态:%-10s 端口:%-10s\n" "$i" "$status" "$port"
        done
    fi
    echo ${testLine}
    #计算内存使用百分比
    #memTotal=$(head -v -n 8 /proc/meminfo|grep "MemTotal:"|awk '{print $2}')
    #memAvailable=$(head -v -n 8 /proc/meminfo|grep "MemAvailable:"|awk '{print $2}')
    #memUsed=$[(memTotal-memAvailable)/1024]
    #memTotal=$[memTotal/1024]

    memTotal=$(free -m|grep "^Mem:"|awk '{print $2}')
    memUsed=$(free -m|grep "^Mem:"|awk '{print $3}')
    memPercent=$(awk -v x=$memUsed -v y=$memTotal 'BEGIN {printf "%.2f\n", x / y* 100 }')
    echo "启动时间:            $(uptime -s)"
    echo "内存使用(已用/总量): $memUsed MB / $memTotal MB; $memPercent %"

    #计算CPU使用百分比
    sleep 0.2
    s=$(head -n 1 /proc/stat);totalOld=$(echo $s|awk '{for(i=2;i<12;i++){t=t+$i};{print t}}');idleOld=$(echo $s|awk '{print $5}')
    sleep 2
    s=$(head -n 1 /proc/stat);totalNew=$(echo $s|awk '{for(i=2;i<12;i++){t=t+$i};{print t}}');idleNew=$(echo $s|awk '{print $5}')
    cpuPercent=$(awk -v idleOld=$idleOld -v idleNew=$idleNew -v totalOld=$totalOld -v totalNew=$totalNew 'BEGIN {printf "%.2f\n", (1 - (idleNew - idleOld) / (totalNew - totalOld)) * 100}')

    echo "CPU使用信息:         $cpuPercent %"
    echo "存储信息:"

    #修改默认分隔符
    IFSOLD=$IFS
    IFS=$'\n'
    for i in $(df -h|grep "^/dev")
    do
        echo -e "\t$i"
    done
    IFS=$IFSOLD
    echo ${testLine}
    printf "正在统计登录信息,时间取决于被攻击的次数(只对最后5000次的登录情况进行统计)\033[5m ... \033[0m"
    getSecureInfo
    printf "\r正在统计登录信息,时间取决于被攻击的次数(只对最后5000次的登录情况进行统计) ... \n"
    echo "登录失败用户数: ${#loginUserArry[@]}"
    echo "登录失败用户TOP10(用户:失败次数): ${loginUserArry[@]:0:10}"
    echo ${testLine}
    echo "  主机名称: $(hostname)"
    echo IP地址列表: $(hostname -I)


    echo "    包管理: ${packageType}"
    echo "  内核信息: $(uname -a)"

	if [ -f /etc/os-release ]
	then
		releaseVersion=$(cat /etc/os-release |grep '^ID='|awk -F= '{print $2}'&&cat /etc/os-release |grep '^VERSION_ID='|awk -F= '{print $2}')
        releaseVersion=$(echo $releaseVersion|sed 's/\n//g')
	fi
    echo "  发行版本: ${releaseVersion//'"'}"
    echo 内核安装信息:
    for i in $($searchCommand *kernel*)
    do
        echo -e "\t$i"
    done
    echo "脚本参数: ${srcArgs}"
}

# --------------func-------------------------

#脚本入口点
main() {

    if [ "$srcArgs" = "" ]
    then
        getCuiHelp
    fi
    if [ ! "$srcArgs" = "" ]
    then
        getArgs "$@"
        if [ $? != 0 ]
        then
            printLog $LINENO WARNING main "Invalid input:[${srcArgs}]"
            echo "Use [--help] to print infomation for help."
        fi
    else
        printLog $LINENO WARNING main "参数无效,退出当前脚本."
        return 99
    fi

    #关闭日志打印
    if [ "${argLog}" = "1" ]
    then
        logLevel="FALSE"
    fi

    #打印帮助信息 
    if [ "$argHelp" = "1" ]
    then
        printLog $LINENO INFO main "打印帮助信息."
        getCuiHelp
        exit 0
    fi

    #打印当前版本
    if [ "${argVersion}" = "1" ]
    then
        printLog $LINENO INFO getVersion "当前版本: $scriptVersion"
    fi

    #开启http 代理
    if [ "${argProxy}" = "1" ]
    then
        printLog $LINENO INFO setProxy "配置代理信息."
        enableProxy ${httpProxy}
    fi

    #版本升级
    if [ "$argUpgrade" == "1" ]
    then
        printLog $LINENO INFO upgradeVersion "版本升级."
        if [ $userID -ne 0 ]
        then
            printLog $LINENO INFO upgradeVersion "需要root权限才能使用此功能: sudo bash $0 $*"
        else
            upgradeVersion $argUpgradeValue
            if [ $? -eq 0 ]
            then
                printLog $LINENO INFO upgradeVersion "版本升级成功."
            else
                printLog $LINENO ERROR upgradeVersion "版本升级失败."
            fi
            return 0
        fi
    fi

    #备份数据库
    if [ "$argBackupData" = "1" ]
    then
        printLog $LINENO INFO backupDB "备份数据库."
        if [ $userID -ne 0 ]
        then
            printLog $LINENO INFO backupDB "需要root权限才能使用此功能: sudo bash $0 $*"
        else
            getInstStatus
            if [ "$instStatus" == "True" ]
            then
                if [ -n "$argBackupDataValue" ]
                then
                    dbPath="$argBackupDataValue"
                else
                    formatTime=$(date +%Y%m%d%H%M%S)
                    dbPath="cactus_${formatTime}_${nowVersion//./}.bak"
                fi
                backupDB "$dbHost" "$dbPwd" "$dbPath"
                if [ "$?" == "0" ]
                then
                    printLog $LINENO INFO backupDB "数据库备份成功:[${dbPath}]."
                else
                    printLog $LINENO ERROR backupDB "数据库备份失败."
                fi
            else
                printLog $LINENO WARNING backupDB "EPP未安装或安装错误,数据库备份失败."
            fi
        fi
    fi

    if [ "$argDown" == "1" ]
    then
            printLog $LINENO INFO upgradeDownload "获取升级文件."
            upgradeFileDown $argDownValue
    fi

    #还原数据库
    if [ "$argRestoreData" = "1" ]
    then
        printLog $LINENO INFO RestoreDB "还原数据库."
        if [ $userID -ne 0 ]
        then
            printLog $LINENO INFO RestoreDB "需要root权限才能使用此功能: sudo bash $0 $*"
        else
            getInstStatus
            if [ "$instStatus" == "True" ]
            then
                if [ -f "$argRestoreDataValue" ]
                then
                    dbPath="$argRestoreDataValue"

                    if [ "$argForce" == "1" ]
                    then
                        restoreDB "$dbHost" "$dbPwd" "$dbPath"
                    else
                        echo
                        echo 此操作将会删除以下内容:
                        echo
                        echo "    1.覆盖现有配置信息"
                        echo "    2.覆盖现有防护日志"
                        echo
                        printf '\33[5m \33[33m以上操作无法恢复,如果您不知道会造成什么后果,请立即退出!!!\033[0m\n'
                        echo
                        read -p '确定执行此操作? < yes/no >: ' input
                        if [ "${input}" == "yes" ]
                        then
                            restoreDB "$dbHost" "$dbPwd" "$dbPath"
                        fi
                    fi
                    
                    if [ "$exitCode" == "0" ]
                    then
                        printLog $LINENO INFO restoreDB "数据库还原成功."
                    else
                        printLog $LINENO ERROR restoreDB "数据库还原失败."
                    fi

                else
                    printLog $LINENO WARNING restoreDB "未指定数据库,或者指定的数据库无效,还原失败"
                fi
            else
                printLog $LINENO WARNING restoreDB "EPP未安装或安装错误,数据库还原失败."
            fi
        fi
    fi

    #进入执行mysql命令
    if [ "$argExec" = "1" ]
    then
        printLog $LINENO INFO execSql "执行数据库命令."
        if [ $userID -ne 0 ]
        then
            printLog $LINENO INFO execSql "需要root权限才能使用此功能: sudo bash $0 $*"
        else
            getInstStatus
            if [ "$instStatus" == "True" ]
            then
                execSql "$dbHost" "$dbPwd"
                if [ "$?" == "0" ]
                then
                    printLog $LINENO INFO execSql "执行命令成功"
                else
                    printLog $LINENO WARNING execSql "执行命令失败"
                fi
            else
                printLog $LINENO WARNING execSQL "EPP未安装或安装错误,执行mysql命令失败."
            fi
        fi
    fi
  
    #重置密码
    if [ "$argSetpw" == "1" ]
    then
        printLog $LINENO INFO setPassword "重置密码."
        if [ $userID -ne 0 ]
        then
            printLog $LINENO INFO setPassword "需要root权限才能使用此功能: sudo bash $0 $*"
        else
            if [ "$argForce" == "1" ]
            then
                setpw
            else
                echo
                echo 此操作将会做如下修改:
                echo
                echo "    1.将 eppadmin 密码重置"
                echo "    2.重置后将无法使用之前的密码进行登录"
                echo
                printf '\33[5m \33[33m以上操作无法恢复,如果您不知道会造成什么后果,请立即退出!!!\033[0m\n'
                echo
                read -p '确定执行此操作? < yes/no >: ' input
                if [ "${input}" == "yes" ]
                then
                    setpw
                else
                    command -v !!! 2>/dev/null
                fi
            fi

            if [ $? -eq 0 ]
            then
                printLog $LINENO INFO setPassword "已成功重置密码: $eppPwdInfo"
            else
                printLog $LINENO WARNING setPassword "重置密码失败."
            fi
        fi
    fi

    #安全加固
    if [ "$argSetSafe" == "1" ]
    then
        printLog $LINENO INFO setSafe "安全加固."
        if [ $userID -ne 0 ]
        then
            printLog $LINENO INFO setSafe "需要root权限才能使用此功能: sudo bash $0 $*"
        else
            if [ "$argForce" == "1" ]
            then
                setSafe
            else
                echo
                echo 此操作将会做如下修改:
                echo
                echo "    1.禁止使用root进行ssh登录"
                echo "    2.开启密码过期 60 天"
                echo "    3.开启密码最小长度 9 位"
                echo "    4.开启密码尝试次数 3 次"
                echo "    5.新建 360epp用户,并指定初始密码为: 360Epp1234."
                echo
                printf '\33[5m \33[33m以上操作无法恢复,如果您不知道会造成什么后果,请立即退出!!!\033[0m\n'
                echo
                read -p '确定执行此操作? < yes/no >: ' input
                if [ "${input}" == "yes" ]
                then
                    setSafe
                fi
            fi
        fi
    fi

    #获取最新安装包
    if [ "$argGetInstPkg" == "1" ]
    then
        printLog $LINENO INFO getInstPkg "获取安装包."
        getCodeArry "${instUrlPath}/${codeInfoName}" "${tempPath}/inst_${codeInfoName}"
        if [ $? -eq 0 ]
        then
            getTmpVer "${instInfoArry[-1]}"
            echo $testLine
            echo
            echo  "    版本: $tmpVer"
            echo  "    code: $tmpCode"
            echo  "      sn: $tmpSn"
            echo  "     MD5: $tmpMd5"
            echo "下载路径: ${tempPath}/$tmpName"
            echo
            echo $testLine
            printLog $LINENO INFO getInstPkg "开始下载安装安装包..."
            fileDownload "${instUrlPath}/$tmpName" "${tempPath}/$tmpName"
            if [ $? -eq 0 ]
            then
                printLog $LINENO INFO getInstPkg "检查文件完整性."
                localMd5=$(md5sum "${tempPath}/$tmpName" | cut -d ' ' -f 1)
                if [ "$tmpMd5" == "$localMd5" ]
                then
                    printLog $LINENO INFO getInstPkg "MD5对比一致,文件下载正常"
                else
                    printLog $LINENO INFO getInstPkg "MD5对比不一致,文件下载异常"
                fi
            else
                printLog $LINENO ERROR getInstPkg "下载安装包失败,请检查网络."
            fi
        else
            printLog $LINENO ERROR getInstPkg "获取安装包失败,无法获取版本信息."
        fi
    fi

    #清理EPP安装环境
    if [ "$argClean" == "1" ]
    then
        printLog $LINENO INFO cleanEPP "清理EPP安装环境."
        if [ $userID -ne 0 ]
        then
            printLog $LINENO INFO cleanEPP "需要root权限才能使用此功能: sudo bash $0 $*"
        else
            if [ "$argForce" == "1" ]
            then
                cleanEnv
            else
                echo
                echo 此操作将会删除以下内容:
                echo
                echo "    1.删除所有docker-compose包含的容器"
                echo "    2.卸载掉所有docker开头的安装包 (rpm -qa docker*)"
                echo "    3.删除 /home/s, /data/docker, /data/mointor"
                echo
                printf '\33[5m \33[33m以上操作无法恢复,如果您不知道会造成什么后果,请立即退出!!!\033[0m\n'
                echo
                read -p '确定执行此操作? < yes/no >: ' input
                if [ "${input}" == "yes" ]
                then
                    cleanEnv
                fi
            fi
        fi
    fi

    #移除临时文件
    if [ "${argsRemove}" == "1" ]
    then
        printLog $LINENO INFO removeTempDir "删除临时文件."
        echo "${tempPath}/*"
        test -d "${tempPath}" && [ "$(echo "${tempPath}" | awk -F/ '{print $2}')" = "tmp" ] && rm -f ${tempPath}/*.{log,sh,tar.gz,txt}
    fi

    #获取系统状态
    if [ "${argStatusInfo}" == "1" ]
    then
        printLog $LINENO INFO getStatus "打印环境状态..."
        if [ $userID -ne 0 ]
        then
            printLog $LINENO INFO getStatus "需要root权限才能使用此功能: sudo bash $0 $*"
        else
            printStatus | tee -a "${logPath}"
        fi
    fi

}

main "$@"
exit $?