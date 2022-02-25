#!/bin/sh

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
}

getProductVersion() {
    if [ $RPM_BASED -ne 0 ]
    then
        productVersion="$(dpkg-query --showformat='${Version}' --show efs 2>/dev/null)"
    else
        productVersion="$(rpm --queryformat "%{VERSION}" -q efs 2>/dev/null)"
    fi
    return 0
}

#传入参数: $1 = era配置文件路径, $2 = 安全产品配置文件路径
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

#传入参数: $1 = 文件路径, $2 = 类型(old or [new|null]) 
productInstall() {
    if [ "$2" != "old" ]
    then
        sh "$1" -y -f -g
        if [ "x" != "x${productVersion}"]
        then
            result=0
        else
            result=1
        fi
    else
        echo No something.
    fi
    return $result
}

#传入参数: $1 = 产品名称
productUninstall() {
    if [ $RPM_BASED -ne 0 ]
        productRemove="rpm -e $1"
    else
        productRemove="dpkg -r $1"
    fi
    $productRemove
    if [ "x" == "x${productVersion}" ]
    then
        result=0
    else
        result=1
    fi
    return $result
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
			echo Invalild input:[The content is empty!]
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
			echo Invalid input:[$port]
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
			echo Invalild input:[The content is empty!]
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
		echo $1
		localConfPath="$(mktemp -q -u)"
		grep  -v '\[ERA_AGENT_PROPERTIES\]' "$1" | sed 's/\r//' > $localConfPath && echo $localConfPath >> $cleanupFile
		. $localConfPath
		localCertPath="$(mktemp -q -u)"
		echo $P_CERT_CONTENT | base64 -d > $localCertPath && echo "$localCertPath" >> "$cleanupFile"
		if test -n "$P_CERT_AUTH_CONTENT"
		then
			localCaPath="$(mktemp -q -u)"
        		echo "$P_CERT_AUTH_CONTENT" | base64 -d > $localCaPath && echo "$localCaPath" >> "$cleanupFile"
		fi
	else
		return 1
	fi
}

#传入参数: $1 = 文件路径, $2 = 类型(cert or password) 
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

uninstallAgent()
{
    if [ -f $1 ] 
    then
    /bin/sh $1
    fi
    return $?
}

cleanup_file="$(mktemp -q)"
finalize()
{
  set +e
  if test -f "$cleanup_file"
  then
    while read f
    do
      rm -f "$f"
    done < "$cleanup_file"
    rm -f "$cleanup_file"
  fi
}

getPackageType
getConfValue ./conf.ini 
readUserInput
echo Print clean file information...
cat  $cleanupFile
echo install agent...
installAgent ./agent.sh password
echo Install status:  $? 

