#-*- coding: utf-8 -*-
import socket,threading,time,os,sys,hashlib,logging,json,re
import traceback

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

def readconf(configPath, section,selectList):
    import configparser
    try:
        #logger.debug('位置:[{}] - 信息:[参数列表:[{},{}]]'.format(sys._getframe().f_code.co_name,filename,section))
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
        #logger.error('位置:[{}] - 信息:[程序出错,报错信息:[{}]]'.format(sys._getframe().f_code.co_name,exeption))
        return 1



#md5 计算
def getFileMd5(filename):
    if not os.path.isfile(filename):
        return
    myhash = hashlib.md5()
    f = open(filename,'rb')
    while True:
        b = f.read(8096)
        if not b :
            break
        myhash.update(b)
    f.close()
    return myhash.hexdigest()

#对文件按时间排序
def sortTime(pathDir):
    if not os.path.exists(pathDir):
        return None
    listFile=os.listdir(pathDir)
    listFile=[x for x in listFile if x.find('$&$')!=-1]
    if not listFile:
        return None
    listFile=sorted(listFile,key=lambda x: os.path.getmtime(os.path.join(pathDir,x)))
    return listFile
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

#处理用户信息
def userInfo(user=None):
    userList=[]
    stats=False
    with open(USERCONF,'r+',encoding='utf-8-sig') as f:
        for line in f.readlines():
            cut=line.split('::')
            if len(cut)==2:
                cut=(cut[0],cut[1].strip())
                if (user==cut[0] and cut[1]=='True'):
                    stats=True
                    if not os.path.exists(os.path.join(confParm['path'],user)):
                        os.makedirs(os.path.join(confParm['path'],user))
                listTmp=sortTime(os.path.join(confParm['path'],cut[0]))
                if listTmp:
                    userList.append((cut[0],cut[1],listTmp[-1],os.path.getmtime(os.path.join(confParm['path'],cut[0],listTmp[-1]))))
                else:
                    userList.append((cut[0],cut[1],None,None))

    if user != None:
        return stats
    elif len(userList)>0:
        return userList
    else:
        return 1

#删除超过限定时间的文件
def delOTF(PATHNAME,days):
    GetTimeDiff=lambda PATHNAME: int((time.time()-os.path.getatime(PATHNAME))/24/60/60)
    filelist=[os.path.join(PATHNAME,file) for file in os.listdir(PATHNAME)  
    if os.path.isfile(os.path.join(PATHNAME,file)) and GetTimeDiff(os.path.join(PATHNAME,file)) > days]
    for files in filelist:
        os.remove(files)
    return filelist
    
#获取文件 完整目录,文件名,后缀名
def getPathInfo(pathname):
    pathname,filename=os.path.split(pathname)
    filename,filext=os.path.splitext(filename)
    return pathname,filename,filext

#日志配置
def log(filelog,level):
    global logger
    logger=logging.getLogger()
    LOG_FORMAT="%(asctime)s - %(levelname)s - %(message)s"
    logger.setLevel(level)
    fileHandler=logging.FileHandler(filelog,mode='a')
    fileHandler.setLevel(logging.DEBUG)
    formatter=logging.Formatter(LOG_FORMAT)
    fileHandler.setFormatter(formatter)
    ch=logging.StreamHandler()
    ch.setLevel(logging.INFO)
    ch.setFormatter(formatter)
    logger.addHandler(ch)
    logger.addHandler(fileHandler)


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

