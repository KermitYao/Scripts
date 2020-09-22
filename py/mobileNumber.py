#!/usr/bin/python3
#-*- coding:utf-8 -*-
import os


def getSuffix(m=1,n=3):
    string='0'*n+str(m)
    string=string[-n:]
    return string
fix='1713154'
num=1
wf=open('mobile_new.txt','w')
with open('mobile.txt','r') as rf:
    for datas in rf.readlines():
        data=datas.strip('\n')
        if len(data)!=11:
            num=num+1
            fixs=fix+getSuffix(num,4)
            print('len:{0} | mobile:{1}>{2}'.format(len(data.strip('\n')),data,fixs))
            wf.write(fixs+'\n')
        else:
            print('len:{0} | mobile:{1}>{2}'.format(len(data.strip('\n')),data,data))
            wf.write(data+'\n')

wf.close()