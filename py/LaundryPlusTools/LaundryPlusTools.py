#-*- coding: utf-8-*-
import tkinter as tk
import tkinter.messagebox as messagebox
import pyodbc
import decimal
#---------函数---------


class DatabaseHandle():
    def __init__(self):
        connectState = False

    #连接数据库
    def connectDatabase(self,serverAddr,databaseName,uid,pwd):
        try:
            self.cnxn = pyodbc.connect('DRIVER={};SERVER={};DATABASE={};UID={};PWD={}'.format('SQL Server',serverAddr,databaseName,uid,pwd))
            self.cursor=self.cnxn.cursor()
            connectState=True
            return 0
        except Exception  as exeption:
            connectState=False
            return 1
    #断开数据库
    def closeDatabase(self):
        self.cnxn.close()
        connectState=False
        return 0

        #查询流水信息	
    def query_clothinfo(self,billno,sdtout):
	    #查询流水
        self.cursor.execute("select id,customerid,price,owefee,createdate,orderstate from tb_clothinfo where billno='{}'".format(billno))
        bill_cursor=self.cursor.fetchall()
        if len(bill_cursor)>0:
            list_payrecord=[]
            list_statedetail=[]
            list_clothattach=[]
            list_clothdetail=[]
            list_clothinfo=[]
            self.dict_query_cloth={'_payrecord':list_payrecord,'_statedetail':list_statedetail,'_clothattach':list_clothattach,'_clothdetail':list_clothdetail,'_clothinfo':list_clothinfo}
        else:
            self.dict_query_cloth={}
            return self.dict_query_cloth


        for bill in bill_cursor:
            #查询支付信息
            self.cursor.execute("select id from tb_payrecord where clothinfoid={}".format(bill.id))
            payrecord_cursor=self.cursor.fetchall()
            for payrecord in payrecord_cursor:
                list_payrecord.append(payrecord.id)

            #查询客户信息
            self.cursor.execute("select id,name,mobile1 from tb_customer where id={}".format(bill.customerid))
            customer_cursor=self.cursor.fetchone() 
            list_clothinfo.append(bill.id)
            if sdtout=='open': showInfoText.insert('end','ID:{}\n姓名:{}\n电话:{}\n金额:{}\n未付:{}\n日期:{}\n状态:{}\n'.format(bill.id, customer_cursor.name, customer_cursor.mobile1,bill.price, bill.owefee,str(bill.createdate)[:19], bill.orderstate))
		
            #查询衣物
            self.cursor.execute("select id,barcode,clothname,price from tb_clothdetail where clothinfoid={}".format(bill.id))
            detail_cursor=self.cursor.fetchall()
            for detail in detail_cursor:
                list_clothdetail.append(detail.id)
                if sdtout=='open': showInfoText.insert('end','衣物名称:{},条码号:{},金额:{}\n'.format(detail.clothname,detail.barcode,detail.price))

                #查询衣物状态
                self.cursor.execute("select id from tb_statedetail where clothdetailid={}".format(detail.id))
                stateD_cursor=self.cursor.fetchall()
                for stateD in stateD_cursor:
                    list_statedetail.append(stateD.id)

                #查询附件			
                self.cursor.execute("select id,name,barcode,clothstate from tb_clothattach where clothdetailid={}".format(detail.id))
                attach_cursor=self.cursor.fetchall()
                for attach in attach_cursor:
                    list_clothattach.append(attach.id)
                    if sdtout=='open': showInfoText.insert('end','\tID:{},附件名称:{},条码号:{},附件状态:{}\n'.format(attach.id,attach.name,attach.barcode,attach.clothstate))

                    #查询附件状态
                    self.cursor.execute("select id from tb_statedetail where clothattachid={}".format(attach.id))
                    stateA_cursor=self.cursor.fetchall()
                    for stateA in stateA_cursor:
                        list_statedetail.append(stateA.id)
        return self.dict_query_cloth

    #查询客户信息
    def query_customer(self,mobile,sdtout):
	    #查询客户信息
	    self.cursor.execute("select id,name,sex,registershop from tb_customer where mobile1='{}'".format(mobile))
	    mobile_cursor=self.cursor.fetchall()
	    if len(mobile_cursor)>0:
		    list_payrecordc=[]
		    list_recharge=[]
		    list_card=[]
		    list_clothinfoc=[]
		    list_customer=[]
		    list_salecard=[]
		    list_cancelcard=[]
		    self.dict_query_customer={'_payrecordc':list_payrecordc,'_recharge':list_recharge,'_card':list_card,'_clothinfoc':list_clothinfoc,'_customer':list_customer,'_salecard':list_salecard,'_cancelcard':list_cancelcard}
	    else:
		    self.dict_query_customer={}
		    return self.dict_query_customer
	    for customer in mobile_cursor:
		    list_customer.append(customer.id)
		    if sdtout=='open': showInfoText.insert('end','ID:{}\n姓名:{}\n性别:{}\n所属门店:{}\n'.format(customer.id, customer.name, customer.sex,customer.registershop))
		    #查询会员卡号
		    self.cursor.execute("select id,cardno,rebate,remain from tb_card where customerid='{}'".format(customer.id))
		    card_cursor=self.cursor.fetchall()
		    for cardno in card_cursor:
			    list_card.append(cardno.id)
			    if sdtout=='open': showInfoText.insert('end','卡号:{},折扣:{},余额:{}\n'.format(cardno.cardno,str(cardno.rebate)[:4],cardno.remain))
			    #查询充值信息
			    self.cursor.execute("select id from tb_recharge where cardid='{}'".format(cardno.id))
			    recharge_cursor=self.cursor.fetchall()
			    for recharge in recharge_cursor:
			    	list_recharge.append(recharge.id)
			    #查询售卡信息
			    self.cursor.execute("select id from tb_salecard where cardid='{}'".format(cardno.id))
			    salecard_cursor=self.cursor.fetchall()
			    for salecard in salecard_cursor:
				    list_salecard.append(salecard.id)
			    #查询退卡信息
			    self.cursor.execute("select id from tb_cancelcard where cardid='{}'".format(cardno.id))
			    cancelcard_cursor=self.cursor.fetchall()
			    for cancelcard in cancelcard_cursor:
				    list_cancelcard.append(cancelcard.id)
		    #查询衣物流水
		    self.cursor.execute("select id,billno,price,owefee,createdate,orderstate from tb_clothinfo where customerid='{}'".format(customer.id))
		    clothinfo_cursor=self.cursor.fetchall()
		    for clothinfo in clothinfo_cursor:
			    list_clothinfoc.append(clothinfo.billno)
			    if sdtout=='open': showInfoText.insert('end','流水号:{},金额:{},未付:{},衣物状态:{}\n'.format(clothinfo.billno,clothinfo.price,clothinfo.owefee,clothinfo.orderstate))	
		    #查询支付信息
		    self.cursor.execute("select id from tb_payrecord where customerid={}".format(customer.id))
		    payrecord_cursor=self.cursor.fetchall()
		    for payrecord in payrecord_cursor:
		    	list_payrecordc.append(payrecord.id)
				
	    return self.dict_query_customer

    #删除流水信息	
    def delete_clothinfo(self,clothinfo_dict,sdtout):
	    try:
		    for h in clothinfo_dict['_payrecord']:
			    if sdtout=='open': print(' 删除支付记录,ID:{}'.format(h))
			    self.cursor.execute("delete from tb_payrecord where id='{}'".format(h))
			    self.cnxn.commit()
		    for i in clothinfo_dict['_statedetail']:
			    if sdtout=='open': print(' 删除状态记录,ID:{}'.format(i))
			    self.cursor.execute("delete from tb_statedetail where id='{}'".format(i))
			    self.cnxn.commit()
		    for j in clothinfo_dict['_clothattach']:
			    if sdtout=='open': print(' 删除附件记录,ID:{}'.format(j))
			    sef.cursor.execute("delete from tb_clothattach where id='{}'".format(j))
			    self.cnxn.commit()
		    for k in clothinfo_dict['_clothdetail']:
			    if sdtout=='open': print(' 删除衣物详情记录,ID:{}'.format(k))
			    self.cursor.execute("delete from tb_clothdetail where id='{}'".format(k))
			    self.cnxn.commit()
		    for l in clothinfo_dict['_clothinfo']:
			    if sdtout=='open': print(' 删除收衣记录,ID:{}'.format(l))	
			    self.cursor.execute("delete from tb_clothinfo where id='{}'".format(l))
			    self.cnxn.commit()
		    return 0
	    except Exception as error:
		    return 1

    #删除客户信息
    def delete_customer(self,customer_dict,sdtout):
	    try:
		    for i in customer_dict['_payrecordc']:
			    if sdtout=='open': print(' 删除支付详情,ID:{}'.format(i))
			    self.cursor.execute("delete from tb_payrecord where id='{}'".format(i))
			    self.cnxn.commit()
		    for i in customer_dict['_recharge']:
			    if sdtout=='open': print(' 删除充值记录,ID:{}'.format(i))
			    self.cursor.execute("delete from tb_recharge where id='{}'".format(i))
			    self.cnxn.commit()
			
		    for i in customer_dict['_salecard']:
			    if sdtout=='open': print(' 删除售卡信息,ID:{}'.format(i))	
			    self.cursor.execute("delete from tb_salecard where id='{}'".format(i))
			    self.cnxn.commit()
			
		    for i in customer_dict['_cancelcard']:
			    if sdtout=='open': print(' 删除退卡信息,ID:{}'.format(i))	
			    self.cursor.execute("delete from tb_cancelcard where id='{}'".format(i))
			    self.cnxn.commit()
			
		    for i in customer_dict['_clothinfoc']:
			    if sdtout=='open': print(' \t删除收衣记录,ID:{}'.format(i))
			    dict_cloth=self.query_clothinfo(i,'close')
			    del_cloth=self.delete_clothinfo(dict_cloth,'clothinfo')			
			
		    for i in customer_dict['_card']:
			    if sdtout=='open': print(' \t\t删除会员卡,ID:{}'.format(i))
			    self.cursor.execute("delete from tb_card where id='{}'".format(i))
			    self.cnxn.commit()

		    for i in customer_dict['_customer']:
			    if sdtout=='open': print(' \t\t\t删除客户信息,ID:{}'.format(i))	
			    self.cursor.execute("delete from tb_customer where id='{}'".format(i))
			    self.cnxn.commit()
			
		    return 0
	    except:
		    return 1
