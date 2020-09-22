from urllib import request
import re
import requests

def getIp1():
    try:
        r = request.urlopen('http://2018.ip138.com/ic.asp')
        m=re.search(r'\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}',r.read().decode('gb2312'))
        if m == None:
            return None
        else:
            return m.group(0)
    except Exception as error:
        return None
def checkIp(ipAddr):
  compile_ip=re.compile('^(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|[1-9])\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)$')
  if compile_ip.match(ipAddr):
    return True  
  else:  
    return False

def test():
    url='http://whois.pconline.com.cn/ipJson.jsp'
    headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0'}
    r = requests.get(url,headers=headers,timeout=6)
    print(r.text.split('"' ,4)[3])

def getIp():
    headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0'}
    url='https://www.taobao.com/help/getip.php'
    urls='http://ip.taobao.com/service/getIpInfo.php?ip=myip'
    urlList=[{
        'url':'http://ip.taobao.com/service/getIpInfo.php?ip=myip',
        'key':'ip'
        },
        {
        'url':'https://api.ipify.org/?format=json',
        'key':'ip'
        },
        {
        'url':'https://jsonip.com/',
        'key':'ip'
        },
        {
        'url':'http://ifconfig.io/all.json',
        'key':'ip'
        },
        ]
    '''
    for info in urlList:
        try:
            r = requests.get(info['url'],headers=headers,timeout=5)
            print(r.text)
            if r.status_code == 200:
                print(r.json()[info['key']])
                return r.json()[info['key']]
        except Exception:
            msg='请求ip地址错误,url:{},msg:{}'.format(info['url'],Exception)
            print(msg)
            #logging.warning(msg)

    try:
        r = requests.post(urls,headers=headers,timeout=6)
        type(r.text)
        if r.status_code == 200:
            ipAddr = r.text.split('"',8)
            print(ipAddr)
            if checkIp(ipAddr):
                return ipAddr
            else:
                return None
    except Exception:
        msg='请求ip地址错误,url:{},msg:{}'.format(url,Exception)
        print(msg)
        #logging.warning(msg)
        return None
    '''

if __name__ == '__main__':
    print(test())