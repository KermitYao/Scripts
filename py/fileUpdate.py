
#!/usr/bin/python3
# -*- coding: utf-8 -*-
import time
import hashlib
import json
from urllib.request import urlopen
import os, shutil, sys,glob
def getMd5(filePath):
    return hashlib.md5(open(filePath, 'rb').read()).hexdigest()

def getWorkingCount(filesInfo):
    workingCount=0
    for item in filesInfo:
        if item['doneStatus'] == 'none' or item['doneStatus'] == 'working':
            workingCount += 1
    return workingCount

#获取文件 完整目录,文件名,后缀名
def getPathInfo(filepath):
    pathname,filename=os.path.split(filepath)
    filename,filext=os.path.splitext(filename)
    return pathname,filename,filext

def removeFile(ext):
    fileList = glob.glob(ext)
    for item in fileList:
        os.remove(item)
    return fileList

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
    logPath = '/var/log/kermit/fileUpdate.log'

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
class Aria2Rpc():
    def __init__(self,rpcHost='http://127.0.0.1:6800/jsonrpc', rpcDir='/data/file/backup/Download/rpcDown/'):
        self.rpcHost = rpcHost
        self.rpcDir  =  rpcDir
        self.rpcPasswd = 'pw_80235956'
        self.rpcJson = {
                        'jsonrpc': '2.0',
                        'id':'filename',
                        'method': 'aria2.addUri',
                        'params': [
                                ['http://localhost/test.txt'],
                                {
                                    'dir':self.rpcDir,
                                    'out':'filename'
                                }
                        ],
                    }

    def __req(self):
        tmpRpcJsonParams = self.rpcJson['params']
        tmpRpcJsonParams.insert(0, 'token:%s' % self.rpcPasswd)
        self.rpcJson['params'] = tmpRpcJsonParams
        logWrite('DEBUG', sys._getframe().f_lineno, '__req请求:%s' % self.rpcJson)
        try:
            result = urlopen(self.rpcHost, json.dumps(self.rpcJson).encode())
            result = json.loads(result.read().decode())
            result['httpStatus'] = True
            return result
        except  Exception as e:
            return {'httpStatus':False}

    def download(self,url,name):
        self.rpcJson['id'] = name
        self.rpcJson['method'] = 'aria2.addUri'
        self.rpcJson['params']=[[url], {'dir':self.rpcDir, 'out':name}]
        return self.__req()
    
    def getStatus(self,gid):
        self.rpcJson['method'] = 'aria2.tellStatus'
        self.rpcJson['params'] = [gid, ['gid','status']]
        return self.__req()

    
    def remove(self,gid,id='qwer'):
        self.rpcJson['id'] = id
        self.rpcJson['method'] = 'aria2.remove'
        self.rpcJson['params'] = [gid,]
        return self.__req()

    def removeResult(self,gid,id='qwer'):
        self.rpcJson['id'] = id
        self.rpcJson['method'] = 'aria2.removeDownloadResult'
        self.rpcJson['params'] = [gid,]
        return self.__req()

    def getMethods(self):
        self.rpcJson['method'] = 'system.listMethods'
        return self.__req()

    def getDownTotal(self,id='qwer'):
        self.rpcJson['id'] = id
        self.rpcJson['method'] = 'aria2.getGlobalStat'
        r = self.__req()
        if r['httpStatus']:
            r['downTotal'] = int(r['result']['numActive']) + int(r['result']['numWaiting'])
        return r

