import paramiko, os,time


class SSHTools():
    def __init__(self,hostname=None, port=22, username=None, password=None, timeout=10,keyfile=None):
        self.hostname=hostname
        self.port=port
        self.username=username
        self.password=password
        self.keyfile=keyfile
        self.timeout=timeout
        self.flag = False

    def connect(self):
        if not self.flag:
            if self.hostname == None or self.port == None or self.username == None or (self.password == None and self.keyfile == None):
                raise Exception("用于连接的参数不完整!")
                return False
            #实例化SSHClient
            self.sshClient = paramiko.SSHClient()
            #自动添加策略到本地,不设置会出现提示添加策略
            self.sshClient.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            try:
                #连接到服务器
                if self.keyfile != None and os.path.isfile(self.keyfile):
                    self.sshClient.connect(hostname=self.hostname, port=self.port, username=self.username, key_filename=self.keyfile, timeout=self.timeout)
                else:
                    self.sshClient.connect(hostname=self.hostname, port=self.port, username=self.username, password=self.password, timeout=self.timeout)
                #打开一个sftp隧道
                self.sftp = self.sshClient.open_sftp()
                #打开一个shell
                self.invoke = self.sshClient.invoke_shell()
                #当使用recv 读取shell内容是,如果内容为空,则会阻塞整个进程，可以在之前设置超时时间进行避免
                self.invoke.settimeout(5)
                #self.invoke.send(r'scree-length 0 temporary\n')
                return True
            except Exception as e:
                raise Exception("主机连接失败!",e)
                return False
        else:
            return True
    
    def transport(self):
        #常见公钥文件对象
        keyFile = paramiko.RSAKey.from_private_key_file(r'./ssh/id_rsa')
        #创建隧道
        tran = paramiko.Transport(('127.0.0.1',22))
        #使用公钥文件连接到隧道
        tran.connect(username='root', pkey=keyFile)
        #使用密码连接到隧道
        #tran.connect(username='root', password='password')
        #从transport中创建sftp对象
        sftp = paramiko.SFTPClient.from_transport(tran)
        #上传文件
        #sftp.put(remote, local)

    def exec(self,cmd):
        self.connect()
        #运行命令
        stdin, stdout, stderr = self.sshClient.exec_command(cmd)
        return stdout.read().decode('utf-8'),stderr.read().decode('utf-8')

    #ssh.shell('ls \n ip a s \n pwd \n cat /etc/os-release \n')
    def shell(self,cmd):
        self.connect()
        n = self.invoke.send(cmd)
        time.sleep(0.5)
        return self.invoke.recv(9999).decode()

    def ls(self,dir):
        self.connect()
        return self.sftp.listdir(dir)
    
    def isFile(self,path):
        self.connect()
        if self.exec('test -f %s&&printf True' % path)[0] == "True":
            return True
        return False

    def isDir(self,path):
        self.connect()
        if self.exec('test -d %s&&printf True' % path)[0] == "True":
            return True
        return False

    def mkdir(self,path):
        self.connect()
        if self.exec('mkdir -p %s&&printf True' % path)[0] == "True":
            return True
        return False

    def put(self,local,remote):
        self.connect()
        return self.sftp.put(local,remote)
    
    def get(self,remote,local):
        self.connect()
        return self.sftp.get(remote,local)

    def close(self):
        self.connect()
        return self.sshClient.close()
        
def main(type='s'):

    ssh = SSHTools(hostname='192.168.30.42', port=22, username='root', password='360Epp1234.')
    for line in ssh.exec('ip a s'):
        print(line)
    
    print(ssh.shell('ls \n ip a s \n pwd \n cat /etc/os-release \n'))






if  __name__ == '__main__':
    main()



