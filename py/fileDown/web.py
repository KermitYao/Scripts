#20181224
#update 2020-06-12
#分离出配置文件
#添加了对文本直接显是，而不是弹出下载
#2020-10-28
#添加 如果文件为视频格式,将会返回一个h5的播放页面,而不是弹出文件下载
#-*-coding:utf-8-*-

from flask import Flask,request,send_from_directory,redirect,url_for,session
from flask import render_template
from flask import make_response
import time,os,re,math
import traceback
import json
from main import keygen
import config
import chardet
from main import wakeOnLan
#单位转换
def bytes(bytes=0):
    if bytes < 1024:
        bytes = round(bytes, 2) ,'B'
    elif bytes >= 1024 and bytes < 1024 * 1024:
        bytes = round(bytes / 1024, 2) , 'KB'
    elif bytes >= 1024 * 1024 and bytes < 1024 * 1024 * 1024:
        bytes = round(bytes / 1024 / 1024, 2) , 'MB'
    elif bytes >= 1024 * 1024 * 1024 and bytes < 1024 * 1024 * 1024 * 1024:
        bytes = round(bytes / 1024 / 1024 / 1024, 2) , 'GB'
    elif bytes >= 1024 * 1024 * 1024 * 1024 and bytes < 1024 * 1024 * 1024 * 1024 * 1024:
        bytes = round(bytes / 1024 / 1024 / 1024 / 1024, 2) , 'TB'
    elif bytes >= 1024 * 1024 * 1024 * 1024 * 1024 and bytes < 1024 * 1024 * 1024 * 1024 * 1024 * 1024:
        bytes = round(bytes / 1024 / 1024 / 1024 / 1024 / 1024, 2), 'PB'
    elif bytes >= 1024 * 1024 * 1024 * 1024 * 1024 * 1024 and bytes < 1024 * 1024 * 1024 * 1024 * 1024 * 1024 * 1024:
        bytes = round(bytes / 1024 / 1024 / 1024 / 1024 / 1024 /1024, 2) , 'EB'
    return bytes

#获取安全的文件名,防止xss攻击。
def reHelper(p):
    p = re.sub('[\/\--]+', '_', p)
    p = re.sub(r':', '_', p)
    p = re.sub(r'-|-$', '', p)
    p = re.sub(r'\\', '_', p)
    return p

def userLevel(username):
    for userDict in Config.USER_INFO:
        if userDict['u']==username:
                return userDict['l']
    return -1

def userCheck(username,password):
    for userDict in Config.USER_INFO:
        if userDict['u']==username:
            if userDict['p']==password:
                return True
    return False


def fileRead(filePath):
    with open(filePath,'rb') as fp:
        return fp.read()

def codeType(filePath):
    with open(filePath, 'rb') as fp:
        encodeType = chardet.detect(fp.read())['encoding']
        if not encodeType:
            encodeType = 'UTF-8'
    return encodeType

#获取文件 完整目录,文件名,后缀名
def GetPathInfo(filepath):
    pathname,filename=os.path.split(filepath)
    filename,filext=os.path.splitext(filename)
    return pathname,filename,filext

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
    
#格式化日期
def formatDate(date,type=1,year=2):
    date=str(date)
    if len(date)>7:
        #20200101
        d=date.replace('-','')
        if type==1:
            return d
        elif type==2:
            #2020-01-01
            d='{}-{}-{}'.format(d[:4],d[4:6],d[-2:])
            return d
        elif type==3:
            #2020+year-01-01
            d='{}-{}-{}'.format(int(d[:4])+year,d[4:6],d[-2:])
            return d
    else:
        return None

def checkNum(num):
    exp=r'^-?\d{1,12}$'
    if re.match(exp,num):
        return True
    else:
        return False


#获取文件夹大小
def getDirSize(path):
    if os.path.isdir(path):
        size=0
        for root, dirs, files in os.walk(path):
            for file in files:
                size+=os.path.getsize(os.path.join(root,file))
        return size
    else:
        return None

