'''
#code by ngrain@Deepin Linux&Python3 @ w.20180516,c.20180522

本程序本质为邮件发送程序。
其主要功能表现为:
    1.自动对比要发送的附件改动日期是否与当日的日期一致,一致则发送一封邮件到接收人,不一致则表示为发送失败。
    2.发送失败则自动发送一封包含日志的提醒邮件到指定邮箱.
    3.在一个指定的目录里选择一张图片添加进邮件贴图。


    
'''

#-*- coding:utf-8 -*-

#导入相关库
import datetime,time,os,smtplib,random,sys
from email import encoders
from email.header import Header
from email.mime.text import MIMEText
from email.utils import parseaddr, formataddr
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase

#获取文件 完整目录,文件名,后缀名
def get_filename(filepath):
    pathname,filename=os.path.split(filepath)
    filename,filext=os.path.splitext(filename)
    return pathname,filename,filext


#邮件发送函数实现,参数列表依次是[邮箱地址,邮箱密码,接收邮箱地址,邮件服务器,邮件标题,邮件正文,邮件附件,邮件贴图,邮件发送人,邮件接收人],强制 [mail_from, mail_pwd, mail_to]　必须传递。

def mail_send(mail_info):
    try:
        logging.debug('位置:[{}] - 信息:[参数列表[:{}]]'.format(sys._getframe().f_code.co_name, mail_info))
        def _format_addr(mail_addr):
            name,addr=parseaddr(mail_addr)
            return formataddr((Header(name,'utf-8').encode(),addr))

        #构建邮件头部
        logging.debug('位置:[{}] - 信息:[构造邮件头部]'.format(sys._getframe().f_code.co_name,))
        msg=MIMEMultipart('alternative')
        msg['From']=_format_addr('%s <%s>' % (mail_info['mail_by'], mail_info['mail_from']))
        msg['To']=_format_addr('%s <%s>' % (mail_info['mail_tos'], mail_info['mail_to']))
        msg['Subject']=Header(mail_info['mail_title'], 'utf-8').encode()
        #构建附件
        
        def add_attach(path, cid):
            logging.debug('位置:[{}] - 信息:[参数列表:{},{}]'.format(sys._getframe().f_code.co_name,path,cid))
            fpath,fname,fext=get_filename(path)
            with open(path, 'rb') as mailfile:
                mime=MIMEBase(fext[1:], fname, filename=fname+fext)
                mime.add_header('Content-Disposition', 'attachment', filename=fname+fext)
                mime.add_header('Content-ID', '<{}>'.format(cid))
                mime.add_header('X-Attachment-Id', '0')
                mime.set_payload(mailfile.read())
                encoders.encode_base64(mime)
            return mime
        #开始发送
        if mail_info['mail_attach'] != 'none':
            logging.debug('位置:[{}] - 信息:[加载附件]'.format(sys._getframe().f_code.co_name,))
            msg.attach(add_attach(mail_info['mail_attach'],0))
        if mail_info['mail_image'] != 'none':
            logging.debug('位置:[{}] - 信息:[加载图片]'.format(sys._getframe().f_code.co_name,))
            msg.attach(add_attach(mail_info['mail_image'],1))
            msg.attach(MIMEText(mail_info['mail_msg'] + '<html><body>' + '<p><img src="cid:1"></p>' + '</body></html>', 'html', 'utf-8'))
        msg.attach(MIMEText(mail_info['mail_msg'], 'plain', 'utf-8'))
        server=smtplib.SMTP_SSL(mail_info['mail_smtp'],465)
        logging.debug('位置:[{}] - 信息:[登录邮箱服务器]'.format(sys._getframe().f_code.co_name,))
        server.login(mail_info['mail_from'],mail_info['mail_pwd'])
        logging.debug('位置:[{}] - 信息:[开始发送邮件]'.format(sys._getframe().f_code.co_name,))
        server.sendmail(mail_info['mail_from'],[mail_info['mail_to']],msg.as_string())
        #server.set_debuglevel(2)
        server.quit()
        logging.debug('位置:[{}] - 信息:[发送完成!]'.format(sys._getframe().f_code.co_name,))
        return 0
    except Exception as exeption:
        logging.error('位置:[{}] - 信息:[程序出错,报错信息:[{}]]'.format(sys._getframe().f_code.co_name,exeption))
        return 1

        
