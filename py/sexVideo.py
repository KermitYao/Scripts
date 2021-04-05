import os, sys, requests
from html.parser import HTMLParser
from urllib.parse import urljoin
from urllib import parse
import re, time
from urllib import parse
import time, threading
#获取sexUrl列表.
class SexVideoListHtmlParser(HTMLParser):

    def __init__(self, rootUrl):
        HTMLParser.__init__(self)
        self.linkList = []
        self.tagState = False
        self.startTagState = False
        self.endTagState = False
        self.seek = 'ul'
        self.rootUrl = rootUrl
        self.urlSplit = parse.urlsplit(rootUrl)
    def handle_starttag(self, tag, attrs):
        if tag == self.seek:
            self.startTagState = True
        if self.startTagState:
            if tag == 'a' and len(attrs) == 3:
                if attrs[0][0] == 'href' and attrs[1][0] == 'title' and attrs[2][0] == 'target':
                    urlTmp = urljoin(self.urlSplit.scheme + '://' + self.urlSplit.netloc, attrs[0][1])
                    self.linkList.append((urlTmp, attrs[1][1]))

    def handle_endtag(self, tag):
        if tag == self.seek:
            self.startTagState = False

    def handle_data(self, data):
        pass
    #用于下一页的重置参数
    def resetVar(self):
        self.linkList = []
        self.tagState = False
        self.startTagState = False
        self.endTagState = False

#获取sexUrl信息.
class SexVideoInfoHtmlParser(HTMLParser):

    def __init__(self, rootUrl):
        HTMLParser.__init__(self)
        self.tagState = False
        self.startTagState = False
        self.endTagState = False
        self.videoInfo = {}
        self.tagStateP = False
        self.seek = 'ul'
        self.rootUrl = rootUrl
        self.strFind = ('類型：', '更新：')
    def handle_starttag(self, tag, attrs):
        #self.videoInfo = {}
        #获取图片链接
        if tag == 'img' and len(attrs) > 4:
            if attrs[0][0] == 'class' and attrs[0][1] == 'lazy' and attrs[1][0] == 'data-original':
                self.videoInfo['img'] = attrs[1][1]
        
        if tag == 'p':
            self.tagStateP = True
        #获取视频链接
        if tag == 'input' and len(attrs) == 5:
            patterns = 'http.://.+\.(rmvb|mp4|avi|rm)+'
            if attrs[1][0] == 'data-clipboard-text' and re.match(patterns, attrs[1][1]):
                self.videoInfo['vUrl'] = attrs[1][1]


    def handle_endtag(self, tag):
        if tag == self.seek:
            self.startTagState = False

    def handle_data(self, data):
        #获取视频类型和时间
        if self.strFind[0] in data:
            self.videoInfo['type'] = data.split('：')[1]
        if self.strFind[1] in data:
            self.videoInfo['time'] = data.split('：')[1]
    #重置参数
    def resetVar(self):
        self.tagState = False
        self.startTagState = False
        self.endTagState = False
        self.videoInfo = {}
        self.tagStateP = False

#格式化时间
def formatTime(times,type=1):
    if times != None:
        m=time.localtime(float(times))
        tm={'year':m.tm_year,
            'mon':m.tm_mon,
            'mday':m.tm_mday,
            'hour':m.tm_hour,
            'min':m.tm_min,
            'sec':m.tm_sec,
        }
        for v in tm:
            if tm[v]<10:
                tm[v]='0'+str(tm[v])
            else:
                tm[v]=str(tm[v])
        #2019-09-09 12:12:00
        if type == 1:
            m='{}-{}-{} {}:{}:{}'.format(tm['year'],tm['mon'],tm['mday'],tm['hour'],tm['min'],tm['sec'])
        #20190909121200
        elif type == 2:
            m='{}{}{}{}{}{}'.format(tm['year'],tm['mon'],tm['mday'],tm['hour'],tm['min'],tm['sec'])
        #2019-09-09
        elif type == 3:
            m='{}-{}-{}'.format(tm['year'],tm['mon'],tm['mday'])
        return m
    return None

#下载图片 连接，文件名，浏览器伪装头
def downImg(url,fileName,headers):
    try:
        r = requests.get(url,headers=headers)
        with open(fileName,'wb') as fileData:
            fileData.write(r.content)
        return 0
    except Exception  as exeption:
        return 1

#获取页面文本
def getUrlText(url, headers):
    try:
        rUrlList = requests.get(url, headers = headers, timeout = 20)
        rUrlList.encoding = 'UTF-8'
        '''
        with open(url, 'r', encoding='UTF-8') as f:
            rUrlList = f.read()
        '''
        return rUrlList.text
    except Exception  as exeption:
        #print('errorInfo:{}'.format(exeption))
        return None
    

    #建立下载目录
