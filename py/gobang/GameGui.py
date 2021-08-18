from tkinter.constants import DISABLED, FLAT, GROOVE, LEFT, NORMAL, RAISED, RIGHT, SUNKEN, TOP
from Chessboard import Chessboard
import tkinter as tk
from tkinter import messagebox as msg

def beginGame():
    tg.surrenderFlag = False
    tg.startGameFlag = True
    tg.startGameObj.config(state=tk.DISABLED)
    tg.blackFirstObj.config(state=tk.DISABLED)
    tg.whiteFirstObj.config(state=tk.DISABLED)
    tg.surrenderObj.config(state=tk.NORMAL)
    tg.lastChessObj.config(state=tk.DISABLED)  

    cb.chessCount = {
    'whiteChessCount':0,
    'blackChessCount':0,
    'putChessTotal':0,
    }


    #清空棋盘
    for obj in tg.chessObj:
            tg.chessCanvas.delete(obj)
    tg.chessObj = []
    initReturn = cb.initArrChessboard()
    if tg.chessPlayer.get() == 'black':
        tg.chessPutFlag = 'white'
        #获取AI落子位置
        aiPlace=cb.aiPut('mid')[0]['chessPlance']
        mousePlace = tg.getPlace(coordinate=aiPlace, coordinatetype='mapplace')
        mapPlace = mousePlace['mapPlace']
        print('黑子落子数据: %s ' % mousePlace)
        tg.paintChess(chesscolor='black', dictcoordinatedata=mousePlace)
        print('chessboard data: %s' % cb.arrChessboard)
        tg.tipsVar.set('黑子先手,落子位置:%s, %s' % (mapPlace[1]+1, mapPlace[0]+1) )


    else:
        tg.tipsVar.set('白子先手,请落子')

def setChessPlayer():
    if tg.chessPlayer.get() == 'white':
        tg.tipsVar.set('你选择了白子先手."')
    else:
        tg.tipsVar.set('你选择了黑子先手"')

def setAiLevel():
    if tg.aiLevel.get() == 'high':
        tg.tipsVar.set('你选择了高级模式')
    elif tg.aiLevel.get() == 'mid':
        tg.tipsVar.set('你选择了中级模式"')
    else:
        tg.tipsVar.set('你选择了新手模式"')

def backLast():
    tg.lastChessboard()
    
    tg.tipsVar.set('已悔棋')

def gameOver(chesscolor='black'):
    chessColor = chesscolor
    tg.startGameFlag = False
    tg.startGameObj.config(state=tk.NORMAL)
    tg.blackFirstObj.config(state=tk.NORMAL)
    tg.whiteFirstObj.config(state=tk.NORMAL)
    tg.lastChessObj.config(state=tk.DISABLED)
    tg.surrenderObj.config(state=tk.DISABLED)
    if chessColor == 'black':
        msg.showinfo(title='结束', message='黑子获得胜利！')
    elif chessColor == 'white':
        msg.showinfo(title='结束', message='白子获得胜利！')
    elif chessColor == 'full':
        msg.showinfo(title='结束', message='棋盘已满,和棋！')

def moveMouse(event):
    mousePlace = tg.getPlace((event.x, event.y))['mapPlace']
    tg.placeTips.set('位置:\n    行:%s\n    列:%s' % (mousePlace[1]+1, mousePlace[0]+1))