#连接
def login():
    if cdb.connectDatabase(inputBoxAddrVar.get(),inputBoxNameVar.get(),inputBoxAccVar.get(),inputBoxPwdVar.get()) != 0:
        messagebox.showerror(title='错误',message='数据库无法连接,请检查!')
    else:
        loginButton.config(text='断开')
        loginButton.config(command=logout)
        queryFlowButton.config(state=tk.NORMAL)
        queryMobileButton.config(state=tk.NORMAL)

#断开连接
def logout():
    if cdb.closeDatabase()==0:
        loginButton.config(text='连接')
        loginButton.config(command=login)
        queryFlowButton.config(state=tk.DISABLED)
        delFlowButton.config(state=tk.DISABLED)
        queryMobileButton.config(state=tk.DISABLED)
        delMobileButton.config(state=tk.DISABLED)
        connectState=False

#查询流水信息button
def selectFlow():
    showInfoText.delete(1.0,tk.END)
    dictQueryCloth=cdb.query_clothinfo(inputBoxFlowVar.get(),'open')
    if dictQueryCloth != {}:
        delFlowButton.config(state=tk.NORMAL)
    else:
        delFlowButton.config(state=tk.DISABLED)
        messagebox.showerror(title='错误',message='未能查询到该流水号信息!')

