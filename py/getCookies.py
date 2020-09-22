import requests
from bs4 import BeautifulSoup

#获取token
def getToken(url,headers):
    token=None
    cookies=None
    r = requests.get(url,headers=headers)
    r.encoding = r.apparent_encoding
    soun=BeautifulSoup(r.text,'lxml')
    for i in soun.head.find_all('meta'):
        if i.get('name') == 'csrf-token':
            token=i.get('content')
    cookies=r.cookies.get_dict()
    return token,cookies

#获取cookies
def getCookies(url,headers,data,cookies):
    r=None
    incookies=None
    r = requests.post(url,headers=headers,data=data,cookies=cookies)
    r.encoding = r.apparent_encoding
    incookies=r.cookies.get_dict()
    return r,incookies


def getWebUrl(url,headers,cookies):
    r=None
    r = requests.get(url,headers=headers,cookies=cookies)
    r.encoding = r.apparent_encoding
    return r


headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0'}
url='http://192.168.0.202:6080/auth/login'
urlData='http://192.168.0.202:6080'
token,cookies=getToken(url,headers)
email='nameyu8023@qq.com'
pwd='blog_mini'
data={'csrf_token':token,'email':email,'password':pwd}
rs,incookies = getCookies(url,headers,data,cookies)
data=getWebUrl(urlData,headers,incookies)
print(data.text)

