@echo off
echo Y|net use * /delete
net use \\192.168.0.3 /user:administrator Wanghua126126
start \\192.168.0.3
exit