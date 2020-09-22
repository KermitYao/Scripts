#!/bin/bash
#发送快捷键给相应的程序

function printHelp() {
  cat <<EOF
  Usage: $(basename $0) [options]
    
    -h, --help         	[optional] print this help message
    -p, --process     	[optional] Program process name
    -k, --key	        [optional] Keys to send  
		Example:$(basename $0) -p "WeChat.exe" -k "Ctrl+Alt+W" 
	
                Kermit.yao@outlook.com 2020-08-23
         
EOF

}

function getArgs()
{
    while test $# != 0
    do
        case "$1" in
            -h|--help)
            printHelp
            exit 0
        ;;
        -p|--process)
            shift
            processName=$1
        ;;
            -k|--key)
            shift
            keyValue=$1
        ;;
        *)
        echo "Unknown option \"$1\". Run '$(basename $0) --help' for usage information." >&2
        exit 1
        ;;
      esac
      shift
    done
}

function sendKey() {
	echo Process:${1} -- Pid:${pid}-- Key:${2} 
	xdotool key --window $(xdotool search --limit 1 --all --pid ${pid}) ${2}
	echo Send keyed done.
}

if [ $# -gt 3 ];then
    getArgs $@
else   
    getArgs --help
    exit 1
fi

pid=$(pgrep ${processName})
if [[ 0"${processName}" = "0" ]] || [[ 0"${keyValue}" = "0" ]];then
	echo Error, Parameter error.
	exit 2
elif [[ 0"${pid}" =  "0" ]] ;then
	echo 'Error, PID must be a number;Process may not be found.'
else
	sendKey ${processName} ${keyValue}
fi
exit 0