#删除流水信息button
def delFlow():
    if cdb.delete_clothinfo(cdb.dict_query_cloth,open) == 0:
        delFlowButton.config(state=tk.DISABLED)
        messagebox.showinfo(title='提示',message='流水信息已删除!')
    else:
        messagebox.showerror(title='错误',message='未能删除该流水号信息!')

#查询客户信息button
def selectMobile():
    showInfoText.delete(1.0,tk.END)
    dictQueryCloth=cdb.query_customer(inputBoxMobile.get(),'open')
    if dictQueryCloth != {}:
        delMobileButton.config(state=tk.NORMAL)
    else:
        delFlowButton.config(state=tk.DISABLED)
        messagebox.showerror(title='错误',message='未能查询到该手机号信息!')

#删除客户信息button
def delMobile():
    if cdb.delete_customer(cdb.dict_query_customer,open) == 0:
        delMobileButton.config(state=tk.DISABLED)
        messagebox.showinfo(title='提示',message='客户信息已删除!')
    else:
        messagebox.showerror(title='错误',message='未能删除该手机号信息!')

#获取文件 完整目录,文件名,后缀名
def getPathInfo(filepath):
    logging.info('位置:[{}] - 信息:[{}]'.format(sys._getframe().f_code.co_name,'GetPathInfo'))
    pathname,filename=os.path.split(filepath)
    filename,filext=os.path.splitext(filename)
    return filepath,filename,filext

