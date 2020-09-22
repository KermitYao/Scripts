import requests
from bs4 import BeautifulSoup

#获取网页属性 连接，标签，属性，浏览器伪装头
#需要说明的是此方法是一个生成器,每次调用生成一个值返回。next(getWebUrl(url,tag,attr,headers))
def getWebUrl(url,tag,attr,headers):
    fr=None
    url = url
    r = requests.get(url,headers=headers)
    r.encoding = r.apparent_encoding
    soup = BeautifulSoup(r.text,'lxml')
    for link in soup.find_all(tag):
        yield fr
        fr = link.get(attr)

#下载图片 连接，文件名，浏览器伪装头
def downImg(url,fileName,headers):
    try:
        r = requests.get(url,headers=headers)
        with open(fileName,'wb') as fileData:
            fileData.write(r.content)
        return 0
    except Exception  as exeption:
        return 1
#dome
if __name__ == '__main__':
    nameCount=0
    headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0'}
    iterImg = getWebUrl('https://www.290rr.com/xiaoshuo/list-%E6%AD%A6%E4%BE%A0%E5%8F%A4%E5%85%B8.html','a','href',headers)
    next(iterImg)
    for m in iterImg:
        print(m)
        dImg = downImg(m,str(nameCount)+'.jpg',headers)
        nameCount+=1