#处理客户端消息
def tcplink(bk_clent,bk_clentaddr):
    try:
        logger.info('位置:[{}] - 信息:[链接地址:{}:{}]'.format(sys._getframe().f_code.co_name,bk_clentaddr[0],bk_clentaddr[1]))
        ReqMsg=bk_clent.recv(BUFFER).decode()
        if ReqMsg.count('|')==1:
            requestack,requestuser=ReqMsg.split('|')
        else:
            bk_clent.send('error'.encode())
            bk_clent.close()
            return 0
        logger.info('用户标识:[{}] - 信息:[开始处理请求.]'.format(requestuser,)) 
        bk_commd=FileRequest(bk_clent)
        if requestack=='ACK' and userInfo(requestuser)==True: 
            logger.debug('用户标识:[{}] - 信息:[删除超过 {} 天的备份文件.]'.format(requestuser,confParm['store']))
            print('\t',delOTF(os.path.join(confParm['path'],requestuser),int(confParm['store'])))
            bk_clent.send('True'.encode())
            #等待接收请求指令
            logger.debug('用户标识:[{}] - 信息:[开始接受操作指令.]'.format(requestuser,)) 
            while True:            
                userReqMsg=bk_clent.recv(BUFFER).decode()
                if userReqMsg.count('|')==2:
                    bk_data_req,bk_data_info,bk_data_msg=userReqMsg.split('|')
                else:
                    bk_clent.send('error'.encode())
                    bk_clent.close()
                    break
                if bk_data_req=='upload':
                    if round(int(bk_data_msg) / 1024 / 1024,2) <= int(confParm['sizelimit']):
                        with open(os.path.join(confParm['path'],requestuser,bk_data_info+'$&$'+str(time.time())),'wb') as fp:
                            logger.info('用户标识:[{}] - 信息:[接受文件上传:{}.]'.format(requestuser,bk_data_info)) 
                            bk_clent.send('upload-ok'.encode()) 
                            if bk_commd.FileRecv(fp,bk_data_msg)==0:
                                logger.debug('用户标识:[{}] - 信息:[接收完成.]'.format(requestuser,))
                    else:
                        bk_clent.send('upload-error1'.encode())
                        logger.info('用户标识:[{}] - 信息:[上传文件超限:{} {}.]'.format(requestuser,bytes(int(bk_data_msg))[0],bytes(int(bk_data_msg))[1]))

                elif bk_data_req=='update':
                    logger.info('用户标识:[{}] - 信息:[发送更新:{}.]'.format(requestuser,updatefile)) 
                    if bk_data_info!=getFileMd5(updatefile):
                        bk_socket_info='True|'+os.path.basename(updatefile)+'|'+str(os.stat(updatefile).st_size)
                        bk_clent.send(bk_socket_info.encode())
                    if bk_clent.recv(BUFFER).decode()=='Waiting':
                       logger.info('用户标识:[{}] - 信息:[开始发送更新.]'.format(requestuser,)) 
                       with open(updatefile,'rb') as fp:
                           print(bk_commd.FileSend(fp,os.stat(updatefile).st_size))
                           logger.debug('用户标识:[{}] - 信息:[发送更新完成.]'.format(requestuser,)) 
                    else:
                        bk_clent.send('False||'.encode())
                        logger.info('用户标识:[{}] - 信息:[无需更新.]'.format(requestuser,))

                elif bk_data_req=='cmd':
                    logger.info('用户标识:[{}] - 信息:[发送指令:{}.]'.format(requestuser, confParm['command'])) 
                    bk_clent.send(confParm['command'].encode())

                elif bk_data_req=='list':
                    listSortDone=sortTime(os.path.join(confParm['path'],requestuser))
                    if listSortDone != None:
                        backFileList=json.dumps(listSortDone[-7:])
                    else:
                        backFileList='none'
                    logger.info('用户标识:[{}] - 信息:[发送备份文件列表:{}.]'.format(requestuser, backFileList))
                    bk_clent.send(backFileList.encode())
            
                elif bk_data_req=='down':
                    downfile=os.path.join(confParm['path'],requestuser,bk_data_info)
                    logger.info('用户标识:[{}] - 信息:[请求下载:{}.]'.format(requestuser, bk_data_info)) 
                    if os.path.isfile(downfile):
                        bk_socket_info='True|'+bk_data_info.split('$&$')[0]+'|'+str(os.stat(downfile).st_size)
                        bk_clent.send(bk_socket_info.encode())
                        if bk_clent.recv(BUFFER).decode()=='Waiting':
                            logger.info('用户标识:[{}] - 信息:[开始发送下载信息:{}.]'.format(requestuser, bk_data_info)) 
                            with open(downfile,'rb') as fp:
                                print(bk_commd.FileSend(fp,os.stat(downfile).st_size))
                                logger.debug('用户标识:[{}] - 信息:[发送下载信息完成.]'.format(requestuser,)) 

                elif bk_data_req=='close':
                    logger.info('用户标识:[{}] - 信息:[关闭链接.]'.format(requestuser,)) 
                    bk_clent.close()
                    break
                else:
                    bk_clent.send('error'.encode())
                    bk_clent.close()
                    break

        else:
            logger.info('用户标识:[{}] - 信息:[拒接访问.]'.format(requestuser,))
            bk_clent.close()
            return 1
    except BaseException as exeption:
        logger.info('位置:[{}] - 信息:[线程异常:{}'.format(sys._getframe().f_code.co_name,exeption))

#开启多线程服务
def ServerSocket():
    logpath=os.path.join(PATHNAME,FILENAME+'.log')
    log(logpath,logging.DEBUG)
    logger.info('位置:[{}] - 信息:[程序开始运行!]'.format(sys._getframe().f_code.co_name,))
    #创建socket,开始监听.
    bk_socket_s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
    bk_socket_s.bind(('0.0.0.0',int(confParm['port'])))
    bk_socket_s.listen(100)
    #等待接受新连接,并创建新的线程. 
    while True:
        bk_clent, bk_clentaddr = bk_socket_s.accept()
        bk_tcplink = threading.Thread(target=tcplink,args=(bk_clent,bk_clentaddr))
        logger.debug('位置:[{}] - 信息:[新的线程:{}!]'.format(sys._getframe().f_code.co_name,bk_tcplink))
        bk_tcplink.start()


#主要过程
def process():
    #初始化变量
    global CONFIG_FILE,BUFFER,SERVER_CONFIG_LIST,PATHNAME,FILENAME,USERCONF
    BUFFER = 1024
    CONFIG_FILE = os.path.join(getPathInfo(os.path.abspath(__file__))[0],'B-CloudS.conf')
    SERVER_CONFIG_LIST = ('port','path','store','command','store','sizelimit','updatefile')
    TYPE_CONFIG='ServerConf'
    PATHNAME,FILENAME,fileext=getPathInfo(os.path.abspath(__file__))
    USERCONF = os.path.join(PATHNAME,'userInfo.data')
    global showprocess,confParm
    showprocess = ShowProcess(100)
    #读取配置
    confParm=readconf(CONFIG_FILE,TYPE_CONFIG,SERVER_CONFIG_LIST)
    if len(sys.argv) > 1:
        confParm['cmdType'] = sys.argv[1]
    else:
        confParm['cmdType'] = None
    if confParm['cmdType'] == 'list':
        for w,x,y,z in userInfo():
            print('UID:{}  状态:{}  最新文件:{}  最新日期:{}'.format(w,x,y,formatTime(z)))
        return 0
    print(confParm)
    ServerSocket()



if __name__=='__main__':
    process()

