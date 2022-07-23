#-*-coding:utf-8-*-
#
# Use UDP 514 port on local.
# The code can make a syslog server or syslog client.
#

from socket import socket

import socket
import time

class SyslogServer():
    def __init__(self):
        self.syslogHost = '0.0.0.0'
        self.syslogPort = 514
        self.syslogAddress = (self.syslogHost, self.syslogPort)
    
    def run(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.bind(self.syslogAddress)
        print("Bind UDP on %s ..." % self.syslogPort)
        while True:
            data, address = s.recvfrom(1024)
            print(data.decode())


class SyslogClient():
    def __init__(self):
        '''
        Code    Facility    
        0   kernel messages
        1   user-level messages
        2   mail system
        3   system daemons
        4   security/authorization messages
        5   messages generated internally by syslogd
        6   line printer subsystem
        7   network news subsystem
        8   UUCP subsystem
        9   clock daemon
        10  security/authorization messages
        11  FTP daemon
        12  NTP subsystem
        13  log audit
        14  log alert
        15  clock daemon
        16-23   local0 - local7
        
        '''

        self.facility = 16
        '''
            Severity
        Code    Severity
        0   Emergency
        1   Alert
        2   Critical
        3   Error
        4   Warning
        5   Notice
        6   Informational
        7   Debug
        
        '''
        self.severity = 1
        #RFC5424
        self.version = 1
        self.timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
        self.hostname = socket.gethostname()
        #APP名称
        self.appName = 'syslogTest'
        #一般是进程ID
        self.procid = 'python'
        #消息ID， 如防火墙 流量的进出
        self.msgid = 'ID55'

        self.structuredData = '-'
        self.msg = "The log from python3 send..."
        self.syslogHost = '192.168.16.88'
        self.syslogPort = 514

    def connectSock(self):
        self.syslogAddress = (self.syslogHost, self.syslogPort)
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.sendto(bytes(self.syslogContent, encoding="utf-8"), self.syslogAddress)
        s.close()

    def send(self):
        self.timestamp = time.strftime("%Y-%m-%dT%H:%M:%S")
        '''
            PRI -- 135
            VERSION -- 1
            TIMESTAMP -- 2022-07-18T15:48:33
            HOSTANME -- 192.168.16.43
            APP-NAME -- syslogTest
            PROCID -- 2231
            MSGGID -- ID47
            STRUCTURED-DATA -- [exampleSDID@22345 i="1" j="kk"]
            MESSAGE -- An application event log entry
        '''
        self.syslogContent = "<{0}>{1} {2} {3} {4} {5} {6} {7} {8}".format(self.facility * 8 + self.severity, self.version, self.timestamp, self.hostname, self.appName, self.procid, self.msgid, self.structuredData, self.msg)
        print(self.syslogContent)
        self.connectSock()


if __name__ == '__main__':
    syslog = SyslogServer()
    syslog.run()

    '''
    syslog = SyslogClient()
    syslog.syslogHost = '192.168.16.43'
    syslog.send()
    '''