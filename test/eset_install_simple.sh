#!/bin/sh
echo Install agent...
/bin/sh agentScriptInstall.sh
echo agent install status: $?
echo configuration source ...
mv /etc/apt/sources.list /etc/apt/sources.list.bak.eset
cp -f ./sources.list /etc/apt/sources.list
apt-get update
echo Install efs...
apt-get -f -y install ./efs-8.1.813.0.x86_64.deb
echo configuration source ...
mv /etc/apt/sources.list.bak.eset /etc/apt/sources.list
apt-get update
ps -ef |grep 'eset'
ls -al /opt/eset
echo Install done.
