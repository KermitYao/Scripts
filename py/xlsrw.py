import xlrd,xlwt,os

class CardInfo():
    def __init__(self,fileName):
        if not os.path.isfile(fileName):
            return None
        self.fileName=fileName
        self.cardList=[]
        self.xlsPointer=xlrd.open_workbook(fileName)
        self.xlsTable = self.xlsPointer.sheets()[0]
        self.xlsXCount = self.xlsTable.nrows
        self.xlsYCount = self.xlsTable.ncols
        for n in range(self.xlsXCount):
            self.cardList.append(self.xlsTable.cell_value(n,0))
        
    def getInfo(self,cardNo):
        if not cardNo in self.cardList:
            return None
        self.cardInfo=[]
        for n in range(self.xlsYCount):
            self.cardInfo.append(self.xlsTable.cell_value(self.cardList.index(cardNo),n))
        if len(self.cardInfo) > 0:
            return self.cardInfo
        else:
            return None

class CustomerInfo():
    def __init__(self,fileName):
        if not os.path.isfile(fileName):
            return None
        self.fileName=fileName
        self.cardList=[]
        self.xlsPointer=xlrd.open_workbook(fileName)
        self.xlsTable = self.xlsPointer.sheets()[0]
        self.xlsXCount = self.xlsTable.nrows
        self.xlsYCount = self.xlsTable.ncols
        for n in range(self.xlsXCount):
            self.cardList.append(self.xlsTable.cell_value(n,4))
    def getList(self):
        if len(self.cardList) > 0:
            return self.cardList
        else:
            return None

    def getInfo(self,cardNo):
        if not cardNo in self.cardList:
            return None
        self.cardInfo=[]
        for n in range(self.xlsYCount):
            self.cardInfo.append(self.xlsTable.cell_value(self.cardList.index(cardNo),n))
        if len(self.cardInfo) > 0:
            return self.cardInfo
        else:
            return None

fileNameC = r'C:\Users\Administrator\Desktop\customer.xls'
fileNameD = r'C:\Users\Administrator\Desktop\card.xls'
fileNameW = r'C:\Users\Administrator\Desktop\W.xls'

customer = CustomerInfo(fileNameC)
card = CardInfo(fileNameD)
writeInfo=xlwt.Workbook()
sheet=writeInfo.add_sheet('完整的客户信息表')
customerList = customer.getList()
x,y=0,0
try:
    for cards in customerList:
        cardInfo=card.getInfo(cards)
        customerInfo=customer.getInfo(cards)
        if cardInfo!=None and customerInfo!=None:
            infoList=cardInfo+customerInfo
            y=0
            for var in infoList:
                sheet.write(x,y,var)
                y+=1
            x+=1
except Exception as exeption:
    print('Error:%s' % exeption)

writeInfo.save(fileNameW)


input('按回车进行下一步操作...')