#日志
'''
def log()
    filepath,filename,fileext=getPathInfo(os.path.abspath(__file__))
    logpath=os.path.join(filepath,filename+'.log')
    LOG_FORMAT="%(asctime)s - %(levelname)s - %(message)s"
    logging.basicConfig(filename=logpath,level=logging.DEBUG,format=LOG_FORMAT)
    logging.debug('位置:[{}] - 信息:[{}]'.format(sys._getframe().f_code.co_name,'开始记录日志.'))
'''


#---------函数---------



cdb = DatabaseHandle()
wm = tk.Tk()
wm.title('LaundryPlusTools v1.3')
wm.geometry('512x600')

#添加输入提示标签
labelBarTitle = tk.Label(wm,text='数据库连接')
labelBarTitle.grid(column=2)

labelBarAddr = tk.Label(wm,text='数据库地址: ')
labelBarAddr.grid(row=1)
inputBoxAddrVar = tk.StringVar()
inputBoxAddrVar.set('127.0.0.1')
inputBoxAddr = tk.Entry(wm,textvariable=inputBoxAddrVar)
inputBoxAddr.grid(row=1,column=2)

labelBarName = tk.Label(wm,text='数据库库名: ')
labelBarName.grid(row=2)
inputBoxNameVar = tk.StringVar()
inputBoxNameVar.set('LaundryPlus')
inputBoxName = tk.Entry(wm,textvariable=inputBoxNameVar)
inputBoxName.grid(row=2,column=2)

labelBarAcc = tk.Label(wm,text='数据库账号: ')
labelBarAcc.grid(row=3)
inputBoxAccVar = tk.StringVar()
inputBoxAccVar.set('sa')
inputBoxAcc = tk.Entry(wm,textvariable=inputBoxAccVar)
inputBoxAcc.grid(row=3,column=2)

labelBarPwd = tk.Label(wm,text='数据库密码: ')
labelBarPwd.grid(row=4)
inputBoxPwdVar = tk.StringVar()
inputBoxPwdVar.set('betterlife')
inputBoxPwd = tk.Entry(wm,textvariable=inputBoxPwdVar,show='*')
inputBoxPwd.grid(row=4,column=2)

labelLineDatabase = tk.Label(wm,text='----------------------')
labelLineDatabase.grid(row=5)

labelBarFlow = tk.Label(wm,text='衣物流水号:')
labelBarFlow.grid(row=6)
inputBoxFlowVar = tk.StringVar()
inputBoxFlowVar.set('17070200010206')
inputBoxFlow = tk.Entry(wm,textvariable=inputBoxFlowVar)
inputBoxFlow.grid(row=6,column=2)

queryFlowButton = tk.Button(wm,text='查询',width=7,height=1,command=selectFlow,state=tk.DISABLED)
queryFlowButton.grid(row=6,column=3,padx=10)
delFlowButton = tk.Button(wm,text='删除',width=7,height=1,command=delFlow,state=tk.DISABLED)
delFlowButton.grid(row=6,column=4,padx=10)

labelLineFlow = tk.Label(wm,text='----------------------')
labelLineFlow.grid(row=7)

labelBarMobile = tk.Label(wm,text='客户手机号:')
labelBarMobile.grid(row=8)
inputBoxMobileVar = tk.StringVar()
inputBoxMobileVar.set('15618095166')
inputBoxMobile = tk.Entry(wm,textvariable=inputBoxMobileVar)
inputBoxMobile.grid(row=8,column=2)

queryMobileButton = tk.Button(wm,text='查询',width=7,height=1,command=selectMobile,state=tk.DISABLED)
queryMobileButton.grid(row=8,column=3,padx=10)
delMobileButton = tk.Button(wm,text='删除',width=7,height=1,command=delMobile,state=tk.DISABLED)
delMobileButton.grid(row=8,column=4,padx=10)
#添加连接按钮
loginButton = tk.Button(wm,text='连接',width=7,height=1,command=login)
loginButton.grid(row=2,column=3,padx=10)

#添加信息展示框
showInfoText = tk.Text(wm,width=71,height=18)
showInfoText.place(x=5,y=355, anchor='nw')

imageCanvas = tk.Canvas(wm,height=100,width=100)
imageCanvas.place(x=390,y=15,anchor='nw')
imageCanvas.create_line(1,1,99,99)
imageCanvas.create_line(99,1,1,99)
#imageFile = tk.PhotoImage(file='jzn.gif')
#image = imageCanvas.create_image(1,1,anchor='nw',image=imageFile)

wm.mainloop()