#随机在传入参数的目录里选择一张图片
def choose_image(image_dir):
    try:
        logging.debug('位置:[{}] - 信息:[参数列表:[{}]]'.format(sys._getframe().f_code.co_name,image_dir))
        image_list=[os.path.join(image_dir,i) for i in os.listdir(image_dir) if os.path.isfile(os.path.join(image_dir,i))==True]
        image_file=image_list[random.randint(0,len(image_list))]
        if os.path.isfile(image_file):
            logging.debug('位置:[{}] - 信息:[选取到的图片为:[{}]]'.format(sys._getframe().f_code.co_name,image_file))
            return (0,image_file)
        else:
            logging.warning('位置:[{}] - 信息:[未能正确的选取一个文件!'.format(sys._getframe().f_code.co_name,))
            return (2,'none')
    except Exception as exeption:
        logging.error('位置:[{}] - 信息:[程序出错,报错信息:[{}]]'.format(sys._getframe().f_code.co_name,exeption))
        return (3,'none')
        
#获取附件的修改时间,并判断是否为当天修改.
def com_time(file_path):
    try:
        logging.debug('位置:[{}] - 信息:[参数列表:[{}]]'.format(sys._getframe().f_code.co_name,file_path))
        attach_time=[time.localtime(os.stat(file_path).st_mtime)[i] for i in (0,1,2)]
        local_time=[time.localtime(time.time())[i] for i in (0,1,2)]
        if attach_time==local_time:
            logging.debug('位置:[{}] - 信息:[文件改动时间对比一致!]'.format(sys._getframe().f_code.co_name,))
            return 0
        else:
            logging.warning('位置:[{}] - 信息:[文件改动时间不是当天的!]'.format(sys._getframe().f_code.co_name,))
            return 4
    except Exception as exeption:
        logging.error('位置:[{}] - 信息:[程序出错,报错信息:[{}]]'.format(sys._getframe().f_code.co_name,exeption))
        return 5

        
#读取配置文件
    
def readconf(filename, section,sendtuple):
    import configparser
    try:
        logging.debug('位置:[{}] - 信息:[参数列表:[{},{}]]'.format(sys._getframe().f_code.co_name,filename,section))
        tmp_dict={}
        conf=configparser.ConfigParser()
        conf.read(filename,encoding='utf-8-sig')
        #构建配置信息为 dict
        for n in range(len(sendtuple)):
            for option in conf.options(section):            
                if sendtuple[n]==option:
                    if conf.get(section,option)=='':
                        tmp_dict[option]='none'
                        break
                    else:
                        tmp_dict[option]=conf.get(section,option)
                        break
            if sendtuple[n] not in tmp_dict.keys():
                tmp_dict[sendtuple[n]]='none'
            
        #修正参数
        logging.debug('位置:[{}] - 信息:[修正参数]'.format(sys._getframe().f_code.co_name,))
        local_time=time.localtime(time.time())
        
        tmp_dict['mail_image']=choose_image(tmp_dict['mail_image'])[1]
        
        if tmp_dict['mail_notice']=='none':
                tmp_dict['mail_notice']=tmp_dict['mail_from']

        if tmp_dict['mail_title']=='none':
                tmp_dict['mail_title']=str(local_time[0])+'年'+str(local_time[1])+'月'+str(local_time[2])+'日,来自 [{}]'.format(get_filename(tmp_dict['mail_attach'])[1]+get_filename(tmp_dict['mail_attach'])[2],)
                
        if tmp_dict['mail_msg']=='none':
                tmp_dict['mail_msg']=str([local_time[i] for i in (0,1,2,3,4,5)])

        if tmp_dict['mail_by']=='none':
                tmp_dict['mail_by']=tmp_dict['mail_from'].split('@')[0]

        if tmp_dict['mail_tos']=='none':
                tmp_dict['mail_tos']=tmp_dict['mail_to'].split('@')[0]
                
        logging.debug('位置:[{}] - 信息:[取得配置参数:[{}]]'.format(sys._getframe().f_code.co_name,tmp_dict))
        return tmp_dict
    except Exception as exeption:
        logging.error('位置:[{}] - 信息:[程序出错,报错信息:[{}]]'.format(sys._getframe().f_code.co_name,exeption))
        return 8
        


    
