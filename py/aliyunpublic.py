#-*-coding:utf-8 -*-
from urllib import request,parse
import hashlib,requests
import hmac,urllib
import datetime,uuid,base64,time

class ALiYunPublic():
    def __init__(self):
        self.idTag=False
        self.updateTag=False
        self.donePrt={}
        self.urlPath='https://alidns.aliyuncs.com/?'
        timestamp=datetime.datetime.strftime(datetime.datetime.utcnow(),"%Y-%m-%dT%H:%M:%SZ")
        self.publicPrt={
            'Format':'JSON',
            'Version':'2015-01-09',
            'SignatureVersion':'1.0',
            'SignatureMethod':'HMAC-SHA1',
            'Timestamp':timestamp,
            'SignatureNonce':str(uuid.uuid1()),
        }

    #内部函数
    #url编码
    def __urlEncode(self,strs):
        res = parse.quote(strs,safe="-_.~",encoding="utf-8")
        res = res.replace('+', '%20')
        res = res.replace('*', '%2A')
        res = res.replace('%7E', '~')
        return res

    #设置功能传输
    def setAction(self,dicts):
        #每次更新重置UUID和时间戳
        timestamp=datetime.datetime.strftime(datetime.datetime.utcnow(),"%Y-%m-%dT%H:%M:%SZ")
        self.publicPrt['Timestamp']=timestamp
        self.publicPrt['SignatureNonce']=str(uuid.uuid1())
        self.donePrt=dict(self.publicPrt,**dicts)
    #设置用户信息
    def setAccessInfo(self,accessID,accessKey):
        self.idTag=True
        self.accessID=accessID
        self.accessKey=accessKey+'&'

    #获取格式化字符串
    def __getStrSingture(self):
        f=''
        apiPrt=sorted(self.donePrt.items(),key=lambda x: x[0])
        for x,y in apiPrt:
            f=f+'&'+self.__urlEncode(x)+'='+self.__urlEncode(y)
        fstr='GET'+'&'+self.__urlEncode('/')+'&'+self.__urlEncode(f[1:])
        return fstr

    #获取签名串
    def __getSingture(self,apiPrt):
        s=hmac.new(self.accessKey.encode('utf-8'),apiPrt.encode('utf-8'),digestmod='sha1')
        s=base64.encodestring(s.digest()).strip()
        return s.decode()
    #获取最终请求地址
    def __getUrl(self,singture):
        self.donePrt['Signature']=singture
        return self.urlPath + parse.urlencode(self.donePrt)

    #更新数据
    def update(self):
        if self.idTag==False:
            raise ValueError('Did not add: %s' % 'AccessID')
        else:
            self.updateTag=True
            self.donePrt['AccessKeyId']=self.accessID
            self.apiPrt=self.__getStrSingture()
            self.singture=self.__getSingture(self.apiPrt)
            self.url=self.__getUrl(self.singture)

    def sendRequest(self):
        if self.updateTag==False:
            raise ValueError('invalid value: %s' % 'update')
        else:
            try:
                r=requests.get(self.url)
                return r.text
            except Exception  as exeption:
                return None

    def getInfo(self,info):
        if self.updateTag==False:
            raise ValueError('invalid value: %s' % 'update')
        else:
            if info=='strsingture':
                return self.apiPrt
            elif info=='singture':
                return self.singture
            elif info=='url':
                return self.url
            else:
                return None

if __name__=='__main__':
    action={
        'Action':'DescribeDomainInfo',
        'DomainName':'yjyn.top',
    }
    accessID = 'id'
    accessKey = 'key'
    dns=ALiYunPublic()
    dns.urlPath='https://alidns.aliyuncs.com/?'
    dns.setAccessInfo(accessID,accessKey)
    dns.setAction(action)
    dns.update()
    print(dns.getInfo('strsingture'))
    print(dns.getInfo('singture'))
    print(dns.getInfo('url'))
    print(dns.sendRequest())
