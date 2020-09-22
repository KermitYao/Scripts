#-*-coding:utf-8-*-
import os,sys,time
import pymssql,pymysql
import tkinter as tk
import tkinter.messagebox as messagebox
import decimal

#state{1:连接状态为false,
#      11:事物提交发生异常,
#      12:连接数据库发生异常}
#      13:为查询到数据


#debug输出
def errorLog(func):
    def wrapper(*args, **kwargs):
        msg='\t%s---FUNC:%s,ARGS:%s,KWARGS:%s' % (formatTime(time.time(),1),func,args,kwargs)
        if DEBUGS:
            dname='debug_'+str(formatTime(time.time(),2))+'.log'
            with open(dname,'a') as f:
                f.write(msg+'\n')
        else:
            pass
            #print(msg)
        return func(*args, **kwargs)
    return wrapper
#sys._getframe().f_code.co_name

#格式化时间
def formatTime(times,type=1):
    if times != None:
        m=time.localtime(float(times))
        if type == 1:
            m='{}-{}-{} {}:{}:{}'.format(m.tm_year,m.tm_mon,m.tm_mday,m.tm_hour,m.tm_min,m.tm_sec)
        elif type == 2:
            m='{}{}{}{}{}{}'.format(m.tm_year,m.tm_mon,m.tm_mday,m.tm_hour,m.tm_min,m.tm_sec)
        return m
    return None

class ConnectDB():
    def __init__(self, host='127.0.0.1', port=1433, user='sa', pwd='betterlife', db='LaundryPlus', type=0):
        self.host=host
        self.user=user
        self.pwd=pwd
        self.db=db
        self.port=port
        self.type=type
        self.state=False

    #连接数据库
    @errorLog
    def getConnect(self):
        try:
            if self.type == 0:
                self.db_conn=pymssql.connect(host=self.host,port=self.port, user=self.user, password=self.pwd, database=self.db, charset='utf8')
            elif self.type == 1:
                self.db_conn=pymysql.connect(host=self.host,port=self.port, user=self.user, password=self.pwd, database=self.db, charset='utf8')
            self.cur=self.db_conn.cursor()
            if not self.cur:
                self.state=False
                return False
            else:
                self.state=True
                return True
        except Exception as exp:
            print(exp)
            return 12
    @errorLog
    #提交SQL语句
    def execSQL(self,sql):
        if self.state == True:
            try:
                self.cur.execute(sql)
                #self.db_conn.commit()
                return self.cur
            except Exception as exp:
                #self.cur.rollback()
                print(exp)
                return 11
        else:
            return 1
    @errorLog
    #关闭数据库连接
    def close(self,):
        if self.db_conn:
            self.db_conn.close()
            self.state=False
        return True




if __name__=='__main__':
    global DEBUGS 
    DEBUGS=False
    sql='select username,password from tb_user'
    LInfo=LaundryInfo()

    db=ConnectDB(host='192.168.0.3')
    db.type=1
    db.port=3306
    db.db='laundryplus'
    db.user='ngrain'
    db.pwd='yk@555698'
    dbStat=db.getConnect()
    print(dbStat)
    if dbStat==True:
        print('数据库连接成功!')
        LInfo.dbExec=db.execSQL
    elif dbStat==False:
        print('数据库连接失败!')
    elif dbStat==12:
        print('数据库连接异常!')
        
    qc=LInfo.queryCustomer('18601785806')
    print('客户信息查询:%s' % qc)

    qcloth=LInfo.queryCloth('18122500010004')
    print('衣物信息查询:%s' % qcloth)
    db.close()



    #cur=db.execSQL(sql)

