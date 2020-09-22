#-*- coding: utf-8 -*-
import socket,threading,time,os,sys,json,re,zipfile
import encodings

#进度条
class ShowProcess():
    """
    显示处理进度的类
    调用该类相关函数即可实现处理进度的显示
    """
    i = 0 # 当前的处理进度
    max_steps = 0 # 总共需要处理的次数
    max_arrow = 50 #进度条的长度

    # 初始化函数，需要知道总共的处理次数
    def __init__(self, max_steps):
        self.max_steps = max_steps
        self.i = 0 

    # 显示函数，根据当前的处理进度i显示进度
    # 效果为[>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>]100.00%
    def show_process(self, i=None):
        if i is not None:
            self.i = i
        else:
            self.i += 1
        num_arrow = int(self.i * self.max_arrow / self.max_steps) #计算显示多少个'>'
        num_line = self.max_arrow - num_arrow #计算显示多少个'-'
        percent = self.i * 100.0 / self.max_steps #计算完成进度，格式为xx.xx%
        process_bar = '[' + '>' * num_arrow + '-' * num_line + ']'\
                      + '%.2f' % percent + '%' + '\r' #带输出的字符串，'\r'表示不换行回到最左边
        sys.stdout.write(process_bar) #这两句打印字符到终端
        sys.stdout.flush()

    def close(self, words='done'):
        print('')
        self.i = 0

#文件解压缩,实例传入 文件/文件夹路径,类型。
class CompressFile():
    def __init__(self,tmpFile):
        self.tmpFile=tmpFile
    #压缩目录
    def compress(self,path):
        bk_compn=os.path.join(self.tmpFile,os.path.basename(path)+'.zip')
        bk_compf=zipfile.ZipFile(bk_compn,'w',zipfile.ZIP_DEFLATED)
        if os.path.isfile(path):
            bk_compf.write(path,os.path.basename(path))
        elif os.path.isdir(path):
            for bk_dirpath, bk_dirnames, bk_filenames in os.walk(path):
                if not bk_filenames:
                    bk_compf.write(os.path.join(bk_dirpath,))
                for bk_filename in bk_filenames:
                    bk_compf.write(os.path.join(bk_dirpath,bk_filename))
        else:
            bk_compf.close()
            return 1
        bk_compf.close()        
        return bk_compn
   
    #解压文件
    def decompress(self,path):
        bk_decompf=zipfile.ZipFile(path,'r')
        for bk_file in bk_decompf.namelist():
            bk_decompf.extract(bk_file,self.tmpFile)
        bk_decompf.close()
        return os.path.join(self.tmpFile,GetPathInfo(path)[1])

class FileRequest():
    #初始化实例
    def __init__(self,bk_connect):
        self.bk_conn=bk_connect
    #处理文件接收
    def FileRecv(self,file_pointer,file_size,showprocess='False'):
        bk_recv_size=0
        flag=True
        while flag:
            if int(file_size)>bk_recv_size:
                bk_data=self.bk_conn.recv(BUFFER)
                bk_recv_size += len(bk_data)
                if showprocess!='False':
                    showprocess.show_process(bk_recv_size/int(file_size)*100)
            else:
                bk_recv_size=0
                flag=False
                continue
            file_pointer.write(bk_data)
        if showprocess!='False':
            showprocess.show_process(100)
            showprocess.close()
        self.bk_conn.send('0'.encode())
        return 0

    #处理文件发送
    def FileSend(self,file_pointer,file_size,showprocess='False'):
        bk_send_size=0
        flag=True
        while flag:
            if bk_send_size + BUFFER > file_size:
                bk_data=file_pointer.read(file_size-bk_send_size)
                flag=False
            else:
                bk_data=file_pointer.read(BUFFER)
                bk_send_size+=BUFFER
                if showprocess!='False':
                    showprocess.show_process(bk_send_size/file_size*100)
            self.bk_conn.send(bk_data)
        if showprocess!='False':
            showprocess.show_process(100)
            showprocess.close()
        self.bk_conn.recv(BUFFER)
        return 0

