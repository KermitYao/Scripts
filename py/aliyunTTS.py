#-*-coding:utf-8-*-
import requests
import json,time,os

#使用阿里云API进行TTS合成, 
#三个参数　text为需要合成的文本,若成功合成则写入当前目录下,以当前时间命名的文件.
#失败返回错误消息,成功返回文件名称。
def getTTS(appkey,token,text):
    url='https://nls-gateway.cn-shanghai.aliyuncs.com/stream/v1/tts'
    vformat='mp3'
    params={
        'appkey':appkey,
        'token' :token,
        'text'  :text,
        'format':vformat,
        'voice' :'xiaobei'
    }

    r=requests.get(url,params=params)
    if r.headers['Content-Type']=='audio/mpeg':
        vname=str(time.time()).replace('.','')+'.'+vformat
        with open(vname,'wb') as af:
            af.write(r.content)
        return os.path.join(os.getcwd(),vname)
    else:
        return json.loads(r.text)['message']

if __name__=='__main__':

    appkey='id'
    token='key'
    text='''
        姐姐,我办法有很多啊,但是就不告诉你哦。
    '''
    print(getTTS(appkey,token,text))