def main():
    logWrite('INFO', sys._getframe().f_lineno, '启动主进程')
    #临时文件主目录
    rpcDir = '/data/file/backup/Download/rpcDir'
    #程序开始时间
    startTime = time.time()
    #允许程序运行最大时间
    maxTime = 7200
    #最大并发下载数
    maxDowns = 5
    sleepTime = 5
    rpc = Aria2Rpc()
    #none|done|working|fail
    filesInfo = [
        {
            'name':'agent-linux-x86_64_later.sh',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/Agent',
            'url':'https://download.eset.com/com/eset/apps/business/era/agent/latest/agent-linux-x86_64.sh',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'agent-linux-i386_later.sh',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/Agent',
            'url':'https://download.eset.com/com/eset/apps/business/era/agent/latest/agent-linux-i386.sh',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'agent_x64_later.msi',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/Agent',
            'url':'https://download.eset.com/com/eset/apps/business/era/agent/latest/agent_x64.msi',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'agent_x32_later.msi',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/Agent',
            'url':'https://download.eset.com/com/eset/apps/business/era/agent/latest/agent_x86.msi',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'eea_nt64_later.msi',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/PC',
            'url':'https://download.eset.com/com/eset/apps/business/eea/windows/latest/eea_nt64.msi',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'eea_nt32_later.msi',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/PC',
            'url':'https://download.eset.com/com/eset/apps/business/eea/windows/latest/eea_nt32.msi',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'efsw_nt64_later.msi',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/Server',
            'url':'https://download.eset.com/com/eset/apps/business/efs/windows/latest/efsw_nt64.msi',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'efsw_nt32_later.msi',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/Server',
            'url':'https://download.eset.com/com/eset/apps/business/efs/windows/latest/efsw_nt32.msi',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'eeau.x86_64_later.bin',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/PC',
            'url':'https://download.eset.com/com/eset/apps/business/eea/linux/g2/latest/eeau.x86_64.bin',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'efs.x86_64_later.bin',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/CLIENT/Server',
            'url':'https://download.eset.com/com/eset/apps/business/efs/linux/latest/efs.x86_64.bin',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
        {
            'name':'x64_later.zip',
            'dir':'/data/file/backup/Company/YCH/EEAI/ESET/EP',
            'url':'https://download.eset.com/com/eset/apps/business/era/allinone/latest/x64.zip',
            'gid':'none',
            'downStatus':'none',
            'time':'none',
            'md5':'none',
            'downPath':'none',
            'doneStatus':'none',
        },
    ]

    logWrite('DEBUG', sys._getframe().f_lineno, '进入循环')
    while True:
        if time.time() - startTime > maxTime:
            logWrite('WARNING', sys._getframe().f_lineno, '超过时间限制:%s' % str(time.time() - startTime > maxTime))
            for item in filesInfo:
                logWrite('WARNING', sys._getframe().f_lineno, '超时,清理任务:%s' % item['name'])
                rpc.remove(item['gid'])
            break

        logWrite('INFO', sys._getframe().f_lineno, '剩余待处理项: %s' % getWorkingCount(filesInfo))
        if not getWorkingCount(filesInfo) > 0:
            logWrite('INFO', sys._getframe().f_lineno, '全部处理完成,退出程序')
            break
        
        logWrite('DEBUG', sys._getframe().f_lineno, '开始处理状态信息')
        for item in filesInfo:
            #当状态为 完成或者失败时,跳过
            logWrite('DEBUG', sys._getframe().f_lineno, '当前处理项: %s' % item['name'])
            logWrite('DEBUG', sys._getframe().f_lineno, '当前处理项下载状态: %s' % item['downStatus'])
            if item['doneStatus'] == 'done' or item['doneStatus'] == 'fail':
                continue
            else:
                #当下载为 完成或者失败时,跳过
                if item['downStatus'] == 'fail':
                    rpc.removeResult(item['gid'])
                    item['doneStatus'] = 'fail'
                elif item['downStatus'] == 'done':
                    item['downPath'] = os.path.join(rpc.rpcDir, item['name'])
                    logWrite('DEBUG', sys._getframe().f_lineno, '进行最终处理:%s' % item['downPath'])
                    
                    if os.path.isfile(item['downPath']):
                        md5Value = getMd5(item['downPath'])
                        item['md5'] = md5Value
                        itemFileName = os.path.join(item['dir'],item['name'])
                        if os.path.isfile(item['downPath']):
                            logWrite('INFO', sys._getframe().f_lineno, '复制文件到:%s' % itemFileName)
                            tmp = shutil.copy(item['downPath'], itemFileName)
                        tmpFileName = os.path.join(item['dir'], os.path.split(itemFileName)[1] + '_' + formatTime(item['time'],type=2) + '.log')
                        tmpFileInfo = '''
                            文件名:{0}
                                MD5:{1}
                            更新日期:{2}
                            文件大小:{3} KB
                        '''.format(item['name'], item['md5'], formatTime(item['time']), os.path.getsize(itemFileName))
                        ext = os.path.join(item['dir'], os.path.split(itemFileName)[1] + '_' + '*' + '.log')
                        logWrite('INFO', sys._getframe().f_lineno, '清理旧的文件摘要: %s' % ext)
                        oldFile = removeFile(ext)
                        with open(tmpFileName,'w') as f:
                            f.write(tmpFileInfo)
                        logWrite('INFO', sys._getframe().f_lineno, '移除下载信息: %s' % item['gid'])
                        rpc.removeResult(item['gid'])
                        item['doneStatus'] = 'done'
                    else:
                        logWrite('ERROR', sys._getframe().f_lineno, '无法找到已下载的文件:%s' % item['downPath'])
                        item['doneStatus'] = 'fail'
                        logWrite('INFO', sys._getframe().f_lineno, '移除下载信息: %s' % item['gid'])
                        rpc.removeResult(item['gid'])
                #当下载为 工作中,跳过
                elif item['downStatus'] == 'working':
                    result = rpc.getStatus(item['gid'])
                    logWrite('DEBUG', sys._getframe().f_lineno, '下载状态检查: %s' % result)
                    if result['httpStatus']:
                        if result['result']['status'] == 'complete':
                            logWrite('DEBUG', sys._getframe().f_lineno, '进入 complete')
                            item['downStatus'] = 'done'
                        elif result['result']['status'] == 'error':
                            item['downStatus'] = 'fail'
                #当总下载为 未处理时,开始添加下载进程
                elif item['downStatus'] == 'none':
                    while True:
                        downTotal = rpc.getDownTotal()
                        if downTotal['httpStatus'] == True and downTotal['downTotal'] >= maxDowns:
                            logWrite('DEBUG', sys._getframe().f_lineno, '并发总数: %s' % downTotal['downTotal'])
                            time.sleep(sleepTime)
                        else:
                            break
                    logWrite('INFO', sys._getframe().f_lineno, '清理旧文件:%s' % os.path.join(rpc.rpcDir, item['name']))
                    removeFile(os.path.join(rpc.rpcDir, item['name']))
                    logWrite('INFO', sys._getframe().f_lineno, '添加下载进程:%s' % item['url'])
                    result = rpc.download(item['url'], item['name'])

                    #当添加下载进程返回失败时，跳过，等待下个轮回
                    if result['httpStatus']:
                        item['gid'] = result['result']
                        item['time'] = time.time()
                        item['downStatus'] = 'working'
                    else:
                        logWrite('WARNING', sys._getframe().f_lineno, '添加下载任务失败:%s' % result)
                else:
                    continue
        logWrite('DEBUG', sys._getframe().f_lineno, '等待下载状态更新: %s 秒' % sleepTime)
        time.sleep(sleepTime)
                    



if __name__ == '__main__':
    main()
    #frp = Aria2Rpc()
    #print(frp.download('https://download.eset.com/com/eset/apps/business/eea/windows/latest/eea_nt32.msi', 'test'))