#功能模块
class RequestProcess():
    def __init__(self):
        BUFFER=1024

    def login(self,username):
        #认证服务器
        mySocket.send(str.encode('ACK'+'|'+username))
        if mySocket.recv(BUFFER).decode()!='True':
            return 1
        else:
            return 0
    
    #上传文件
    def upload(self,filename):
        fileNameSize=os.stat(filename).st_size
        bk_uploadfile='upload|'+os.path.basename(filename)+'|'+str(fileNameSize)
        mySocket.send(bk_uploadfile.encode())
        print('文件大小: {} {}'.format(bytes(fileNameSize)[0],bytes(fileNameSize)[1]))
        recvtype=mySocket.recv(BUFFER).decode()
        if recvtype=='upload-ok':
            with open(filename,'rb') as fp:
                if fileRequest.FileSend(fp,os.stat(filename).st_size,showprocess)==0:

                    return 0
        elif recvtype=='upload-error1':
            return 1

    #下载更新
    def update(self,tmpFile):
        bk_tmp='1b54c31b9a9f9bb1e7aef29ee65ddd93'
        bk_downfile='update|'+bk_tmp+'|'
        mySocket.send(bk_downfile.encode())
        bk_tmpmsg=mySocket.recv(BUFFER).decode()
        bk_data_seq,bk_data_info,bk_data_msg=bk_tmpmsg.split('|')
        if bk_data_seq=='True':
            with open(os.path.join(tmpFile,bk_data_info),'wb') as fp:
                mySocket.send('Waiting'.encode())
                print(fileRequest.FileRecv(fp,bk_data_msg,showprocess))
            return 0
        else:
            return 1
    
    #获取操作指令
    def getCommand(self):
        bk_downfile='cmd||'
        mySocket.send(bk_downfile.encode())
        bk_tmpmsg=mySocket.recv(BUFFER).decode()
        if len(bk_tmpmsg) > 0:
            return bk_tmpmsg
        else:
            return 1

    #获取远程文件列表
    def getFileList(self):
        bk_downfile='list||'
        mySocket.send(bk_downfile.encode())
        listMsg=mySocket.recv(BUFFER).decode()
        if listMsg == 'none':
            return 1
        bk_tmpmsg=json.loads(listMsg)
        choosenum=0
        for file in bk_tmpmsg:
            choosenum+=1
            filename,filetime=file.split('$&$')
            filetime=time.localtime(float(filetime))
            filetime='{}-{}-{} {}:{}:{}'.format(filetime.tm_year,filetime.tm_mon,filetime.tm_mday,filetime.tm_hour,filetime.tm_min,filetime.tm_sec)
            print('{}.{} Time:{}'.format(choosenum,filename,filetime))
        if choosenum == 0:
            return 1
        else:
            while True:
                filenamechoose=input('请选择你要下载的文件序号 <1-%d>/<q>退出:' % choosenum)
                if re.match('[1-9qQ]{1,%d}' % len(str(choosenum)),filenamechoose):
                    if filenamechoose == 'q' or filenamechoose == 'Q':
                        return 2
                    if int(filenamechoose[0:len(str(choosenum))]) <= choosenum:
                        break

            #请求下载文件
            print('下载文件:{}'.format(filename[:-4]))
            bk_downfile='down|'+bk_tmpmsg[int(filenamechoose[0:len(str(choosenum))])-1]+'|'
            mySocket.send(bk_downfile.encode())
            bk_tmpmsg=mySocket.recv(BUFFER).decode()
            bk_data_seq,bk_data_info,bk_data_msg=bk_tmpmsg.split('|')
            if bk_data_seq=='True':
                print('文件大小: {} {}'.format(bytes(int(bk_data_msg))[0],bytes(int(bk_data_msg))[1]))
                with open(os.path.join(tmpFile,bk_data_info),'wb') as fp:
                    mySocket.send('Waiting'.encode())
                    if fileRequest.FileRecv(fp,bk_data_msg,showprocess) == 0:
                        return os.path.join(tmpFile,bk_data_info)

    #关闭远程连接
    def closeSocket(self):
        bk_uploadfile='close||'
        s=mySocket.send(bk_uploadfile.encode())
        return 0

