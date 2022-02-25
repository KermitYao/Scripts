#设置http代理
#如果是内网环境可以开一台代理服务器，通过代理来临时安装依赖环境。
#如果你不想使用代理服务器可以保持为空即可，或者注释掉即可。
#proxyServer=http://192.168.16.82:3128

#此地址是 agent安装脚本的下载地址，可以使用iis搭建服务器来发布。
agentScript=http://192.168.16.81:6080/Tmp/ESMCAgentInstaller.sh

#此地址是 杀毒软件的文件下载地址，可以使用iis搭建服务器来发布。
antivirusBin=http://192.168.16.81:6080/Tmp/efs.x86_64.bin

#如果是4.x的版本请开启此选项以解决依赖问题 （enabled|disabled）， 7.x安装包会自动解决依赖问题，所以并不需要。
depends=enabled
#-----------------------------------------------------

if [ $(id -u) != 0 ]
then 
    echo -------- You must use root. 
    exit 1
fi

set_proxy()
{
    export http_proxy=${proxyServer} https_proxy=${proxyServer}
}

down_install()
{
        for url in $agentScript $antivirusBin
        do
            fileName=$(mktemp -uq)
            echo -------- Download $fileName
            (wget --connect-timeout 300 --no-check-certificate -O "$fileName" "${url}"||curl --fail --connect-timeout 300 -kL "${url}" > "$fileName")
            if [ -f $fileName ]
            then
                echo -------- Install $fileName
                /bin/sh "$fileName" -y
                rm -f "$fileName"
            fi
        done
}

depends_install()
{
    grep "Red Hat" /proc/version 2>&1 > /dev/null
    if [ $? -eq 0 ]
    then
        yum install -y ld-linux.so.2 ed
    else
        apt-get install -y ld-linux.so.2 ed
    fi
}


if test -n "${proxyServer}"
then
    echo -------- Enable proxy.
    echo -------- proxy:${proxyServer}
    set_proxy
fi

if [ "$depends" = "enabled" ]
then
    echo -------- Installation dependency.
    depends_install
fi

down_install
exit

