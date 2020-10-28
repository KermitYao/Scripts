#!/usr/bin/python3
#-*- coding:utf-8 -*-
#卡号补齐
import os


def fillCard(cardData):
    temp=fillStr+str(cardData)
    return temp[total:]

fillStr='00000000000'
total=-11

sourceCardFile='cardNo.txt'
df=open('cardNo_new.txt','w')

with open(sourceCardFile,'r',encoding='utf-8') as sf:
    for datas in sf.readlines():
        data=datas.strip('\n')
        data=data.strip()
        if len(data)!=0:
            if len(data)!=11:
                CompleteCardData=fillCard(data)
                print('len:{0} | card:{1}>{2}'.format(len(data.strip('\n')),data,CompleteCardData))
                df.write(CompleteCardData+'\n')
            else:
                print('len:{0} | card:{1}>{2}'.format(len(data.strip('\n')),data,CompleteCardData))
                df.write(data+'\n')

df.close()