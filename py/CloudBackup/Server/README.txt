'''
此为云备份客户端目录,整体文件详情如下:
'''
    B-CloudS.conf -- 配置文件,控制程序需要备份的文件,和一些预设信息；程序功能尽在此文件配置。
    B-CloudS.log -- 日志文件,记录程序行为信息。
    B-CloudS.exe -- 主程序,双击启动,开启监听。
    README.txt -- 自述文件。
    userInfo.data -- 用户配置，必须现在此文件预设用户信息，客户端方可访问；可单独阻断某个用户的访问,状态改为 False 即可。
    setup.bat -- 自动配置程序开机启动，和方便实现部分功能;可认为是安装程序。
使用前请先阅读此文件,然后配置 B-CloudC.conf 预设值。
用 setup.bat 安装程序和选择程序功能。
程序源码访问:https://github.com/ngrain/ngcode/tree/master/CloudBackup