def mousePutChessr(event):
    #边界检测
    if cb.chessCount['putChessTotal'] >= cb.rowNum*cb.colNum:
        gameOver('full')
        return True
    if tg.startGameFlag:
        if event.x < tg.chessboardLineSpace - tg.chessboardLineSpace/2 or event.x > tg.chessboardLineSpace * 15 + tg.chessboardLineSpace/2 or event.y < tg.chessboardLineSpace - tg.chessboardLineSpace/2 or event.y > tg.chessboardLineSpace * 15 + tg.chessboardLineSpace/2:
            tg.tipsVar.set('此处无法落子')
        else:
            mousePlace = tg.getPlace((event.x, event.y))
            mapPlace = mousePlace['mapPlace']
            turnPlace = (mapPlace[1], mapPlace[0])
            if cb.arrChessboard[turnPlace[0]][turnPlace[1]]  == cb.nullChess:
                tg.paintChess(chesscolor='white', dictcoordinatedata=mousePlace)
                print('白子落子数据: %s, %s ' % (turnPlace))
                print('chessboard data: %s' % cb.arrChessboard)
                #扫描棋盘进行评估,当分数大于 10w表示出现五子连珠
                dictChessLine = cb.scanChessboard(turnPlace)
                userEvaluateScore = cb.evaluateChess('white', dictChessLine)
                print('\n当前棋盘:')
                for x in cb.arrChessboard:
                    print(x, '\n')
                print('九子连线:',dictChessLine)
                print('白子评分:%s' % userEvaluateScore)


                if userEvaluateScore['totalScore'] >= 100000:
                    userFiveChess = cb.getFiveChess('white', userEvaluateScore)
                    print('白子五连位置:%s' % (userFiveChess))
                    tg.tipsVar.set('白子获得胜利')
                    cb.winChess = userFiveChess
                    tg.painRedLine(userFiveChess)
                    gameOver('white')
                    return True
                else:
                    aiPlace=cb.aiPut((tg.aiLevel.get()))[0]['chessPlance']
                    turnPlace = (aiPlace[1], aiPlace[0])
                    mousePlace = tg.getPlace(coordinate=turnPlace, coordinatetype='mapplace')
                    tg.paintChess(chesscolor='black', dictcoordinatedata=mousePlace)
                    tg.tipsVar.set('黑子己下,落子位置:%s, %s' % (turnPlace[0]+1, turnPlace[1]+1) )
                    dictChessLine = cb.scanChessboard(aiPlace)
                    aiEvaluateScore = cb.evaluateChess('black', dictChessLine)
                    print('\n当前棋盘:')
                    for x in cb.arrChessboard:
                        print(x, '\n')

                    print('aiPlace:',aiPlace)
                    print('九子连线:',dictChessLine)
                    print('黑子评分:%s' %  aiEvaluateScore)
                    if aiEvaluateScore['totalScore'] >= 100000:
                        aiFiveChess = cb.getFiveChess('black', aiEvaluateScore)
                        print('黑子五连位置:%s' % (aiFiveChess))
                        tg.tipsVar.set('黑子获得胜利')
                        cb.winChess = aiFiveChess
                        tg.painRedLine(aiFiveChess)
                        gameOver('black')
                        return True
                tg.lastChessObj.config(state=tk.NORMAL)
            else:
                tg.tipsVar.set('此处已落子')
    else:
        tg.tipsVar.set('点击"开局"按钮以开始游戏')

