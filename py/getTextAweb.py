#-*- coding: utf-8 -*-
import os,time,threading,re, sqlite3, hashlib
from urllib import request,parse
from html.parser import HTMLParser

#重写 HtmlParser 解析webUrl
class WebHtmlParser(HTMLParser):
    listUrlTextWeb=[]
    flag = False
    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            if re.match(r'^/.*/.*/\d+.html',attrs[0][1]):
                self.attrs = attrs
                self.flag = True

    def handle_data(self,data):
        if self.flag:
            self.listUrlTextWeb.append((self.attrs[0][1],data))
            self.flag = False

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
        if type == 1:
            m='{}-{}-{} {}:{}:{}'.format(tm['year'],tm['mon'],tm['mday'],tm['hour'],tm['min'],tm['sec'])
        elif type == 2:
            m='{}{}{}{}{}{}'.format(tm['year'],tm['mon'],tm['mday'],tm['hour'],tm['min'],tm['sec'])
        elif type == 3:
            m='{}-{}-{}'.format(tm['year'],tm['mon'],tm['mday'])
        return m
    return None

class SqliteTools():
    def __init__(self):
        self.dbName='test.db'
        self.tableName='test'

    def execute(self, sqliteCmd):
        self.cursor.execute(sqliteCmd)
        self.connectSqlite.commit()

    def createTable(self):
        self.connectSqlite = sqlite3.connect(self.dbName)
        self.cursor = self.connectSqlite.cursor()
        createTableCmd='''
        CREATE TABLE IF NOT EXISTS {0}(
            id INTEGER PRIMARY KEY  NOT NULL, 
            name TEXT  NOT NULL, 
            time TEXT, 
            url TEXT, 
            content TEXT,
            md5 TEXT
            )
        '''.format(self.tableName)
        self.execute(createTableCmd)

    def dropTable(self):
        dropTableCmd='DROP TABLE IF EXISTS {0}'.format(self.tableName)
        self.execute(dropTableCmd)

    def close(self):
        self.cursor.close()
        self.connectSqlite.close()

def procecc():
    inurl=input('抓取网址:')
    if not inurl:inurl='http://www.g4e3.com/AAbook/AAAtb/luanlunx/index-'
    incountx=input('开始页面:')
    if not incountx:incountx='2'
    incounty=input('结束页面:')
    if not incounty:incounty='20'
    
    infilen=input('写入文件名:')
    if not infilen:infilen=str(time.time()).replace('.','')
    print('\n参数---Index:{},StartPage:{},EndPage:{}\n'.format(inurl,incountx,incounty))
    downTextDir = r'downText'
    threadMax=5
    countName=1

    webParser=WebHtmlParser()
    textParser=TextHtmlParser()
    db = SqliteTools()
    md5 = hashlib.md5()
    #建立下载目录
    if not os.path.exists(downTextDir):
        os.makedirs(downTextDir)
    textP=open(os.path.join(downTextDir,infilen+'.txt'),'a+',encoding='utf-8')
    db.dbName = os.path.join(downTextDir,infilen+'.db')
    db.tableName = infilen
    db.createTable()

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
        for urlText, urlTitle in webParser.listUrlTextWeb:
            dbSelect = 'select name from {0} where name="{1}"'.format(db.tableName, urlTitle)
            db.execute(dbSelect)
            dbContent = db.cursor.fetchall()
            urlTextWeb=parse.urljoin(urlParse.scheme+'://'+urlParse.netloc,urlText)
            if len(dbContent) == 0:
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
                            md5.update(textParser.dataText.encode('utf-8'))
                            dbInsert = 'INSERT INTO {5} ("name", "time", "url", "content", "md5") VALUES ("{0}", "{1}","{2}","{3}", "{4}" )'.format(textParser.textTitle, formatTime(time.time()), urlTextWeb, textParser.dataText, md5.hexdigest(), db.tableName)
                            db.execute(dbInsert)
                            textP.write('\n\t\t\t第 {} 章 '.format(str(countName))+textParser.textTitle)
                            textP.write(textParser.dataText)
                            countName+=1
                except Exception  as exeption:
                    print('\turlRequestText:{},RequestError:{}'.format(urlTextWeb,exeption))
            else:
                print('\turlRequestText:{}'.format(urlTextWeb))
                print('\t\t 数据库中存在相应的条目: {0}'.format(urlTitle))

        #清空 Web 列表      
        webParser.listUrlTextWeb=[]

    textP.close()
    db.close
    print('Text All Grab OK!')


if __name__=='__main__':
    procecc()

