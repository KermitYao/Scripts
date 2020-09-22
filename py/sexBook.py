import requests
from bs4 import BeautifulSoup
from urllib import parse
import os,time,re
#获取文本链接，标题
def getTextUrl(url,headers):
    try:
        r = requests.get(url,headers=headers, timeout = 20)
        listTextUrl={}
        r.encoding = r.apparent_encoding
        soup = BeautifulSoup(r.text,'lxml')
        for ul in soup.find_all('ul'):
            for li in ul.find_all('li'):
                text = li.a.get('title')
                if text:
                    listTextUrl[text]=li.a.get('href')
        return listTextUrl
    except Exception  as exeption:
        return 1
#获取文本数据
def getTextData(url,headers):
    try:
        data = ''
        r = requests.get(url,headers=headers, timeout = 20)
        r.encoding = r.apparent_encoding
        soup = BeautifulSoup(r.text,'lxml')
        #获取标签属性为style 
        for div in soup.find_all('div'):
            if str(div.get('style'))[:10]=='text-align':
                for dataLine in div.strings:
                    data=data+str(dataLine)
        return data
    except Exception  as exeption:
        return 1
#获取完整路径
def getFullUrl(url,subUrl):
    urlParse = parse.urlparse(url)
    urlTextWeb=parse.urljoin(urlParse.scheme+'://'+urlParse.netloc,subUrl)
    return urlTextWeb

#下载图片 连接，文件名，浏览器伪装头
def downImg(url,fileName,headers):
    try:
        r = requests.get(url,headers=headers)
        with open(fileName,'wb') as fileData:
            fileData.write(r.content)
        return 0
    except Exception  as exeption:
        return 1

    #建立下载目录
def mkdirDown(downTextDir,fileName):
    try:
        if not os.path.exists(downTextDir):
            os.makedirs(downTextDir)
        
        textP=open(os.path.join(downTextDir,fileName+'.txt'),'a+',encoding='utf-8')
        return textP
    except Exception as exeption:
        return 1


def procecc():
    inurl=input('抓取网址:')
    if not inurl:inurl='https://www.290rr.com/xiaoshuo/list-%E5%AE%B6%E5%BA%AD%E4%B9%B1%E4%BC%A6-'
    incountx=input('开始页面:')
    if not incountx:incountx='1'
    incounty=input('结束页面:')
    if not incounty:incounty='20'
    infilen=input('写入文件名:')
    if not infilen:infilen=str(time.time()).replace('.','')
    #sys var    
    threadMax=5
    countName=1
    headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0'}
    downTextDir = r'downText'
    fileP=mkdirDown(downTextDir,infilen)
    #sys var
    if fileP == 1:
        print('mkdirDownError:')
        return 1

    print('\n参数---Index:{},StartPage:{},EndPage:{},FileName:{}\n'.format(inurl,incountx,incounty,fileP.name))
    for page in range(int(incountx),int(incounty)):
            url = re.sub('(\-\d+)?\.html$', '-{}.html'.format(page), inurl)
            print('textListUrl:{}'.format(url))
            webTextUrl = getTextUrl(url,headers)
            #判断文章链接
            if webTextUrl != 1:
                for key in webTextUrl:
                    print('\tgetTextData|Title:{}|Url:{}'.format(key,webTextUrl[key]))
                    textData = getTextData(getFullUrl(url,webTextUrl[key]),headers)
                    #判断文章数据
                    if textData != 1:
                        fileP.write('\n\t\t\t第 {} 章 {}\n'.format(str(countName),key))
                        fileP.write(textData)
                        countName+=1
                    else:
                        print('getTextDataError:')
                        print('\t文章数据解析错误!')
                        #return 0          
            else:
                print('getTextUrlError:')
                #return 0
    fileP.close()
    print('Text All Grab OK!')
    return 0

if __name__ == '__main__':
    procecc()


'''
https://www.290rr.com/xiaoshuo/list-都市激情-2.html
https://www.290rr.com/xiaoshuo/list-人妻交换-2.html
https://www.290rr.com/xiaoshuo/list-校园春色-2.html
https://www.290rr.com/xiaoshuo/list-家庭乱伦-2.html
https://www.290rr.com/xiaoshuo/list-情色笑话-2.html
https://www.290rr.com/xiaoshuo/list-性爱技巧-2.html
https://www.290rr.com/xiaoshuo/list-武侠古典-2.html
https://www.290rr.com/xiaoshuo/list-另类小说-2.html

'''