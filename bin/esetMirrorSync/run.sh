#!/bin/sh

mirrorTool='MirrorTool'
mirrorPath=$(dirname $0)
currentDate=$(date "+%Y%m%d_%H%M%S")
mirrorLogDir='/var/log/esetMirrorSync'
mirrorLogFile=${mirrorLogDir}/${currentDate}.log

updateModule=False
updateRepository=False
#--------------------------------------------

#ESET数据存放目录
esetDate=/media/dataCenter/FILE/_Ubackup/ESET_Date

#自动选择服务器
downServer='--repositoryServer AUTOSELECT'
#存储库临时目录
repositoryTempPath="--intermediateRepositoryDirectory ${esetDate}/repositoryTemp"
#存储库路径
repositoryPath="--outputRepositoryDirectory ${esetDate}/repository"

#指定语言
language='--languageFilterForRepository zh_CN en_US'
#指定关键字
keyWord='--productFilterForRepository Antivirus File Management'

#----------------------------------------------

#病毒库类型 [regular | pre-release | delayed}
moduleType="--mirrorType regular"
#病毒库临时目录
moduleTempPath="--intermediateUpdateDirectory ${esetDate}/moduleTemp"
#病毒库目录
modulePath="--outputDirectory ${esetDate}/module"
#离线许可文件
offLicense="--offlineLicenseFilename ${mirrorPath}/mirrorTool-esetfilesecurityformicrosoftwindowsserver-0.lf"

#---------------------------


#------func------
printUsage()
{
  cat <<EOF
  Usage: $(basename $0) [options]
    
    -h, --help              [optional] print this help message
    -m, --module            [optional] Update virus library
    -r, --repository        [optional] Synchronize repositories  

                ESET NOD32 2020-03-19 , Yao
         
EOF
}

syncStart()
{
    if [ "${updateModule}" = 'True' ]
    then
        ${mirrorPath}/${mirrorTool} ${moduleType} ${moduleTempPath} ${modulePath} ${offLicense} | tee -a ${mirrorLogFile}
    fi

    if [ "${updateRepository}" = 'True' ]
    then
        	${mirrorPath}/${mirrorTool} ${downServer} ${repositoryTempPath} ${repositoryPath} ${language} ${keyWord} | tee -a ${mirrorLogFile}
    fi
    
}

getArgs()
{
    while test $# != 0
    do
      case "$1" in
        -h|--help)
          printUsage
          exit 0
          ;;
        -m|--module)
          updateModule=True
          ;;
        -r|--repository)
          updateRepository=True
          ;;
        *)
          echo "Unknown option \"$1\". Run '$(basename $0) --help' for usage information." >&2
          exit 1
          ;;
      esac
      shift
    done
}
#-----func-------

if [ $# -gt 0 ];then
    getArgs $@
else   
    getArgs --help
    exit 1
fi

if [ "`id -u`" != "0" ];then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo 
echo Synchronizing ESET installation files
echo 



#---------begin------------
#创建日志目录
if [ ! -d ${mirrorLogDir} ];then
	mkdir ${mirrorLogDir}
fi

if [ -f "${mirrorPath}/${mirrorTool}" ];then
        syncStart
else
	echo "[${mirrorTool}] cannot be found." | tee -a ${mirrorLogFile}
fi
echo -----------$(date)---------------|tee -a ${mirrorLogFile}
exit 0






