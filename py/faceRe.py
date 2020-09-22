#!/bin/python3
#AI face test
import sys,os
import requests
import base64

def toB64(srcPath):
    with open(srcPath, 'rb') as f:
        b64 = base64.b64encode(f.read())
    return b64

def fromB64(b64, srcPath):
    with open(srcPath, 'wb') as f:
        srcRet = f.write(base64.b64decode(b64))


def downImage(url,filename):
    agentTuple = {'user-agent':'Mozilla/5.0 (X11; Linux x86_64;rv:58.0) Gecko/20100101 Firefox/58.0'}
    try:
        r = requests.get(url,headers=agentTuple)
        with open(filename, 'wb') as f:
            f.write(r.content)
    except Exception  as exeption:
        print('url:{},downError:{}'.format(url,exeption))


def faceApi(body):
    pass

def process():
    srcPath_a = '/home/keming/Desktop/faceJpg/src_a.jpg'
    srcPath_b = '/home/keming/Desktop/faceJpg/src_b.jpg'
    apiUrl = 'http://picread.market.alicloudapi.com/facecg'
    srcPath_new = '/home/keming/Desktop/faceJpg/src_new.jpeg'
    appcode = 'f109a74a5ca446d992a850855b1d5746'
    
    headers = {
            'Authorization':'APPCODE ' + appcode,
            'user-agent':'chrome'
    }
    
    bodys = {
            'srca':toB64(srcPath_a),
            'srcb':toB64(srcPath_b),
            'type':'pic'
    }
    
    r = requests.post(apiUrl, headers=headers, data=bodys)
    print(r.json())    





if __name__ == '__main__':
    process()