#获取列表信息, 接受路径和类型, type=file|dir
def getInfoList(path,type='file'):
    if os.path.isdir(path):
        dirInfo = os.listdir(path)
        dirList = [dir for dir in dirInfo if os.path.isdir(os.path.join(path,dir))]
        fileList= [file for file in dirInfo if os.path.isfile(os.path.join(path,file))]
        dirList.sort()
        fileList.sort()
        if type == 'file':
            infoList = []
            for file in fileList:
                ftime=formatTime(os.path.getmtime(os.path.join(path,file)))
                fsize=os.path.getsize(os.path.join(path,file))
                isVideo=GetPathInfo(os.path.join(path,file))[2] in Config.PLAY_VIDEO
                infoList.append({'name':file, 'time':ftime, 'unit':bytes(fsize), 'isVideo':isVideo})
            return infoList
        elif type == 'dir':
            infoList = []
            for dir in dirList:
                ftime=formatTime(os.path.getmtime(os.path.join(path,dir)))
                #fsize=getDirSize(os.path.join(path,dir))
                infoList.append({'name':dir, 'time':ftime,})
            return infoList
        else:
            return None
    else:
        return None

#获取图片信息
def photoInfo(paths,types='dir'):
    if types=='dir':
        if not os.path.isdir(paths):
            return None
        else:
            dirInfo=os.listdir(paths)
            dirList=[dir for dir in dirInfo if os.path.isdir(os.path.join(paths,dir))]
            if not dirList:
                return None
            else:
                return dirList
    elif types=='file':
        if not os.path.isdir(paths):
            return None
        else:
            fileInfo=os.listdir(paths)
            fileList=[file for file in fileInfo if os.path.isfile(os.path.join(paths,file))]
            if not fileList:
                return None
            else:
                return fileList


app = Flask(__name__)
#主页
@app.route('/')
@app.route('/<path:filepath>/')
def index(filepath=None):
    topPath='/'
    if filepath:
        fullDir=os.path.join(Config.ROOT_DIR,filepath)
    else:
        fullDir=Config.ROOT_DIR
    #如果路径为文件则发送文件流 
    if os.path.isfile(fullDir):
        print(GetPathInfo(fullDir)[2])
        if GetPathInfo(fullDir)[2] in Config.DISPLAY_TEXT:
            if os.path.getsize(fullDir) < Config.DISPLAY_TEXT_MAX * 1024 ** 2:
                encodeType = codeType(fullDir)
                response = make_response(fileRead(fullDir))
                response.headers["Content-type"]="text/plain;charset={}; filename={}".format(encodeType ,os.path.split(fullDir)[1].encode().decode('latin-1'))
                response.headers["Content-Disposition"] = " filename={}".format(os.path.split(fullDir)[1].encode().decode('latin-1'))
                return response
            else:
                response = make_response(send_from_directory(os.path.split(fullDir)[0],os.path.split(fullDir)[1],as_attachment=True))
                response.headers["Content-Disposition"] = "attachment; filename={}".format(os.path.split(fullDir)[1].encode().decode('latin-1'))
                return response
        elif GetPathInfo(fullDir)[2] in Config.PLAY_VIDEO:
                fileInfo=GetPathInfo(fullDir)
                r_page=render_template('video.html',
                                        title=fileInfo[1],
                                        videoPath=request.path
                                        )
                return r_page
        else:
            #对中文文件名进行转码.
            response = make_response(send_from_directory(os.path.split(fullDir)[0],os.path.split(fullDir)[1],as_attachment=True))
            response.headers["Content-Disposition"] = "attachment; filename={}".format(os.path.split(fullDir)[1].encode().decode('latin-1'))
            return response
    elif os.path.isdir(fullDir):
        list_dir=getInfoList(fullDir,'dir')
        list_file=getInfoList(fullDir)
        if filepath==None:
            filepath=''
            topDir='/'
        else:
            topDir=filepath.split('/')[:-1]
            for p in topDir:
                topPath=topPath+(p+'/')
        ltime=formatTime(time.time(),1)
        keyDate=formatDate(formatTime(time.time(),type=3),type=3,year=2)
        if 'username' in session:
            if userLevel(session['username'])==3:
                r_page=render_template('login.html', 
                                        text_h1=filepath,
                                        list_dir=list_dir, 
                                        list_file=list_file, 
                                        fill=' '*6, 
                                        topPath=topPath, 
                                        ltime=ltime, 
                                        regDate=keyDate,
                                        uploadsize=Config.UPLOAD_SIZE,
                                        username=session['username'],
                                        level=userLevel(session['username']),
                                        mediaUrl='/media',
                                        mediaMsg='进入MEDIA'
                                        )
            else:
                r_page=render_template('login.html', 
                                        text_h1=filepath,
                                        list_dir=list_dir, 
                                        list_file=list_file, 
                                        fill=' '*6, 
                                        topPath=topPath, 
                                        ltime=ltime, 
                                        regDate=keyDate,
                                        uploadsize=Config.UPLOAD_SIZE,
                                        username=session['username'],
                                        level=userLevel(session['username']),
                                        )
        else:
            r_page=render_template('index.html', 
                                    text_h1=filepath, 
                                    list_dir=list_dir, 
                                    list_file=list_file, 
                                    fill=' '*6, 
                                    topPath=topPath, 
                                    ltime=ltime,
                                    regDate=keyDate,
                                    uploadsize=Config.UPLOAD_SIZE
                                    )
        return r_page
    else:
        return page_not_found('您访问的这个地址,在服务器上并未找到!')

