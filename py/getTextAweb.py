#-*- coding: utf-8 -*-
import os,time,threading,re
from urllib import request,parse
from html.parser import HTMLParser

#重写 HtmlParser 解析webUrl
class WebHtmlParser(HTMLParser):
    listUrlTextWeb=[]
    def handle_data(self,data):
        self.data=data
    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            if re.match(r'^/.*/.*/\d+.html',attrs[0][1]):
                self.listUrlTextWeb.append(attrs[0][1])



#重写 HtmlParser 解析textUrl
class TextHtmlParser(HTMLParser):
    def ClearVar(self):
        self.dataText=''
        self.textTitle='No Title'
        self.flag = False
        self.encoding='utf-8'
    #获取正文
    def handle_data(self,data):
        self.data = data
        if self.flag == True:
            self.dataText=self.dataText+self.data

    def handle_starttag(self, tag, attrs):
        if tag.lower() == 'b' or tag.lower() == 'p' or tag.lower() == 'br':
            self.flag = True
        else:
            self.flag = False
        #获取编码格式
        if tag.lower() == 'meta':
            if attrs[0][0].lower() == 'charset':
                self.encoding = attrs[0][1]
    #获取标题
    def handle_endtag(self,tag):
        if tag.lower() == 'h1':
            self.textTitle=self.data



def procecc():
    inurl=input('抓取网址:')
    if not inurl:inurl='http://www.g4e3.com/AAtupian/AAAtb/asia/index-'
    incountx=input('开始页面:')
    if not incountx:incountx='2'
    incounty=input('结束页面:')
    if not incounty:incounty='20'
    print('\n参数---Index:{},StartPage:{},EndPage:{}\n'.format(inurl,incountx,incounty))
    downTextDir = r'downText'
    threadMax=5
    countName=1

    webParser=WebHtmlParser()
    textParser=TextHtmlParser()
    #建立下载目录
    if not os.path.exists(downTextDir):
        os.makedirs(downTextDir)
    textP=open(os.path.join(downTextDir,str(time.time()).replace('.','')+'.txt'),'a+',encoding='utf-8')
    #主要过程    
    for page in range(int(incountx),int(incounty)):
        url = inurl+str(page)+'.html'
        print('urlRequestWeb:{}'.format(url))
        #添加浏览器模拟
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
            print('UrlWeb:{},RequestError:{}'.format(url,exeption))
            webParser.listUrlTextWeb=[]

        for urlText in webParser.listUrlTextWeb:

            urlTextWeb=parse.urljoin(urlParse.scheme+'://'+urlParse.netloc,urlText)
            print('\turlRequestText:{}'.format(urlTextWeb))
            try:
                with request.urlopen(urlTextWeb) as urlP:
                    urlTextData=urlP.read()
                    textParser.ClearVar()
                    textParser.feed(str(urlTextData))
                    encoding=textParser.encoding
                    textParser.ClearVar()
                    textParser.feed(urlTextData.decode(encoding))
                    if textParser.textTitle != 'No Title':
                        textP.write('\n\t\t\t第 {} 章 '.format(str(countName))+textParser.textTitle)
                        textP.write(textParser.dataText)
                        countName+=1
            except Exception  as exeption:
                print('\turlRequestText:{},RequestError:{}'.format(urlTextWeb,exeption))
        #清空 Web 列表      
        webParser.listUrlTextWeb=[]

    textP.close()
    print('Text All Grab OK!')


if __name__=='__main__':
    procecc()

