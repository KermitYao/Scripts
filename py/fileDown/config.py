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
    #User info
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
    

