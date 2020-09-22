#-*- coding: utf-8 -*-
import os,time,threading,re
from urllib import request,parse
from html.parser import HTMLParser

#重写 HtmlParser 解析webUrl
class webHtmlParser(HTMLParser):
    listUrlImageWeb=[]
    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            if re.match(r'^/.*/.*/\d+.html',attrs[0][1]):
                self.listUrlImageWeb.append(attrs[0][1])

#重写 HtmlParser 解析imageUrl
class imageHtmlParser(HTMLParser):
    listUrlImage=[]
    def handle_starttag(self, tag, attrs):
        if tag == 'img':
            for img in attrs:
                if img[0] == 'src':
                    self.listUrlImage.append(img[1])

#下载图片
def downImage(url,filename,agentTuple):
    opener = request.build_opener()
    opener.addheaders = [agentTuple]
    request.install_opener(opener)
    try:
        request.urlretrieve(url,filename)
    except Exception  as exeption:
        print('url:{},downError:{}'.format(url,exeption))

def procecc():

    inurl=input('键入网址:')
    if not inurl:inurl='http://www.g4e3.com/AAtupian/AAAtb/asia/index-'
    incountx=input('开始页面:')
    if not incountx:incountx='2'
    incounty=input('结束页面:')
    if not incounty:incounty='20'
    print('\n参数---Index:{},StartPage:{},EndPage:{}\n'.format(inurl,incountx,incounty))
    downImageDir = r'downImage'
    threadMax=5
    countName=0
    webParser=webHtmlParser()
    imageParser=imageHtmlParser()
    #添加浏览器模拟
    #建立下载目录
    if not os.path.exists(downImageDir):
        os.makedirs(downImageDir)
    #主要过程    
    for page in range(int(incountx),int(incounty)):
        url = inurl+str(page)+'.html'
        print('urlRequestWeb:{}'.format(url))
        agentKey='User-Agent'
        agentValue='Mozilla/5.0 (X11; Linux x86_64;rv:58.0) Gecko/20100101 Firefox/58.0'
        headers = {agentKey:agentValue}
        reponse = request.Request(url,headers={agentKey:agentValue})
        #url地址解析
        urlParse = parse.urlparse(url)
        #实例化 web 解析

        try:
            with request.urlopen(url) as urlP:
                webParser.feed(urlP.read().decode('utf-8'))
        except Exception  as exeption:
            print('url:{},requestError:{}'.format(url,exeption))
            webParser.listUrlImageWeb=[]
        #解析图片地址
        for urlImage in webParser.listUrlImageWeb:
            urlDownWeb=parse.urljoin(urlParse.scheme+'://'+urlParse.netloc,urlImage)
            print('\turlRequestWeb:{}'.format(urlDownWeb))
            try:
                with request.urlopen(urlDownWeb) as urlP:
                    imageParser.feed(urlP.read().decode())
            except Exception  as exeption:
                print('\turl:{},requestError:{}'.format(urlDownWeb,exeption))
                imageParser.listUrlImage = []
                #启用多线程下载    
            for urlImage in imageParser.listUrlImage:
                print('\t\turlDown:{},Name:{}'.format(urlImage,countName))
                thread = threading.Thread(target=downImage,args=(urlImage,os.path.join(downImageDir,str(time.time()).replace('.','')+'-'+str(countName)+'.jpg'),(agentKey,agentValue)))
                thread.start()
                countName+=1
                while True:
                    if threading.active_count() < threadMax:
                        break
                    time.sleep(1)
            imageParser.listUrlImage=[]
        webParser.listUrlImageWeb=[]
    print('Image All Down OK!')


if __name__=='__main__':
    procecc()