#获取文件 完整目录,文件名,后缀名
def GetPathInfo(filepath):
    pathname,filename=os.path.split(filepath)
    filename,filext=os.path.splitext(filename)
    return pathname,filename,filext

#获取可用的 连接 地址
def GetIPaddr(socketapi,*ipaddr):
    for ip in ipaddr:
        if ip != None:
            iplist=ip.split(':')
            if len(iplist)==1:
                try:
                    socketapi.connect((iplist[0],59001))
                    return (iplist[0],59001)
                except Exception:
                    pass
            elif len(iplist)==2:
                try:
                    socketapi.connect((iplist[0],int(iplist[1])))
                    return (iplist[0],int(iplist[1]))
                except Exception:
                    pass

#单位转换
def bytes(bytes):
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

#删除超过限定时间的文件
def delOTF(PATHNAME,days):
    GetTimeDiff=lambda PATHNAME: int((time.time()-os.path.getatime(PATHNAME))/24/60/60)
    filelist=[os.path.join(PATHNAME,file) for file in os.listdir(PATHNAME)  
    if os.path.isfile(os.path.join(PATHNAME,file)) and GetTimeDiff(os.path.join(PATHNAME,file)) > int(days)]
    for files in filelist:
        os.remove(files)
    return filelist

#备份mssql数据库
def sqlBackup(databaseName,uid,pwd,backupPath,setpath=''):
    try:
        sql='{}sqlcmd -U {} -P {} -Q "backup database [{}] to disk=\'{}\'" >nul 2>&1'.format(setpath,uid,pwd,databaseName,backupPath)
        sqlMsg=os.popen(sql)
        sqlMsg=sqlMsg.read()
        if not os.path.isfile(backupPath):
            return 1
        return 0
    except Exception  as exeption:
        return 1

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

def readconf(configPath, section,selectList):
    import configparser
    try:
        #logging.debug('位置:[{}] - 信息:[参数列表:[{},{}]]'.format(sys._getframe().f_code.co_name,filename,section))
        tmp_dict={}
        conf=configparser.ConfigParser()
        conf.read(configPath,encoding='utf-8-sig')
        #构建配置信息为 dict
        for n in range(len(selectList)):
            for option in conf.options(section):            
                if selectList[n]==option:
                    if conf.get(section,option)=='':
                        tmp_dict[option]=None
                        break
                    else:
                        tmp_dict[option]=conf.get(section,option)
                        break
            if selectList[n] not in tmp_dict.keys():
                tmp_dict[selectList[n]]=None
        return tmp_dict
    except Exception as exeption:
        #logging.error('位置:[{}] - 信息:[程序出错,报错信息:[{}]]'.format(sys._getframe().f_code.co_name,exeption))
        return 1
def pause(confg):
    if confg['cmdType'] == 'pause':
        input('请按回车键,继续下一步操作...')