#REG
@app.route('/keygen',methods=['GET'])
def reg():
    if 'username' in session:
        if userLevel(session['username'])>0:
            if request.method == 'GET':
                if not checkNum(request.args.get('uuid','')) or not checkNum(formatDate(request.args.get('times',''),type=1)):
                    return '''
                        <p>输入不合法!</p>
                        <a href="/">返回到主页</a>
                        '''
                else:
                    src_uuid=int(request.args.get('uuid',''))
                    src_times=int(formatDate(request.args.get('times',''),type=1))
                    src_types=request.args.get('types','')
                if src_types=='en':
                    r_page=render_template('keygen.html',
                                            keygenDict={
                                                'uuid':src_uuid,
                                                'date':formatDate(src_times,type=2),
                                                'regnum':str(keygen.uuid_en(src_uuid))+'-'+str(keygen.time_en(src_times)),
                                            }
                                            )
                    return r_page
                else:    
                    r_page=render_template('keygen.html',
                                            keygenDict={
                                                'uuid':str(keygen.uuid_de(src_uuid)),
                                                'date':formatDate(keygen.time_de(src_times),type=2),
                                                'regnum':str(src_uuid)+'-'+str(src_times)
                                            }
                                            )
                    return r_page
        else:
            return '''
                <p>权限不足!</p>
                <a href="/">返回到主页</a>
               '''
    else:
        return '''
            <p>需要登陆!</p>
            <a href="/">返回到主页</a>
            '''
    return page_not_found('未知的错误!')
    
#pic
@app.route('/pic',methods=['GET','POST'])
@app.route('/pic/<path:dirPath>/')
def pic(dirPath=None):

    if os.path.isdir(Config.PHOTO_DIR):
        pass
    else:
        return page_not_found('此页面暂未开放!')

    if 'username' in session:
        if userLevel(session['username'])>0:
            if dirPath:
                fullDir=os.path.join(Config.PHOTO_DIR,dirPath)
            else:
                fullDir=Config.PHOTO_DIR
            if os.path.isfile(fullDir):
                #对中文文件名进行转码.
                response = make_response(send_from_directory(os.path.split(fullDir)[0],os.path.split(fullDir)[1],as_attachment=True))
                response.headers["Content-Disposition"] = "attachment; filename={}".format(os.path.split(fullDir)[1].encode().decode('latin-1'))
                return response
            elif os.path.isdir(fullDir):
                #初始目录
                nowDir=PHOTO_INFO[0]['dirName']
                if dirPath:
                    nowDir=dirPath
                #当前页
                if request.args.get('page'):
                    nowPage=int(request.args.get('page'))
                else:
                    nowPage=1
                #当前页的图片列表
                ltime=formatTime(time.time(),1)
                tmp_photoList=None
                for dirDict in PHOTO_INFO:
                    if dirDict['dirName']==nowDir:
                        tmp_photoList=dirDict['filePath'][nowPage*PHOTO_NUM-PHOTO_NUM:nowPage*PHOTO_NUM]
                        tmp_nowLine=dirDict['fileLine']
                        tmp_nowFileNum=dirDict['fileNum']

                #上一页
                if nowPage>1:
                    uPageNum=nowPage-1
                else:
                    uPageNum=1
                #下一页
                if tmp_nowLine>nowPage:
                    nPageNum=nowPage+1
                else:
                    nPageNum=nowPage

                r_page=render_template('photo.html',
                                    photoList=PHOTO_INFO,
                                    pageInfo={
                                        'nowDir':nowDir,
                                        'sumPage':tmp_nowLine,
                                        'sumPhoto':tmp_nowFileNum,
                                        'uPageNum':uPageNum,
                                        'nPageNum':nPageNum,
                                        'tPageNum':tmp_nowLine,
                                        'nowPhotoList':tmp_photoList,
                                        },
                                    ltime=ltime,
                                    )

                return r_page
            else:
                return '''
                    <p>服务器找不到你要访问的资源!</p>
                    <a href="/">返回到主页</a>
                    '''
        else:
            return '''
                <p>权限不足!</p>
                <a href="/">返回到主页</a>
                '''
    else:
        return '''
            <p>需要登录!</p>
            <a href="/">返回到主页</a>
            '''


