#2020-08-22
#Code by kermit@Arch/Linux
#The script for backing up the system

excludeFiles='/dev /proc /mnt /tmp /lost+found'
backupPath='/'
backupFile=/mnt/sysBackup_$(date +%Y%m%d%H%M).tar.gz

#------------------
excludeTmp=/tmp/excludeTmp.tmp

function makeExclude () {
	echo >${excludeTmp}
	for i in  ${excludeFiles}
	do
		echo ${i} >>${excludeTmp}
	done
	
	if [ -f "${excludeTmp}" ];then
		echo 'Exclusion generated'
		return 0
	fi
	return 1

}

function makeBackup() {
	if [ ! -r "${backupPath}" ];then
		echo "Unable to read ${backupPath}"
		return 2
	fi

	if [ -f "${excludeTmp}" ];then
		tar -cvzpf ${backupFile} -X ${excludeTmp} ${backupPath}
	else
                tar -cvzpf ${backupFile} ${backupPath}
        fi
	return 0
}

makeExclude

echo "Exclude path:${excludeFiles}"
echo "Backup path:${backupPath}"
echo "Backup file name:${backupFile}"
read -r -p "Are You Sure? [Y/n] " input

case $input in
	[yY][eE][sS]|[yY])
	makeBackup
	;;

	[nN][oO]|[nN])
	exit 4
	;;

	*)
		echo "Invalid input..."
		exit 5
	;;
esac


if [ -f "${backupFile}" ];then
	echo 'Script execution completed'
        exit 0
else
	echo 'Failed'
	exit 3
fi
exit 99