class TkinterGui():
    def __init__(self,chessboardwidth=650, chessboardline=15):
        self.chessboardWidth = chessboardwidth
        self.chessboardLine = chessboardline
        self.chessboardLineSpace = self.chessboardWidth/(self.chessboardLine+1)
        #棋子半径
        self.chessDiam = self.chessboardLineSpace/2 - self.chessboardLineSpace/2/6
        self.title = 'Gobang'
        self.imagePath = 'image/background.png'

        self.chessObj = []

        #--------标志-------
        #是否投降
        self.surrenderFlag = False
        #是否已经开局
        self.startGameFlag = False
        #落子标志
        self.chessPutFlag = 'black'

    #初始化主框架
    def initMasterFrame(self):
        self.rootFrame = tk.Tk()
        self.rootFrame.title(self.title)
        self.rootFrame.geometry('850x800')
        self.tipsVar = tk.StringVar()
        self.tipsVar.set('选择先手方,然后点击 "开局" 以开始游戏')
        self.tips = tk.Label(self.rootFrame,
            textvariable=self.tipsVar,
            bg = 'Gray',
            font=('Times', 14)
            )
        self.tips.pack(side=TOP,
            pady = 20,
            )
        
        self.rootFrame.resizable(0,0)

        return self.rootFrame

    #画出棋盘
    def paintChessboard(self):
        self.chessCanvasImageFile = tk.PhotoImage(file=self.imagePath)
        self.chessCanvas = tk.Canvas(self.rootFrame, bg='green', height=self.chessboardWidth, width=self.chessboardWidth,)
        self.chessCanvas.create_image((self.chessboardWidth/2,0),anchor='n',image=self.chessCanvasImageFile)
        rowX0,rowY0, rowX1,rowY1=self.chessboardLineSpace,self.chessboardLineSpace, self.chessboardLineSpace,self.chessboardLineSpace*self.chessboardLine
        colX0,colY0, colX1,colY1=self.chessboardLineSpace,self.chessboardLineSpace, self.chessboardLineSpace*self.chessboardLine,self.chessboardLineSpace
        setp = 0
        for x in range(15):
            self.chessCanvasLine = self.chessCanvas.create_line(rowX0+setp,rowY0, rowX1+setp,rowY1)
            self.chessCanvasLine = self.chessCanvas.create_line(colX0,colY0+setp, colX1,colY1+setp)
            setp += self.chessboardLineSpace
        self.chessCanvas.pack(side=LEFT,
            padx = 20,
            #pady = 20
            )

        #绑定鼠标事件
        self.chessCanvas.bind("<Button-1>", mousePutChessr)
        self.chessCanvas.bind("<Motion>", moveMouse)

    #生成交互框架
    def createInteractiveFrame(self):
        tk.Frame(self.rootFrame,width=20,height=650).pack(side=RIGHT)
        self.interactiveFrame = tk.Frame(self.rootFrame, width=150 , height=650, bd=1, relief=SUNKEN, highlightthickness=1)
        self.interactiveFrame.pack(side=RIGHT)

        #高度保持
        tk.Frame(self.interactiveFrame,width=1,height=648, bd=1,relief=SUNKEN, highlightthickness=1).pack(side=LEFT)

        self.chessPlayer = tk.StringVar()
        self.chessPlayer.set(self.chessPutFlag)
        self.startGameObj = tk.Button(self.interactiveFrame, text='开局',state=tk.NORMAL, font=('Times', 14), width=6 ,command=beginGame)
        self.startGameObj.pack(side=TOP,pady=20)

        self.blackFirstObj = tk.Radiobutton(self.interactiveFrame, text= '黑子先手', variable=self.chessPlayer, value='black', command=setChessPlayer)
        self.blackFirstObj.pack()
        self.whiteFirstObj = tk.Radiobutton(self.interactiveFrame, text= '白子先手', variable=self.chessPlayer, value='white', command=setChessPlayer)
        self.whiteFirstObj.pack()
        #分隔线
        tk.Frame(self.interactiveFrame,width=150,height=4, bd=1,relief=SUNKEN, highlightthickness=1).pack(pady=10)

        self.aiLevel = tk.StringVar()
        self.aiLevel.set('mid')
        tk.Label(self.interactiveFrame, text='AI 棋力水平', font=('Times', 10)).pack(pady=10)
        tk.Radiobutton(self.interactiveFrame, text= '新手娱乐', variable=self.aiLevel, value='low', command=setAiLevel).pack()
        tk.Radiobutton(self.interactiveFrame, text= '有来有回', variable=self.aiLevel, value='mid', command=setAiLevel).pack()
        #tk.Radiobutton(self.interactiveFrame, text= '极寒地域', variable=self.aiLevel, value='high', command=setAiLevel).pack()
        
        tk.Label(self.interactiveFrame, text='    AI:执黑子\n\n棋手:执白子', fg='Orange', font=('Times', 14)).pack(pady=10)

        #分隔线
        tk.Frame(self.interactiveFrame,width=150,height=4, bd=1,relief=SUNKEN, highlightthickness=1).pack(pady=10)

        self.lastChessObj = tk.Button(self.interactiveFrame, text='悔棋', state=tk.DISABLED, font=('Times', 14), width=6 ,command=backLast)
        self.lastChessObj.pack(pady=20)
        self.surrenderObj = tk.Button(self.interactiveFrame, text='认输', state=tk.DISABLED, font=('Times', 14), width=6 ,command=gameOver)
        self.surrenderObj.pack(pady=20)

        #分隔线
        tk.Frame(self.interactiveFrame,width=150,height=4, bd=1,relief=SUNKEN, highlightthickness=1).pack(pady=10)

        self.placeTips = tk.StringVar()
        self.placeTips.set('位置:\n     行:X\n     列:Y')
        tk.Label(self.interactiveFrame,
            textvariable=self.placeTips,
            bg = 'Blue',
            width=11,
            height=3,
            font=('Arial', 12)
            ).pack()

    #画棋子
    def paintChess(self,chesscolor='black', dictcoordinatedata = None):
        chessColor = chesscolor
        dictCoordinateData = dictcoordinatedata
        coreCoordinate = dictCoordinateData['coreCoordinate']
        turnPlace = (dictCoordinateData['mapPlace'][1], dictCoordinateData['mapPlace'][0])
        x1,y1, x2,y2 = int(coreCoordinate[0] - self.chessDiam), int(coreCoordinate[1] - self.chessDiam), int(coreCoordinate[0] + self.chessDiam), int(coreCoordinate[1] + self.chessDiam)
        if chessColor == 'black':
            self.chessObj.append(self.chessCanvas.create_oval(x1,y1, x2,y2 ,fill='black'))
            cb.putChess('black', turnPlace)
            self.blackLastChess = self.chessObj[-1]
            cb.aiLastPlace = turnPlace
        else:
            self.chessObj.append(self.chessCanvas.create_oval(x1,y1, x2,y2 ,fill='white'))
            cb.putChess('white', turnPlace)
            self.whiteLastChess = self.chessObj[-1]
            cb.userLastPlace= turnPlace
        return None

    #对胜利的五子画一条红线
    def painRedLine(self, fivechess):
        fiveChess = fivechess
        turnFiveChess = [ (x[1],x[0]) for x in fivechess ]
        xCoreCoordinate = self.getPlace(coordinate= turnFiveChess[0], coordinatetype='chessPlace')['coreCoordinate']
        yCoreCoordinate = self.getPlace(coordinate= turnFiveChess[-1], coordinatetype='chessPlace')['coreCoordinate']
        self.chessObj.append(self.chessCanvas.create_line(xCoreCoordinate[0],xCoreCoordinate[1], yCoreCoordinate[0],yCoreCoordinate[1], fill='red', width=3))
        

    def getPlace(self,coordinate=(0,0), coordinatetype='coordinate'):
        coordinateType = coordinatetype
        dictCoordinateData = {}
        #交叉点定位算法
        coreCoordinate = lambda n: ((n // self.chessboardLineSpace) + (0 if n % self.chessboardLineSpace < self.chessboardLineSpace/2 else 1)) * self.chessboardLineSpace
        #chess place 到 Coordinate 转换算法
        placeToCoordinate = lambda n: self.chessboardLineSpace * (n+1)
        #Coordinate 到 chess place 转换算法
        coordinateToPlace = lambda n: int(n // self.chessboardLineSpace - 1)
        if coordinatetype == 'coordinate':
            dictCoordinateData = {
                'clickCoordinate':coordinate,
                'coreCoordinate':(coreCoordinate(coordinate[0]), coreCoordinate(coordinate[1])),
                'mapPlace':(coordinateToPlace(coreCoordinate(coordinate[0])),coordinateToPlace(coreCoordinate(coordinate[1]))),
            }
        else:
            dictCoordinateData = {
                'clickCoordinate':(placeToCoordinate(coordinate[0]), placeToCoordinate(coordinate[1])),
                'coreCoordinate':(placeToCoordinate(coordinate[0]), placeToCoordinate(coordinate[1])),
                'mapPlace':coordinate
            }

        #黑白棋子计数
        whiteChessCount=0
        blackChessCount=0
        for x in range(cb.rowNum):
            for y in range(cb.colNum):
                if cb.arrChessboard[x][y] == cb.blackChess:
                    blackChessCount += 1
                elif cb.arrChessboard[x][y] == cb.whiteChess:
                    whiteChessCount += 1

        cb.chessCount = {
            'whiteChessCount':whiteChessCount,
            'blackChessCount':blackChessCount,
            'putChessTotal':whiteChessCount+blackChessCount,
        }
        return dictCoordinateData


    def lastChessboard(self):
        for lastChess in (self.blackLastChess, self.whiteLastChess):
            self.chessCanvas.delete(self.chessObj[-1])
            self.chessObj.pop()
        cb.lastChessboard()
        self.lastChessObj.config(state=tk.DISABLED)

def startGame():
    global tg,cb
    #实例化AI棋局
    cb = Chessboard()
    cb.initArrChessboard()
    tg = TkinterGui()
    tkObject = tg.initMasterFrame()
    tg.paintChessboard()
    tg.createInteractiveFrame()

    tg.rootFrame.mainloop()
    

if __name__ == '__main__':
    startGame()