@app.route('/text',methods=['GET'])
@app.route('/text/<path:filePath>/')
def text(filePath=None):
    if filePath:
        fullPath=os.path.join(Config.TEXT_DIR,filePath)
    else:
        fullPath=Config.TEXT_DIR
    if os.path.isfile(fullPath):
        #对中文文件名进行转码.
        response = make_response(send_from_directory(os.path.split(fullPath)[0],os.path.split(fullPath)[1],as_attachment=True))
        response.headers["Content-Disposition"] = "attachment; filename={}".format(os.path.split(fullPath)[1].encode().decode('latin-1'))
        return response
    else:
        return '''
            <p>服务器找不到你要访问的资源!</p>
            <a href="/">返回到主页</a>
            '''

@app.route('/gettime',methods=['POST','GET'])
def getTime():
    return formatTime(time.time())

@app.route('/getip',methods=['POST','GET'])
def getIp():
    if 'Remote_Addr' in request.headers:
        remoteAddr = request.headers.get('Remote_Addr')
    else:
        remoteAddr = request.remote_addr
    return remoteAddr

@app.route('/testup',methods=['POST','GET'])
def testup():

    return render_template('testup.html')

@app.route('/runServer',methods=['get', 'POST'])
def runServer():
    if 'username' in session:
        MAC=['78:2b:cb:19:a5:7e', '78:2b:cb:19:a5:7f']      
        for i in MAC:
            macFormat = wakeOnLan.format_mac0(i) 
            sendMacData = wakeOnLan.create_magic_packet(macFormat)
            wakeOnLan.send_magic_packet(sendMacData)
            print('Send magic ok.')
    else:
            return '''
                <p>需要登录!</p>
                <a href="/">返回到主页</a>
                '''
    return '''
        <p>已发送魔法封包!</p>
        <a href="/">返回到主页</a>
        '''

#登陆
@app.route('/login',methods=['POST','GET'])
def login():
    if request.method == 'POST':
        if userCheck(request.form['username'],request.form['password']):
            session['username']=request.form['username']
            session.permanent = False
            return redirect(url_for('index',filepath='/'))
        else:
            return '''
                <p>用户名或密码错误!</p>
                <a href="/">返回到主页</a>
                '''
    else:
        return redirect(url_for('index',filepath='/'))

def testMsg(msg):
    print(msg)
    print('testMsgEnd')

#登出
@app.route('/logout')
def logout():
    session.pop('username',None)
    return redirect(url_for('index',filepath='/'))