def runClient(confParm):
    if myReq.login(confParm['uid']) == 0:
        #如果传入参数不为DOWN则。
        if confParm['cmdType'] == 'conf' or confParm['cmdType'] == 'pause':
            commandInfo=myReq.getCommand()
            cmdMsg=os.popen(commandInfo)
            cmdMsg=cmdMsg.read()
            if os.path.exists(confParm['path']):
                print('正在压缩:{}'.format(confParm['path']))
                upLoadCompressInfo=compress.compress(confParm['path'])
            else:
                print('备份对象未找到! >>:%s' % confParm['path'])
                return 1
            if upLoadCompressInfo == 1:
                print('压缩错误,请检查!')
                return 1
            print('上传文件:{}'.format(upLoadCompressInfo))
            if upLoadCompressInfo != 1:
                upLoadInfo=myReq.upload(upLoadCompressInfo)
                if upLoadInfo==0:
                    print('文件上传成功')
                elif upLoadInfo==1:
                    print('文件被服务器拒绝接受!')
                else:
                    print('上传错误')
            #if myReq.upload() == 0:

        elif confParm['cmdType'] == 'down':
            #如果传入参数为DOWN则。
            while True:
                fileListInfo = myReq.getFileList()
                if fileListInfo == 1:
                    print('远程服务器未找到文件列表.')
                    break
                elif fileListInfo == 2:
                    break
                else:
                    print('解压文件:{}'.format(fileListInfo))
                    decompressInfo = compress.decompress(fileListInfo)
                    if sys.platform == 'win32':
                        os.system(r'explorer /select,{}'.format(decompressInfo))
                    print('解压完成：{}'.format(decompressInfo))
        else:
            print('传入参数错误:{}'.format(confParm['cmdType']))

    else:
        print('服务器拒绝你的指令请求,请联系管理员!')
    myReq.closeSocket()

#主要过程
def process():
    #初始化变量
    global CLIENT_CONFIG_LIST,CONFIG_FILE,BUFFER,TMPFILENAME,tmpFile
    BUFFER = 1024
    TMPFILENAME ='TmpFile'
    tmpFile = os.path.join(GetPathInfo(os.path.abspath(__file__))[0],TMPFILENAME)
    msbackup = os.path.join(GetPathInfo(os.path.abspath(__file__))[0],'mssqlbackup')
    CONFIG_FILE = os.path.join(GetPathInfo(os.path.abspath(__file__))[0],'B-CloudC.conf')
    CLIENT_CONFIG_LIST = ('uid','addr_1','addr_2','addr_3','path','ismssql','mssqlcmd','mssqladdr','mssqlid','mssqlpwd','mssqldatabase','store')
    #SERVER_CONFIG_LIST = ('port','path','store','command')
    global fileRequest,showprocess,myReq,compress,mySocket
    TYPE_CONFIG='ClientConf'
    mySocket=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    #实例化方法
    fileRequest = FileRequest(mySocket)
    showprocess = ShowProcess(100)
    myReq = RequestProcess()
    compress = CompressFile(tmpFile)
    #读取配置
    confParm=readconf(CONFIG_FILE,TYPE_CONFIG,CLIENT_CONFIG_LIST)
    if len(sys.argv) > 1:
        confParm['cmdType'] = sys.argv[1]
    else:
        confParm['cmdType'] = 'pause'
    #清理超过一定天数的文件
    if confParm['store'] != None:
        if os.path.isdir(tmpFile): delOTF(tmpFile,confParm['store'])
        if os.path.isdir(msbackup): delOTF(msbackup,confParm['store'])
    #备份若系统为win系列,则检测是否备份数据库.
    if sys.platform == 'win32' and confParm['cmdType'] != 'down':
        if confParm['ismssql']=='True':
            dbbackup=os.path.join(msbackup,confParm['mssqldatabase']+formatTime(time.time(),2)+'.mssqlbak')
            print('正在备份数据库:%s' % confParm['mssqldatabase'])
            if os.path.isdir(confParm['mssqlcmd']):
                mspath='set path=%path%;'+confParm['mssqlcmd']+'&'
            else:
                mspath=''
            if sqlBackup(confParm['mssqldatabase'],confParm['mssqlid'],confParm['mssqlpwd'],dbbackup,setpath=mspath)==0:
                confParm['path']=dbbackup
            else:
                print('数据库备份失败.')
                pause(confParm)
                return 1
    #获取可用地址
    connectAddr=GetIPaddr(mySocket,confParm['addr_1'],confParm['addr_2'],confParm['addr_3'])
    if connectAddr == None:
        print('无法连接服务器!')
        pause(confParm)
        return 1
    runClient(confParm)
    pause(confParm)
if __name__ == '__main__':
    process()

'''
if sys.platform == 'win32':
    os.system('taskkill /f /pid {}&& copy /y pids.py pid.py&& start pid.py'.format(os.getppid()))
'''
