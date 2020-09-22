#-*-coding:utf-8-*-
from PIL import Image
import os,time,sys

#格式化时间
def formatTime(times,type=1):
    if times != None:
        m=time.localtime(float(times))
        if type == 1:
            m='{}-{}-{} {}:{}:{}'.format(m.tm_year,m.tm_mon,m.tm_mday,m.tm_hour,m.tm_min,m.tm_sec)
        elif type == 2:
            m='{}{}{}{}{}{}'.format(m.tm_year,m.tm_mon,m.tm_mday,m.tm_hour,m.tm_min,m.tm_sec)
        return m
    return None

#获取缩略图
def get_resize(imageSize,saveFormat,fromPath,toPath):
    try:
        image=Image.open(fromPath)
        imageNew=image.resize(imageSize,Image.BICUBIC)
        print('FileSize:',image.size,'>',imageNew.size)
        imageNew.save(toPath,saveFormat)
        return 0
    except Exception as exeption:
        print(exeption)
        return 1


def getPathInfo(pathname):
    pathname,filename=os.path.split(pathname)
    filename,filext=os.path.splitext(filename)
    return pathname,filename,filext


if len(sys.argv) > 1:
    if len(sys.argv) > 4:
        fromPath=sys.argv[1]
        newImageSize=(int(sys.argv[2]),int(sys.argv[3]))
        newImageFormat = sys.argv[4]
    else:
        print('Usage: {} FileName | x | y | ImageFormat.'.format(sys.argv[0],))
        print('Tips: {} d:/t.jpg 200 150 png'.format(sys.argv[0],))
        exit(6080)
else:  
    fromPath = '1.jpg'
    newImageSize = (250,200)
    newImageFormat = 'png'
if not os.path.isfile(fromPath):
    exit(1)
x,y,z = getPathInfo(fromPath)
toPath = os.path.join(x,y+'_'+formatTime(time.time(),type=2)+'.'+newImageFormat)
print('FileName:',fromPath,'>',toPath)
print(get_resize(newImageSize,newImageFormat,fromPath,toPath))