#视频页面
@app.route('/media/')
@app.route('/media/<path:filePath>/')
def video(filePath=None):
    
    if os.path.isdir(Config.VIDEO_DIR):
        pass
    else:
        return page_not_found('此页面暂未开放!')
    
    keyDate=formatDate(formatTime(time.time(),type=3),type=3,year=2)
    if 'username' in session:
        if userLevel(session['username'])==3:
            topPath='/media/'
            if filePath:
                fullDir=os.path.join(Config.VIDEO_DIR,filePath)
            else:
                fullDir=Config.VIDEO_DIR
            #如果路径为文件则发送文件流 
            if os.path.isfile(fullDir):
                if request.args.get('type','')=='video':
                    fileInfo=GetPathInfo(fullDir)
                    r_page=render_template('video.html',
                                            title=fileInfo[1],
                                            videoPath=request.path
                                            )
                    return r_page
                else:
                    #对中文文件名进行转码.
                    response = make_response(send_from_directory(os.path.split(fullDir)[0],os.path.split(fullDir)[1],as_attachment=True))
                    response.headers["Content-Disposition"] = "attachment; filename={}".format(os.path.split(fullDir)[1].encode().decode('latin-1'))
                    return response
            elif os.path.isdir(fullDir):
                list_dir=getInfoList(fullDir,'dir')
                list_file=getInfoList(fullDir)
                if filePath==None:
                    filePath=''
                    topDir=topPath
                else:
                    topDir=filePath.split('/')[:-1]
                    for p in topDir:
                        topPath=topPath+(p+'/')
                ltime=formatTime(time.time(),1)
                r_page=render_template('video_go.html', 
                                        text_h1=topPath[1:]+filePath,
                                        list_dir=list_dir, 
                                        list_file=list_file, 
                                        fill=' '*6, 
                                        topPath=topPath, 
                                        ltime=ltime, 
                                        regDate=keyDate,
                                        uploadsize=Config.UPLOAD_SIZE,
                                        username=session['username'],
                                        level=userLevel(session['username']),
                                        mediaUrl='/',
                                        mediaMsg='  返回首页'
                                        )
                return r_page
            else:
                return page_not_found('您访问的这个地址,在服务器上并未找到!')
        else:
            return '''
                <p>权限不足!</p>
                <a href="/">返回到主页</a>
                '''
    else:
        return '''
            <p>需要登录!</p>
            <a href="/">返回到主页</a>
            '''
        
    return redirect(url_for('index',filepath='/'))

#上传请求
@app.route('/upload',methods=['POST'])
def uploadFile():
    try:
        if request.method == 'POST':
            if 'username' in session:
                if not os.path.exists(Config.UPLOAD_DIR):
                    os.makedirs(Config.UPLOAD_DIR)
                if not 'loadfile' in request.files:
                    return '未选择文件!'
                    
                f = request.files['loadfile']
                loadfilePath=os.path.join(Config.UPLOAD_DIR,reHelper(f.filename))
                if os.path.isfile(loadfilePath):
                    return '此文件名称已存在!'

                f.save(loadfilePath)
                if os.path.isfile(loadfilePath):
                    return '上传完成!'
                else:
                    return '文件写入服务器失败!'

            else:
                return '未登陆!'
        else:
            return page_not_found('此页面并不能直接访问!')
    except Exception  as exeption:
        traceback.print_exc()
        return page_not_found('服务器内部错误:%s' % exeption)

@app.errorhandler(404)
def page_not_found(errorInfo='HTTP 404 Page Not Found'):
    return render_template('404.html',seq_404=range(9),errorInfo=errorInfo)

if __name__ == '__main__':

    Config = config.Config()

    #加载图片信息
    PHOTO_INFO=[]
    PHOTO_NUM=20
    dirList=photoInfo(Config.PHOTO_DIR,'dir')
    if dirList:
        for dir in dirList:
            fileList=photoInfo(os.path.join(Config.PHOTO_DIR,dir),types='file')
            if fileList:
                PHOTO_INFO.append({
                    'dirName':dir,
                    'fileNum':len(fileList),
                    'fileLine':int(math.ceil(len(fileList)/PHOTO_NUM)),
                    'filePath':fileList
                })

    print(Config.USER_INFO)
    print(Config.DISPLAY_TEXT)
    print(Config.PLAY_VIDEO)
    #------------------------------------------------
    app.config['MAX_CONTENT_LENGTH'] = Config.UPLOAD_SIZE * 1024 * 1024
    app.secret_key = Config.SECRET_KEY
    if Config.DEBUG:
        app.run(debug=True,port=Config.PORT,host='0.0.0.0')
    else:
        app.run(host='0.0.0.0',port=Config.PORT,threaded=True)

