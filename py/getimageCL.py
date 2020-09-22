#-*- coding: utf-8 -*-
import re,os,threading,time
import urllib.request as request

#图片网页地址解析
def urlImageWebParsing(strData):
    urlImageWeb=re.match(r'\s*<td.+class="tal".+href="(.+)".+target="_blank".+id="">(.+)</a>',strData)
    if urlImageWeb:return urlImageWeb.groups()

#图片地址解析
def urlImageParsing(imageData):
    urlImage=re.match(r'\s*<input.+src="(http://.+)".*type="image"',imageData)
    if urlImage:return urlImage.group(1)

#下载图片
def downImage(url,filename):
    downHeaders=[('User-Agent','Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.221 Safari/537.36 SE 2.X MetaSr 1.0')]
    opener = request.build_opener()
    opener.addheaders = downHeaders
    request.install_opener(opener)
    try:
        request.urlretrieve(url,filename)
    except Exception  as exeption:
        print('downError:{},url:{}'.format(exeption,url))
#地址列表组装
def getUrlList(url,funcType):
    listUrlImageWeb=[]
    try:
        with request.urlopen(url) as urlPointer:
            urlCodeData=urlPointer.readlines()
        for data in urlCodeData:
            urlImageWeb=funcType(data.decode('utf-8'))
            if urlImageWeb:listUrlImageWeb.append(urlImageWeb)
        return listUrlImageWeb
    except Exception  as exeption:
        print('downError:{},url:{}'.format(exeption,url))
        return listUrlImageWeb 

countName=1491
for page in range(8,30):
    downImageDir = r'downImage'
    url = 'http://c70ccd63810237ef.pw/thread.php?fid=15&page={}'.format(str(page))
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.221 Safari/537.36 SE 2.X MetaSr 1.0'}
    reponse = request.Request(url,headers=headers)
    listUrlImageWeb=getUrlList(url,urlImageWebParsing)
    if not os.path.exists(downImageDir):
        os.makedirs(downImageDir)

    for urlWeb in listUrlImageWeb:
        urlAdd='http://c70ccd63810237ef.pw/' + urlWeb[0]
        print(urlAdd, urlWeb[1])
        listImageAdd=getUrlList(urlAdd,urlImageParsing)
        for urlImage in listImageAdd:
            print('down:{},name:{}'.format(urlImage,countName))
            thread = threading.Thread(target=downImage,args=(urlImage,os.path.join(downImageDir,str(countName)+'.jpg')))
            thread.start()
            while True:
                if threading.active_count() < 10:
                    break
                time.sleep(1)
            countName+=1
print('From Image All Down OK!')

            


