import requests
from datetime import datetime
from email import encoders
from email.header import Header
from email.mime.text import MIMEText
from email.utils import parseaddr, formataddr
import smtplib
import os,sys,time
import socket
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

def save_mail(msg=None,count=2):
    strftime = time.strftime('%Y-%m-%d')
    with open(os.path.join(sys.path[0], 'sendMail.dat'), 'r+') as f:
        send_count = str(f.readlines()).count(strftime)
        if send_count == 0:
            f.truncate()
            f.writelines
            f.write(strftime + ' ' + msg + '\n')
            return True
        elif send_count<count:
            f.write(strftime + ' ' + msg + '\n')
            return True
        else:
            return False
    True

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

def sendMail(from_addr, password, to_addr, smtp_server, form_msg): 
    def _format_addr(send_format):
        name, addr = parseaddr(send_format)
        return formataddr((Header(name, 'utf-8').encode(), addr))
    msg = MIMEText(form_msg, 'plain', 'utf-8')
    msg['From'] = _format_addr('Python robot <%s>' % from_addr)
    msg['To'] = _format_addr('NGRAIN <%s>' % to_addr)
    if len(ccList) > 0:
        msg['Cc'] = _format_addr(ccList)
    msg['Subject'] = Header('EPP 服务器存活监测', 'utf-8').encode()
    try:
        server = smtplib.SMTP_SSL(smtp_server, 465)
        #server.set_debuglevel(1)
        server.login(from_addr, password)
        server.sendmail(from_addr, [to_addr]+ccList, msg.as_string())
        server.quit()
        return True
    except smtplib.SMTPException as e:
        logWrite('ERROR', sys._getframe().f_lineno, '邮件发送错误报告: %s' % e)
        return False

def urlTest(url):
    logWrite('INFO', sys._getframe().f_lineno, '测试服务器:%s 是否存活' % url)
    try:
        r = requests.get(url,timeout=5)
        if r.status_code == 200:
            return True
        else:
            return False
    except:
        return False

def main():
    localhostname=socket.gethostname()
    for url in urlList:
        if urlTest(url):
            logWrite('INFO', sys._getframe().f_lineno, '服务器:%s 运行正常' % url)
        else:
            logWrite('WARNING', sys._getframe().f_lineno, '服务器:%s 运行异常' % url)
            msg = url+' 无法访问,请尽快处理' + '\nname:' + localhostname + '\n时间: ' + formatTime(time.time()) + '\nIP: ' + socket.gethostbyname(localhostname)
            if save_mail(msg,3):
                if sendMail('714580117@qq.com', 'jfbyhvwwtaxrbefj', 'kermit.yao@qq.com', 'smtp.qq.com', msg):
                    logWrite('INFO', sys._getframe().f_lineno, '邮件发送正常')
                else:
                    logWrite('WARNING', sys._getframe().f_lineno, '邮件发送异常')
    return True

if __name__ == '__main__':
    urlList = ["http://10.152.9.185:8081", "http://10.152.9.220:8081", "http://10.152.10.97:8081"]
    ccList = ["714580117@qq.com"]
    main()
