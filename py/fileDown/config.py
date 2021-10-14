#This script is config file for "web.py"
import os
class Config():
    #Start debugging or not
    DEBUG = False
    #Http request port
    PORT  = 6081
    
    #At client display character string.
    DISPLAY_TEXT = ['.txt', '.log', '.sh', '.py', '.bat', '.cmd', '.ini', '.conf', '.html', '.xml', '.css', '.cfg']
    tmpList_A = [s.lower() for s in DISPLAY_TEXT if isinstance(s,str)==True]
    tmpList_a = [s.upper() for s in DISPLAY_TEXT if isinstance(s,str)==True]
    DISPLAY_TEXT = tmpList_A + tmpList_a
    # X/MB
    DISPLAY_TEXT_MAX = 1

    #At client play video
    PLAY_VIDEO = ['.mp4', '.ogg', '.webm']
    tmpList_B = [s.lower() for s in PLAY_VIDEO if isinstance(s,str)==True]
    tmpList_b = [s.upper() for s in PLAY_VIDEO if isinstance(s,str)==True]
    PLAY_VIDEO = tmpList_B + tmpList_b

    
    #If system is "Windows" then 
    if os.name=='nt':
        #File show root 
        ROOT_DIR=r'd:'
        #Video show root
        VIDEO_DIR=r'd:'
        #Where is Upload file? 
        UPLOAD_DIR=r'd:\Tmp'
        #Picture show root
        PHOTO_DIR=r'y:\PHOTO'
        #The CSS
        TEXT_DIR=os.path.dirname(__file__)
    #If system is "Linux" then    
    else:
        ROOT_DIR=r'/media/kermit/Tools'
        VIDEO_DIR=r'/media/dataCenter/VIDEO/sexVIDEO'
        UPLOAD_DIR=os.path.join(ROOT_DIR, '/Tmp')
        PHOTO_DIR=r'/media/dataCenter/PIC/sexPIC'
        TEXT_DIR=os.path.dirname(__file__)


    #Upload file max
    UPLOAD_SIZE=500
    #Only key
    SECRET_KEY = 'A0Zr98j/3yX R~XHH!jmN]LWX/,?RT20200612'
    #user info
    USER_INFO=[
        {
            'u':'root',
            'p':'yk@555698',
            'l':3
        },
        {
            'u':'guest',
            'p':'yk@555698',
            'l':1
        },
        {
            'u':'ngrain',
            'p':'yk@555698',
            'l':2
        }
    ] 

    ROUTE=[
            {   
                'name':'baota',
                'hosta':'http://192.168.17.91:8888',
                'hostb':'http://baota.yjyn.top:6080',
                'user':'baota',
                'passwd':'pw80235956',
                'describe':'宝塔linux管理面板',
            },

            {
                'name':'pytools',
                'hosta':'http://192.168.17.91:6081',
                'hostb':'http://yjyn.top:1443',
                'user':'guest',
                'passwd':'pw80235956',
                'describe':'python 下载站点',
            },

            {
                'name':'aria2',
                'hosta':'http://192.168.17.91:6084',
                'hostb':'http://download.yjyn.top:6080',
                'user':'admin',
                'passwd':'pw80235956',
                'describe':'aria2 下载面板',
            },

            {
                'name':'datassh',
                'hosta':'192.168.17.91:22',
                'hostb':'yjyn.top:22',
                'user':'root',
                'passwd':'pw_80235956',
                'describe':'网络服务中心 ssh',
            },

            {
                'name':'frps',
                'hosta':'http://192.168.17.91:7500',
                'hostb':'http://frp.yjyn.top:7500',
                'user':'admin',
                'passwd':'pw80235956',
                'describe':'frp 内网穿透控制面板',
            },

            {
                'name':'proxy',
                'hosta':'http://192.168.17.91:3128',
                'hostb':'http://yjyn.top:3128',
                'user':None,
                'passwd':None,
                'describe':'Apache http 正向代理。',
            },

            {
                'name':'wall_proxy',
                'hosta':'http://192.168.17.91:3129',
                'hostb':'http://yjyn.top:3129',
                'user':None,
                'passwd':None,
                'describe':'Apache http 正向代理,可以连接国际互联网;翻墙梯子。',
            },

            {
                'name':'ych_vmware',
                'hosta':'https://192.168.16.99:443',
                'hostb':'https://yjyn.top:3129',
                'user':'root',
                'passwd':'pw_80235956',
                'describe':'ych vmware esxi 控制台',
            },

            {
                'name':'demo_vmware',
                'hosta':'https://192.168.16.190:443',
                'hostb':'http://yjyn.top:3129',
                'user':'root',
                'passwd':'eset1234.',
                'describe':'demo vmware esxi 控制台',
            },

            {
                'name':'eset ep',
                'hosta':'https://192.168.16.192:443/era',
                'hostb':'https://yjyn.top:1443/era',
                'user':'administrator',
                'passwd':'eset1234.',
                'describe':'eset 杀毒软件控制台',
            },

            {
                'name':'eset eei',
                'hosta':'http://192.168.16.192:8443',
                'hostb':'http://yjyn.top:7515',
                'user':'administrator',
                'passwd':'eset1234.',
                'describe':'eset edr 控制台',
            },

            {
                'name':'360eep all in one',
                'hosta':'https://192.168.16.194:9088',
                'hostb':'http://yjyn.top:7515',
                'user':'admin',
                'passwd':'360Epp1234.',
                'describe':'eset edr 控制台',
            },

        ]
