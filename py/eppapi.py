
#pip install pycryptodomex
#pip install requests

import base64
import hashlib
import random
import time
from Cryptodome.Cipher import AES
import requests

class EppApi():
    def __init__(self, appName, appKey, appSecret, iv, host):
        self.appKey = appKey
        self.appSecret = appSecret
        self.appName = appName
        self.iv = iv
        self.host = host
        self.accessToken = ""
        self.tokenExpires = 0
    def getToken(self):
        if int(time.time()) >= self.tokenExpires:
            url = f"{self.host}/openapi/statistics/gettoken"
            nonce = ''.join(random.choice('0123456789ABCDEF') for i in range(32))
            stime = int(time.time())
            joinstr = f"{self.appKey}{nonce}{self.appSecret}{stime}"
            sign = hashlib.md5(joinstr.encode(encoding='utf-8')).hexdigest()
            params = {
                "app_key": self.appKey,
                "app_name": self.appName,
                "stime": stime,
                "nonce": nonce,
                "sign": sign
            }
            content = requests.post(url, data=params)
            response = content.json()
            self.accessToken = response['data']["accessToken"]
            self.tokenExpires = int(time.time()) + response['data']["expiresIn"]

    def decodeData(self, data):
        data = base64.b64decode(data)
        data = data[4:]
        bAppSecret = bytes(self.appSecret[0:32], encoding="utf-8")
        bIv = bytes(self.iv, encoding="utf-8")
        cipher = AES.new(bAppSecret, AES.MODE_CBC, bIv)
        msg = cipher.decrypt(data)
        padding_len = msg[len(msg) - 1]
        return msg[0:-padding_len]
    
    #获取每个分组下的客户端安装数量
    def getGroupTree(self):
        url = f"{self.host}/openapi/statistics/getmygrouptree"
        self.getToken()
        params = {
            "token": self.accessToken
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']

    #获取操作系统统计
    def getPcInfo(self):
        url = f"{self.host}/openapi/statistics/pcinfo"
        self.getToken()
        params = {
            "token": self.accessToken
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']

    #资产统计
    def getAssetstat(self):
        url = f"{self.host}/openapi/statistics/assetstat"
        self.getToken()
        params = {
            "token": self.accessToken
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']

    #客户端版本统计
    def geteppVersion(self):
        url = f"{self.host}/openapi/statistics/eppversion"
        self.getToken()
        params = {
            "token": self.accessToken
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']

    #病毒库版本统计
    def getVirusLibVersion(self):
        url = f"{self.host}/openapi/statistics/virus"
        self.getToken()
        params = {
            "token": self.accessToken
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']

    #补丁库版本统计
    def getPatchLibVersion(self):
        url = f"{self.host}/openapi/statistics/patchlibversion"
        self.getToken()
        params = {
            "token": self.accessToken
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']

    def getGroupList(self):
        url = f"{self.host}/openapi/statistics/violations"
        self.getToken()
        params = {
            "token": self.accessToken
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']
        
    def scanFast(self,m2,handleType="auto",expireTime=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time()+172800))):
        url = f"{self.host}/openapi/SetCommand/scanfast"
        self.getToken()
        params = {
            "token": self.accessToken,
            "m2s":m2,
            "handle_type":handleType,
            "expire_time":expireTime
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']

    def updateVirus(self,m2):
        url = f"{self.host}/openapi/SetCommand/clientupdatevirus"
        self.getToken()
        params = {
            "token": self.accessToken,
            "m2s":m2,
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']

    def updatePatch(self,m2):
        url = f"{self.host}/openapi/SetCommand/clientupdatepatch"
        self.getToken()
        params = {
            "token": self.accessToken,
            "m2s":m2,
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']
        
    def scanFull(self,m2,handleType="auto",expireTime=time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time()+172800))):
        url = f"{self.host}/openapi/SetCommand/scanfast"
        self.getToken()
        params = {
            "token": self.accessToken,
            "m2s":m2,
            "handle_type":handleType,
            "expire_time":expireTime
        }
        content = requests.post(url, data=params)
        response = content.json()
        if response['errno'] == 0:
            data = response['data']
            return self.decodeData(data)
        else:
            return response['errmsg']


if __name__ == '__main__':
    appName = "test"
    appKey = "a5fc390c5d9701395131235b9b425f50"
    appSecret = "274070d5b2ff11da9cf94e0651cc1f627fdc1eee"
    iv = "15K55c7vYwZ657Gl"
    host = "http://192.168.16.196:8081"

    api = EppApi(appName, appKey, appSecret, iv, host)
    print(api.getGroupTree())
    print(api.getPcInfo())
    print(api.geteppVersion())