#!/bin/bash
#eset 文件自动打包

path="/data/file/backup/Company/YCH/EEAI/ESET"
zipName="CLIENT_$(date +%Y%m%d%H%M).zip"
allow="*"
exclude="*.sh_*.log *.sh *.bin_*.log *.bin"
cd ${path}
logPath="/var/log/kermit/$(basename $0).log"
find ./ -name "CLIENT_*.zip" -type f -mtime +3 | xargs rm -f

echo Compress data: $(date) >>${logPath}
for nameItem in $(find ./CLIENT -name "${allow}")
do
    flag="false"
    if [ -f ${nameItem} ];then	
        for excludeItem in ${exclude}
        do
            if [[ $(basename ${nameItem}) = ${excludeItem} ]];then
                flag="true"
                break	        
	    fi
        done
        if [ ${flag} = "false" ];then
            zip ${zipName} "${nameItem}" | tee -a ${logPath}
        fi
    else
        zip ${zipName} "${nameItem}" | tee -a ${logPath}
    fi
done
