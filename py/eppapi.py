#-*-coding:utf-8-*-
import requests
import time,string,random,hashlib
from urllib.parse import urljoin
import base64
#当系统为 nt 时安装: pycryptodome, linux为: pycrypto
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
class GetEppData():
    def __init__(self):
        self.appInfo = ''
        self.tokenInfo = ''
        self.url = ''
        self.urlHost = ''
        self.randomStr = ''.join(random.sample(string.ascii_letters + string.digits + string.punctuation, 32))

    def initToken(self,appInfo,urlHost):
        intStr = (appInfo['appKey'] + self.randomStr + appInfo['appSecret'] + str(int(time.time()))).encode("utf-8")
        md5Str = hashlib.md5(intStr).hexdigest()
        data = {
        'app_name': appInfo['appName'],
        'app_key': appInfo['appKey'],
        'sign': md5Str,
        'nonce': self.randomStr,
        'stime': str(int(time.time())),
        }
        urlPath = 'openapi/statistics/gettoken'
        url = urljoin(urlHost, urlPath)
        r = requests.post(url, data=data)
        if r.status_code != 200:
            return False
        else:
            if r.json()['errno'] != 0:
                return False
            else:
                self.tokenInfo = r.json()
                self.appInfo = appInfo
                self.urlHost = urlHost
                return True
        return False

    def __checkToken(self):
        if self.tokenInfo:
            return True
        else:
            print('Token 信息未获取!')
            return False

    def __deData(self,data):
        print(data)
        deData = base64.b64decode(data['data'])
        
        '''
        if len(self.appInfo['iv']) % 16 != 0:
            iv = pad(self.appInfo['iv'].encode("utf-8"), 16)
        else:
            iv = self.appInfo['iv'].encode("utf-8")
        print(iv)
        cipher = AES.new(self.appInfo['appKey'].encode("utf-8"), AES.MODE_CBC, iv)
        deData = cipher.decrypt(deData)
        print("str:%s" % str(deData))
        '''
        return deData

    def getGroupTree(self):
        if self.__checkToken() == False:
            return False
        urlPath = '/openapi/statistics/virus'
        url = urljoin(self.urlHost, urlPath)
        data = {
            'token': self.tokenInfo['data']['accessToken'],
        }
        r = requests.post(url, data=data)
        if r.status_code != 200:
            return False
        else:
            if r.json()['errno'] != 0:
                return False
            else:
                return self.__deData(r.json())


        return r.json()


def main():
    appInfo = {
        'appName': 'pytest',
        'appKey': '11d7825afa15ed2ffec848ff0e3e210e',
        'appSecret': '4f97ae80a56bf3800527eac026ebe66d5041c504',
        'iv': '2EBPJd76eb000000'
    }
    urlHost = 'http://192.168.16.196:8081'
    app = GetEppData()
    tokenState = app.initToken(appInfo,urlHost)
    if tokenState :
        print('Get token okey!')
        print(app.getGroupTree())
        return  tokenState
    else:
        print('Get token failed')
        return  tokenState
if __name__=='__main__':
    main()