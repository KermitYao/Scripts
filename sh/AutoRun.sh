#/bin/bash
#
#自动执行本脚本目录下的 sh 脚本文件。
#
#

cd `dirname $0`
echo 当前目录 [`pwd`]。
listSh=$(ls *.sh 2>/dev/null)

if test -n "$listSh"
then
    for var in $listSh
    do
        if test $var != $(basename $0)
        then
            echo 执行脚本 [$var]
            ./$var >/dev/null 2>&1
        fi
    done
fi
echo 执行完成。
echo $(basename $0)
