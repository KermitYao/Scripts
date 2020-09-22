#-- coding:utf-8 --
import requests
import xlwt,os


def getToken(url,headers,loginDict):
    r=requests.post(url=url, headers=headers, data=loginDict)
    return r.json()


def getCardInfo(url,headers,cardDict):
    r=requests.post(url=url, headers=headers, data=cardDict)
    return r.json()

class ExcelWrite():
    def __init__(self,fileName,sheet):
        self.fileName=fileName
        self.sheet=sheet
        self.workBook=xlwt.Workbook(encoding='utf-8')
        self.workSheet=self.workBook.add_sheet('cardInfo')
        self.workY=0
    def write(self,infoList):
        self.workY+=1
        x=0
        for info in infoList:
            x+=1
            self.workSheet.write(self.workY,x,label=info)

    def close(self):
        self.workBook.save(self.fileName)
        
        

    



if __name__=='__main__':
    headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0'}
    urlToken='http://clean.shuxier.com/project.php/mapi/login/login'
    urlCard='http://clean.shuxier.com/project.php/mapi/User/balanceTotal'

    mid='1244'
    mobile='57189066'
    passwd='57189066'
    version='3.1.2250'
    loginDict={
        'mid':mid,
        'mobile':mobile,
        'passwd':passwd,
        'version':version,
    }

    tokens=getToken(urlToken,headers,loginDict)
    if tokens['code']==0:
        print('登录成功:\n\t店名称:{0}\n\ttoken:{1}'.format(tokens['mname'],tokens['token']))
    else:
        print('登录失败.')

    page='1'
    limit='3000'
    cardDict={
        'token':tokens['token'],
        'page':page,
        'limit':limit,
    }
    cardInfo=getCardInfo(urlCard,headers,cardDict)
    if cardInfo['code']==0:
        pageInfo=cardInfo['result']
        customerDict=pageInfo['list']
    print('会员总计:{0}\n总计余额:{1}'.format(pageInfo['count'],pageInfo['balance_total']))
    exc=ExcelWrite('test.xls','cardTest')
    for uInfo in customerDict:
        uInfo['discount']=uInfo['discount']/100
        i=[uInfo[x] for x in uInfo]
        exc.write(i)
    exc.close()
        




