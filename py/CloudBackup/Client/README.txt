'''
此为云备份客户端目录,整体文件详情如下:
'''
│  B-CloudC.conf -- 配置文件,控制程序需要备份的文件,和一些预设信息；程序功能尽在此文件配置。
│  B-CloudC.exe -- 主程序。
│  README.txt -- 自述文件。
│  setup.bat -- 自动配置程序开机启动，和方便实现部分功能;可认为是安装程序。
│
├─mssqlbackup -- 如果启动 SQL server 数据库备份，则此目录为存放备份的文件。
└─TmpFile -- 压缩和下载的文件临时目录。

使用前请先阅读此文件,然后配置 B-CloudC.conf 预设值。
用 setup.bat 安装程序和选择程序功能。

程序源码访问:https://github.com/ngrain/ngcode/tree/master/CloudBackup