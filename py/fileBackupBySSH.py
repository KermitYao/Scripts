#!/usr/bin/python3
#Backup files to remote server
import paramiko,os,sys,time
import socket

class SSHTools():
    def __init__(self):
        self.hostname=None
        self.port=22
        self.username=None
        self.password=None
        self.timeout=10

    def connect(self):
        if self.hostname == None or self.port == None or self.username == None or self.password == None:
            logWrite('WARNING', sys._getframe().f_lineno, '参数不完整')
            return False
    
        self.sshClient = paramiko.SSHClient()
        self.sshClient.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            self.sshClient.connect(hostname=self.hostname, port=self.port, username=self.username, password=self.password, timeout=self.timeout)
            self.sftp = self.sshClient.open_sftp()
            return True
        except:
            logWrite('WARNING', sys._getframe().f_lineno, '主机连接失败：%s' % self.hostname)
            return False
    def exec(self,cmd):
        stdin, stdout, stderr = self.sshClient.exec_command(cmd)
        return stdout.read().decode('utf-8'),stderr.read().decode('utf-8')

    def ls(self,dir):
        return self.sftp.listdir(dir)
    
    def isFile(self,path):
        if self.exec('test -f %s&&printf True' % path)[0] == "True":
            return True
        return False

    def isDir(self,path):
        if self.exec('test -d %s&&printf True' % path)[0] == "True":
            return True
        return False

    def mkdir(self,path):
        if self.exec('mkdir -p %s&&printf True' % path)[0] == "True":
            return True
        return False

    def put(self,local,remote):
        return self.sftp.put(local,remote)
    
    def close(self):
        return self.sshClient.close()

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


def logWrite(errorType, codeLine, message):
    logLevel = 'INFO'
    logPath = __file__+'.log'

    if logLevel == 'DEBUG':
        logLevelList = ['DEBUG', 'INFO', 'WARNING', 'ERROR']
    elif logLevel == 'INFO':
        logLevelList = ['INFO', 'WARNING', 'ERROR']
    elif logLevel == 'WARNING':
        logLevelList = ['WARNING', 'ERROR']
    elif logLevel == 'ERROR':
        logLevelList = ['ERROR',]
    else:
        logLevelList = ['DEBUG', 'INFO', 'WARNING', 'ERROR']

    for item in logLevelList:
        if item == errorType:
            msg = '{0} -- {1} -- line:{2} -- {3}'.format(formatTime(time.time()), errorType, codeLine, message)
            print(msg)
            with open(logPath, 'a+') as f:
                f.write(msg+'\n')

def main():
    localhostname=socket.gethostname()
    remoteBackupDir='/data/backup/%s/' % localhostname
    localBackupDir='/home/360data/docker/cactus-web/system/data.restore/'
    sshTools = SSHTools()
    sshTools.hostname = '10.152.9.185'
    sshTools.username = 'root'
    sshTools.password = 'FXEDU_2023'
    if sshTools.connect():
        if not sshTools.isDir(remoteBackupDir):
            sshTools.exec('mkdir -p %s' % remoteBackupDir)
        for r,d,f in os.walk(localBackupDir):
            relPath = r.replace(localBackupDir, '')
            for name in d:
                remoteDir = os.path.join(remoteBackupDir,relPath,name).replace('\\','/')
                if not sshTools.isDir(remoteDir):
                    logWrite('INFO', sys._getframe().f_lineno, '创建远程目录：%s' % remoteDir)
                    sshTools.mkdir(remoteDir)

            for name in f:
                localFile = os.path.join(r,name).replace('/',os.sep)
                remoteFile = os.path.join(remoteBackupDir,relPath, name).replace('\\','/')
                if not sshTools.isFile(remoteFile):
                    logWrite('INFO', sys._getframe().f_lineno, '开始上传文件：%s' % localFile)
                    sshTools.put(localFile, remoteFile)
        return sshTools.close()
    
if '__main__' == __name__:
    main()
