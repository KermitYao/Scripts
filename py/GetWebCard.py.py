#-*- coding :utf-8 -*-
import os,xlrd,xlwt

def getInfoDict():
    with open('tt','r',encoding='utf-8') as f:
        aList=f.read().split('},')
        bList=[]
        cDict={}
        for aData in aList:
            bList.append(aData[2:].replace(' ','').replace('"',''))

        for bData in bList:
            cList=bData.split(',')
            yield cDict
            for cData in cList:
                dList=cData.split(':')
                cDict[dList[0]]=dList[1]

m=getInfoDict()            
xlsName='CustomerInfo.xls'
writeInfo=xlwt.Workbook()
sheet=writeInfo.add_sheet('完整的客户信息表')
sheet.write(0,0,'序号')
sheet.write(0,1,'姓名')
sheet.write(0,2,'手机')
sheet.write(0,3,'卡号')
sheet.write(0,4,'折扣')
sheet.write(0,5,'余额')
sheet.write(0,6,'类型')
sheet.write(0,7,'ID')
sheet.write(0,8,'门店')

next(m)
x=0
for data in m:
    x+=1
    y=0
    print('Read Info - 序号:{}-姓名:{}-手机:{}-卡号:{}-折扣:{}-余额:{}'.format(data['row_number'],data['xm'],data['shouji'],data['kahao'],data['zhekoulv'],data['yue']))
    for dd in data:
        sheet.write(x,y,data[dd])
        y+=1

writeInfo.save(xlsName)