#主要过程        
def process(mail_info):
    try:
        #解析参数    
        logging.debug('位置:[{}] - 信息:[信息处理开始.]'.format(sys._getframe().f_code.co_name,)) 
        if mail_info['mail_com']=='yes':
            if com_time(mail_info['mail_attach'])==0:
                if mail_send(mail_info)==0:
                    logging.debug('位置:[{}] - 信息:[邮件发送成功!]'.format(sys._getframe().f_code.co_name,))
                    return 0 
                else:
                    logging.warning('位置:[{}] - 信息:[邮件发送失败!]'.format(sys._getframe().f_code.co_name,))
                    return 6
            else:
                logging.warning('位置:[{}] - 信息:[邮件发送失败,在校对附件时出错!]'.format(sys._getframe().f_code.co_name,))
                return 7
        else:
            if mail_send(mail_info)==0:
                logging.debug('位置:[{}] - 信息:[邮件发送成功!]'.format(sys._getframe().f_code.co_name,))
                return 0 
            else:
                logging.warning('位置:[{}] - 信息:[邮件发送失败!]'.format(sys._getframe().f_code.co_name,))
                return 6
    except Exception as exeption:
        logging.error('位置:[{}] - 信息:[程序出错,报错信息:[{}]]'.format(sys._getframe().f_code.co_name,exeption))
        return 5

        
if __name__=='__main__':
    #预设日志相关参数.
    import logging
    x,y,z=get_filename(os.path.abspath(__file__))
    logpath=os.path.join(x,y+'.log')
    LOG_FORMAT="%(asctime)s - %(levelname)s - %(message)s"
    logging.basicConfig(filename=logpath,level=logging.DEBUG,format=LOG_FORMAT)
    logging.debug('位置:[{}] - 信息:[程序开始运行!]'.format(__name__,))

    #读取配置文件
    sendtuple=('mail_from', 'mail_pwd', 'mail_to', 'mail_smtp', 'mail_title', 'mail_msg', 'mail_attach', 'mail_image', 'mail_by','mail_notice','mail_tos','mail_com')
    load_conf=readconf(os.path.join(x,y+'.conf'),y,sendtuple)

    #发送提醒邮件
    if load_conf != '8':
        if process(load_conf) != 0:
            logging.warning('位置:[{}] - 信息:[邮件发送失败,开始发送通知邮件!]'.format(__name__,))
            load_conf['mail_attach']=logpath
            load_conf['mail_image']='none'
            load_conf['mail_to']=load_conf['mail_notice']
            load_conf['mail_msg']='邮件发送失败了!'
            load_conf['mail_com']='none'
            if mail_send(load_conf)==0:
                logging.warning('位置:[{}] - 信息:[通知邮件发送成功,程序结束运行!]'.format(__name__,))
                print('发送失败,已通知!')
            else:
                logging.warning('位置:[{}] - 信息:[通知邮件发送失败,程序结束运行!]'.format(__name__,))
                print('通知邮件发送失败!')
        else:
            logging.debug('位置:[{}] - 信息:[邮件发送成功,程序结束运行!]'.format(__name__,))
            print('发送成功!')
