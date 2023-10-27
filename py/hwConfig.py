#pip install telnetlib3

from telnetlib import Telnet as telnet


class TelnetTools():
    def __init__(self,host,user,passwd,timeout=5):
        self.host=host
        self.user=user
        self.passwd=passwd
        self.timeout=timeout
        self.obj=None
        self.port=23
    def __openTelnet(self):
        if not self.obj:
            if not self.host:
                print('未配置主机')
                return 1
            if not self.passwd:
                print('未配置密码')
                return 1
            try:
                self.obj = telnet(host=self.host,port=self.port)
                self.obj.read_until(b'Password',timeout=self.timeout)
                self.obj.write(self.passwd.encode("ascii")+b"\n")
                self.obj.read_until(b'>',timeout=self.timeout).decode("ascii")
            except:
                 print("modify failed")
        else:
            self.obj.write("return".encode("ascii") + b"\n") 
        return self.obj

    def setPasswd(self,passwd):
        if self.__openTelnet():
            print(self.obj)
            try:
                self.obj.write("system-view".encode("ascii") + b"\n")   
                self.obj.read_until(b"]",timeout=self.timeout).decode("ascii")  
                self.obj.write("user-int vty 0 4".encode("ascii") + b"\n") 
                self.obj.read_until(b"]",timeout=self.timeout).decode("ascii") 
                self.obj.write("set authentication password cipher {0}".format(passwd).encode("ascii") + b"\n")
                s = self.obj.read_until(b"]",timeout=self.timeout).decode("ascii")
                print("modify ok")
            except:
                print("modify failed")
        else:
            print('open telnet failed')
        return 1
    
    def close(self):
        return self.obj.close()
    
if __name__ == '__main__':
    hostList=[
        {
            'name':'huawei',
            'host':'30.1.1.1',
            'user':None,
            'passwd':'test',
        }
        ]
    
    for l in hostList:
        print('name:{0}, host:{1},user:{2},passwd:{3}'.format(l['name'],l['host'],l['user'],l['passwd']))
        t = TelnetTools(host=l['host'],user=l['user'],passwd=l['passwd'])
        print(t)
        t.setPasswd('123456')
        t.close