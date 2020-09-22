#-*-coding:utf-8-*-
from aliyunpublic import ALiYunPublic as ali
from urllib import request
import json,re
import os,sys,time,requests

class DomainNameResolution():
    def __init__(self,accessID,accessKey):
        self.urlPath='http://alidns.aliyuncs.com/?'
        self.dnsRes=ali()
        self.dnsRes.setAccessInfo(accessID,accessKey)
        action=''
    
    def __feed(self):
        self.dnsRes.setAction(self.action)
        self.dnsRes.update()
        return self.dnsRes.sendRequest()

    def addRes(self,domainName,rr,value,type='A'):
        self.action={
            'Action':'AddDomainRecord',
            'DomainName':domainName,
            'RR':rr,
            'Value':value,
            'Type':type
        }
        return json.loads(self.__feed())


    def delRes(self,recordld):
        self.action={
            'Action':'DeleteDomainRecord',
            'RecordId':recordld
        }

        return json.loads(self.__feed())

    def updateRes(self,recordld,rr,value,type='A'):
        self.action={
            'Action':'UpdateDomainRecord',
            'RecordId':recordld,
            'RR':rr,
            'Type':type,
            'Value':value
        }

        return json.loads(self.__feed())

    def queryRes(self,domainName,rrKeyWord='',pageNumber='1',pageSize='20',typeKeyWord='',valueKeyWord=''):
        self.action={
            'Action':'DescribeDomainRecords',
            'DomainName':domainName,
            'PageNumber':pageNumber,
            'PageSize':pageSize,
            'RRKeyWord':rrKeyWord,
            'TypeKeyWord':typeKeyWord,
            'ValueKeyWord':valueKeyWord
        }

        return json.loads(self.__feed())

    def querySubRes(self,recordld,pageNumber='1',pageSize='20',type=''):
        self.action={
            'Action':'DescribeSubDomainRecords',
            'SubDomain':recordld,
            'PageNumber':pageNumber,
            'PageSize':pageSize,
            'Type':type
        }

        return json.loads(self.__feed())

#debug输出
def errorLog(func):
    def wrapper(*args, **kwargs):
        msg='\t%s---FUNC:%s,ARGS:%s,KWARGS:%s' % (formatTime(time.time(),1),func,args,kwargs)
        if DEBUGS:
            print(msg)
            with open(dname,'a') as f:
                f.write(msg+'\n')
        else:
            pass
            #print(msg)
        return func(*args, **kwargs)
    return wrapper



def getPathInfo(pathname):
    pathname,filename=os.path.split(pathname)
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

def checkIp(ipAddr):
  compile_ip=re.compile('^(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|[1-9])\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)\.(1\d{2}|2[0-4]\d|25[0-5]|[1-9]\d|\d)$')
  if compile_ip.match(ipAddr):
    return True  
  else:  
    return False

def getIp():
    headers = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0'}
    urlA='https://www.taobao.com/help/getip.php'
    urlB='http://whois.pconline.com.cn/ipJson.jsp'
    urlList=[{
        'url':'https://api.ipify.org/?format=json',
        'key':'ip'
        },
        {
        'url':'https://jsonip.com/',
        'key':'ip'
        },
        {
        'url':'http://ifconfig.io/all.json',
        'key':'ip'
        },
        {
        'url':'http://ip.taobao.com/service/getIpInfo.php?ip=myip',
        'key':'ip'
        },

        ]

    for info in urlList:
        try:
            r = requests.get(info['url'],headers=headers,timeout=5)
            msg=msg='外网ip原始结果,url:{},msg:{}'.format(info['url'],r.text)
            logging.debug(msg)
            if r.status_code == 200:
                ipAddr = r.json()[info['key']]
                if checkIp(ipAddr):
                    return ipAddr
        except Exception:
            msg='请求ip地址错误,url:{},msg:{}'.format(info['url'],Exception)
            logging.debug(msg)


def process():
    def getDNSInfo():
        try:
            dnsValue=alidns.querySubRes(addns+'.'+rootdns)
            if 'DomainRecords' in dnsValue:
                if len(dnsValue['DomainRecords']['Record']) == 0:
                    return 2
                else:
                    return dnsValue['DomainRecords']['Record'][0]
            else:
                msg='原始信息,msg:{}'.format(dnsValue)
                logging.error(msg)
                return 1

        except Exception:
            msg='查询子域名出错,msg:{}'.format(Exception)
            logging.error(msg, exc_info=True)
            return msg
    #配置域名信息
    accessID = 'id'
    accessKey = 'key'
    alidns=DomainNameResolution(accessID,accessKey)
    rootdns='yjyn.top'
    addns='ych'
    if addns==None:
        addns='@'

    #开始解析
    logging.debug('正在处理解析...')
    try:
        netIp=getIp()
        if netIp==None:
            msg='获取外网地址失败,msg：{}'.format(netIp)
            logging.warning(msg)
            return 4001
        msg='获取外网地址成功,msg：[{}]'.format(netIp)
        logging.info(msg)
        dnsInfo=getDNSInfo()
        if dnsInfo==1:
            msg='域名不存在,或查询失败,msg：{}'.format(rootdns)
            logging.warning(msg)
        elif dnsInfo==2:
            msg='子域名不存在,开始添加,msg:{}'.format(addns+'.'+rootdns)
            logging.warning(msg)
            addDNS=alidns.addRes(rootdns,addns,netIp)
        elif 'RecordId' in dnsInfo:
            if dnsInfo['Value']==netIp:
                msg='记录值正确,无需更新,msg:{}'.format(addns+'.'+rootdns+'>'+dnsInfo['Value'])
                logging.info(msg)
            else:
                msg='记录值不一致,开始更新,msg:{}'.format(addns+'.'+rootdns+'>'+dnsInfo['Value'])
                logging.info(msg)
                updateDNS=alidns.updateRes(dnsInfo['RecordId'],addns,netIp)
                msg='更新返回结果,msg:{}'.format(updateDNS)
                logger.debug(msg)
    except Exception:
        logger.error('Errors in the loop process', exc_info=True)

#doemo
if __name__ == '__main__':
    #---------------------------------------
    #预设日志相关参数.
    import logging
    x,y,z=getPathInfo(os.path.abspath(__file__))
    #logPath=os.path.join(x,y+'.log')
    #logPath=os.path.join(sys.path[0] ,'debug_'+str(formatTime(time.time(),2))+'.log')
    logPath=os.path.join(sys.path[0] ,'dnstools_debug'+'.log')
    #logging.basicConfig(level=logging.DEBUG,format=LOG_FORMAT)
    #debug>info>warning,error
    LOG_FORMAT=logging.Formatter("%(asctime)s - %(filename)s[line:%(lineno)d] - %(funcName)s - %(levelname)s - %(message)s")
    logger = logging.getLogger()
    logger.setLevel(level=logging.DEBUG)
    
    #设置文件日志输出
    handler=logging.FileHandler(logPath)
    handler.setLevel(logging.DEBUG)
    handler.setFormatter(LOG_FORMAT)

    #设置控制台日志输出
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    console.setFormatter(LOG_FORMAT)

    logger.addHandler(handler)
    logger.addHandler(console)
    #----------------------------------------

    def addResolution():
        addDNS=alidns.addRes('yjyn.top','nnn','22.22.22.22')
        return addDNS

    def delResolution():
        delDNS=alidns.delRes('4024881799599104')
        return delDNS

    def updateResolution():
        updateDNS=alidns.updateRes('4025342508177408','ppp','180.76.76.76')
        return updateDNS
    
    outTime=180
    DEBUGS=True
    process()