def mkdirDown(downDir,fileName):
    try:
        if not os.path.exists(downDir):
            os.makedirs(downDir)
        
        textP=open(os.path.join(downDir,fileName+'.txt'),'a+',encoding='utf-8')
        return textP
    except Exception as exeption:
        return 1



def process():
    #处理cui输入
    inurl=input('抓取网址:')
    if not inurl:inurl='https://www.afy3.com/xiazai/list-%E5%9B%BD%E4%BA%A7%E8%87%AA%E6%8B%8D-2.html'
    incountx=input('开始页面:')
    if not incountx:incountx='1'
    incounty=input('结束页面:')
    if not incounty:incounty='3'
    infilen=input('写入文件名:')
    if not infilen:infilen=str(time.time()).replace('.','')
    #-------------------------


    #变量预配置
    codeCount = 0
    threadMax=10
    countName=1
    headers = {'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:68.0) Gecko/20100101 Firefox/68.0'}
    sexInfo = infilen
    #实例化解析类
    urlListParser = SexVideoListHtmlParser(inurl)
    urlInfoParser = SexVideoInfoHtmlParser('http://yjyn.top:6081')
    #-------------------
    #打开一个文件用于写入信息
    fileP=mkdirDown(sexInfo,infilen)
    #sys var
    if fileP == 1:
        print('mkdirDownError:')
        return 1

    print('\n参数---Index:{},StartPage:{},EndPage:{},FileName:{}\n'.format(inurl,incountx,incounty,fileP.name))
    #开始遍历页面
    for page in range(int(incountx),int(incounty)):
            url = re.sub('(\-\d+)?\.html$', '-{}.html'.format(page), inurl)
            print('videoListUrl:{}'.format(url))
            rListUrlText = getUrlText(url, headers)
            if not rListUrlText:
                print('  getUrlTextError:{}'.format(url))
                continue
            #重置初始变量，填充数据
            urlListParser.resetVar()
            urlListParser.feed(rListUrlText)
            print("rListUrlText")
            print(urlListParser.linkList)
            if len(urlListParser.linkList) < 1:
                print('  urlListParserError:{}'.format(url))
                continue
            print(urlListParser.linkList)
            videoCount = len(urlListParser.linkList)

            #遍历获取视频页面信息
            for videoUrl, videoName in urlListParser.linkList:
                print('    count:{} videoInfoUrl:{} name:{} '.format(videoCount-1, videoUrl, videoName ))
                videoCount-=1
                rInfoUrlText = getUrlText(videoUrl, headers)
                if not rInfoUrlText:
                    print('      getUrlTextError:{}'.format(videoUrl))
                    continue
                urlInfoParser.resetVar()
                print("rInfoUrlText")
                urlInfoParser.feed(rInfoUrlText)
                print(urlInfoParser.videoInfo)
                if len(urlInfoParser.videoInfo) != 3:
                    print('      urlInfoParserError:{}'.format(videoUrl))
                    continue
                #写入信息到文本
                if urlInfoParser.videoInfo['vUrl']:
                    codeName = formatTime(time.time(), 2) + '000000{}'.format(codeCount)[-6:]
                    fileP.write('{0}.(编码:{1}|名称:{2}|网址:{3}|类型:{4}|时间:{5})\n'.format(codeCount, codeName, videoName, urlInfoParser.videoInfo['vUrl'], urlInfoParser.videoInfo['type'], urlInfoParser.videoInfo['time']))
                    codeCount+=1
                    fileP.flush()
                else:
                    print('    信息抓取不完整')

                    #启用多线程下载  已解析图片  
                if urlInfoParser.videoInfo['img']:
                    thread = threading.Thread(target=downImg,args=(urlInfoParser.videoInfo['img'],os.path.join(sexInfo, codeName + '.jpg'),headers))
                    thread.start()
                    countName+=1
                    while True:
                        if threading.active_count() < threadMax:
                            break
                        time.sleep(1)


    fileP.close()
    return 0
    
    

    
    '''
    urlInfoParser = SexVideoInfoHtmlParser('http://yjyn.top:6081')
    rUrlInfo = getUrlText(r'https://www.aph2.com/xiazai/59820.html')
    urlInfoParser.feed(rUrlInfo)
    print(urlInfoParser.tmpInfo)
    '''
if __name__ == '__main__':
    print(process())
    input('press key next...')