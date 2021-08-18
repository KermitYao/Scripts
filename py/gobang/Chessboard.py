#!/usr/bin/python3
#-*- coding: utf-8 -*-

#AI 棋盘和策略处理
import EvaluateFactor
import random

class Chessboard():
    def __init__(self,row=15,col=15,blackchess='◉ ',whitechess='◎',nullchess='＋'):
        self.rowNum=row
        self.colNum=col
        self.blackChess=blackchess
        self.whiteChess=whitechess
        self.nullChess=nullchess
        self.aiLastPlace=False
        self.userLastPlace=None
        self.winChess=[]
        self.chessRange=3
        #剪枝宽度, 评分最高的前多少个棋子落点
        self.cutBranchRange=5
        self.chessCount={
            'whiteChessCount':0,
            'blackChessCount':0,
        }
    #初始化棋盘数据  
    def initArrChessboard(self):
        self.arrChessboard=[[self.nullChess for y in range(self.colNum)] for x in range(self.rowNum)]
        return self.arrChessboard


    #设置AI等级
    def aiPut(self, level = 'low'):
        if level == 'low':
            return self.lowPolicy()
        elif level == 'mid':
            return self.middlePolicy()
        elif level == 'high':
            return self.hightPolicy
        return False

    #生成以中心点半径距离 3 范围内的随机坐标
    def aiFirstPut(self):
        return (random.randint(int(self.rowNum/2) - self.chessRange, int(self.rowNum/2) + self.chessRange), random.randint(int(self.colNum/2) - self.chessRange, int(self.colNum/2) + self.chessRange))

    #初级AI
    def lowPolicy(self, chesscolor = 'black', chesscount = 'blackChessCount'):
        chessColor = chesscolor
        chessCount = chesscount
        listTmpEvaluateFactor=[]
        if self.chessCount['blackChessCount'] + self.chessCount['whiteChessCount'] == 0:
            while True:
                randomPlace=self.aiFirstPut()
                if self.arrChessboard[randomPlace[0]][randomPlace[1]] == self.nullChess:
                    dictTmpFactor = {
                        'chessPlance':(randomPlace[0], randomPlace[1]),
                        'evaluateScore': 0,
                        }
                    listTmpEvaluateFactor.append(dictTmpFactor)
                    return listTmpEvaluateFactor
        else:
            for x in range(self.rowNum):
                for y in range(self.colNum):
                    if self.arrChessboard[x][y] == self.nullChess:
                        #----------broken
                        if chessColor == 'black':
                            self.arrChessboard[x][y] = self.blackChess
                        else:
                            self.arrChessboard[x][y] = self.whiteChess
                        aiEvaluateScore = self.evaluateChess(chessColor, self.scanChessboard((x, y)))
                        dictTmpFactor = {
                            'chessPlance':(x,y),
                            'evaluateScore': aiEvaluateScore['totalScore'],
                        }
                        self.arrChessboard[x][y] = self.nullChess
                        if aiEvaluateScore['totalScore'] >= 100000:
                            listTmpEvaluateFactor.append(dictTmpFactor)
                        else:
                            listTmpEvaluateFactor.append(dictTmpFactor)
        return self.cutBranch(listTmpEvaluateFactor)

    #中级AI
    def middlePolicy(self):
        listEvaluateFactorMid=[]
        aiListEvaluateFactor = self.lowPolicy(chesscolor = 'black', chesscount = 'blackChessCount')
        userListEvaluateFactor = self.lowPolicy(chesscolor = 'white', chesscount = 'whiteChessCount')
    
        #遍历剪枝后的棋子坐标
        for x in range(len(aiListEvaluateFactor)):
            #当当前棋子坐标权值小于 0 表示周围无子，大于100000时，表示已经五子连珠，此时不在对比权值大小。
            if aiListEvaluateFactor[x]['evaluateScore'] != 0 or aiListEvaluateFactor[x]['evaluateScore'] >= 100000:
                evaluateScoreDiff = aiListEvaluateFactor[x]['evaluateScore'] - userListEvaluateFactor[x]['evaluateScore']
                #Minimax
                if evaluateScoreDiff >= 0:
                    dictTmpFactor = {
                        'chessPlance':aiListEvaluateFactor[x]['chessPlance'],
                        'evaluateScore': aiListEvaluateFactor[x]['evaluateScore'],
                        'evaluateScoreDiff':evaluateScoreDiff,
                    }
                    listEvaluateFactorMid.append(dictTmpFactor)
                else:
                    dictTmpFactor = {
                        'chessPlance':userListEvaluateFactor[x]['chessPlance'],
                        'evaluateScore': userListEvaluateFactor[x]['evaluateScore'],
                        'evaluateScoreDiff':evaluateScoreDiff,
                    }
                    listEvaluateFactorMid.append(dictTmpFactor)
            else:
                dictTmpFactor = {
                    'chessPlance':aiListEvaluateFactor[x]['chessPlance'],
                    'evaluateScore': aiListEvaluateFactor[x]['evaluateScore'],
                    'evaluateScoreDiff':0,
                    }
                listEvaluateFactorMid.append(dictTmpFactor)
        return self.cutBranch(listEvaluateFactorMid)


    #获取五连坐标
    def getFiveChess(self,chesscolor, dictEvaluateScore):
        if chesscolor == 'white':
            chessColor = self.whiteChess
        else:
            chessColor = self.blackChess
        winChessPlace = []
        for chessLine in dictEvaluateScore:
            #过虑掉分数项
            if chessLine != 'totalScore':
                #取出四条九子连线坐标
                #print('九子连线:',dictEvaluateScore[chessLine]['chessPlanceLine'])
                for x in range(len(dictEvaluateScore[chessLine]['chessPlanceLine'])):
                    tmpChessPlanceLine = dictEvaluateScore[chessLine]['chessPlanceLine']
                    #判断第个坐标的棋子，是否为相应着色，若为真则追加到列表尾部
                    if self.arrChessboard[tmpChessPlanceLine[x][0]][tmpChessPlanceLine[x][1]] == chessColor:
                        winChessPlace.append((tmpChessPlanceLine[x][0], tmpChessPlanceLine[x][1]))
                        #如果为五了连珠，则直接跳出循环
                        #print('单子:', (tmpChessPlanceLine[x][0], tmpChessPlanceLine[x][1]))
                        if len(winChessPlace) == 5:
                            return winChessPlace
                    #当出现一个子非相应着色，表示棋子已不再连续，清空列表，重新寻找
                    else:
                        winChessPlace = []
        return winChessPlace




    #高级AI
    def hightPolicy(self):
        if self.chessCount['blackChessCount'] == 0:
            return self.aiFirstPut()

    #alpha - beta 剪枝
    def cutBranch(self, listevaluatescore):
        listTmpEvaluateFactor=listevaluatescore
        return sorted(listTmpEvaluateFactor, key=lambda x: x['evaluateScore'], reverse=True)[0:self.cutBranchRange]


    #落子
    def putChess(self, player, place):
        if 'player' in vars() and 'place' in vars():
            if player == 'black':
                self.arrChessboard[place[0]][place[1]] = self.blackChess
                self.aiLastPlace=place
            elif player == 'white':
                self.arrChessboard[place[0]][place[1]] = self.whiteChess
                self.userLastPlace=place
            else:
                return False
        return True
    #悔棋
    def lastChessboard(self):
        if self.userLastPlace and self.aiLastPlace:
            for lastPlace in (self.aiLastPlace, self.userLastPlace):
                x, y = lastPlace
                self.arrChessboard[x][y] = self.nullChess
        return True

    #棋盘扫描
    def scanChessboard(self,chessplace):
        #获取以落子点为中心的八个方位,与落点交汇行成的四条九子连线
        chessPlace=chessplace
        tmpChessLineX=[]
        tmpChessLineY=[]
        tmpChessLineLD=[]
        tmpChessLineRD=[]

        #获取x轴九子连线
        for y in range(int(chessPlace[1])-4, int(chessPlace[1])+4+1):
            if y < 0 or y > self.colNum -1:
                continue
            else:
                tmpChessLineX.append((chessPlace[0],y))

        #获取y轴九子连线
        for x in range(int(chessPlace[0])-4, int(chessPlace[0])+4+1):
            if x < 0 or x > self.rowNum -1:
                continue
            else:
                tmpChessLineY.append((x, chessPlace[1]))

		#获取左下九子连线
        for m in range(9):
            #将棋子坐标放置到以当前坐标点的左上4位置，然后右下连线，过虑掉越界棋子
            if chessPlace[0] - 4 + m < 0 or chessPlace[0] - 4 + m > self.rowNum -1 or chessplace[1] -4 + m < 0 or chessplace[1] -4 + m > self.rowNum -1 :
                continue
            else:
                tmpChessLineLD.append((chessPlace[0] - 4 + m, chessplace[1] -4 + m))

        #获取右下九子连线
        for n in range(9):
            #将棋子坐标放置到以当前坐标点的右上4位置，然后左下连线，过虑掉越界棋子
            if chessPlace[0] - 4 + n < 0 or chessPlace[0] - 4 + n > self.rowNum -1 or chessplace[1] + 4 - n < 0 or chessplace[1] + 4 - n > self.colNum -1 :
                continue
            else:
                tmpChessLineRD.append((chessPlace[0] - 4 + n, chessplace[1] + 4 - n))

        return {
            'chessLineX':tmpChessLineX,
            'chessLineY':tmpChessLineY,
            'chessLineLD':tmpChessLineLD,
            'chessLineRD':tmpChessLineRD
        }



    #权值评估
    def evaluateChess(self, evaluatecolor, dictchessline):
        evaluateFactor=EvaluateFactor.evaluateFactor
        tmpEvaluate = {}
        tmpTotalScore = 0
        dictChessLine = dictchessline
        evaluateColor = evaluatecolor

        #将坐标转换成字符串，用于匹配成活因子
        for tmpPlaceLine in dictChessLine:
            tmpStr=''
            for tmpPlace in dictChessLine[tmpPlaceLine]:
                tmpStr = tmpStr + self.arrChessboard[tmpPlace[0]][tmpPlace[1]]
            if evaluateColor == 'black':
                tmpStr=tmpStr.replace(self.blackChess, '1').replace(self.whiteChess, '2').replace(self.nullChess, '0')
            else:
                tmpStr=tmpStr.replace(self.blackChess, '2').replace(self.whiteChess, '1').replace(self.nullChess, '0')

            #--------------------------------墙体检测--------------------------------------------------
            #检测横向边界
            if tmpPlaceLine == 'chessLineX':
                #检测为左边界，则添加对方棋子
                if dictChessLine[tmpPlaceLine][0][1] == 0:
                    tmpStr='2' + tmpStr
                #检测为左边界，则添加对方棋子
                if dictChessLine[tmpPlaceLine][-1][1] == self.colNum-1:
                    tmpStr=tmpStr + '2'

            #检测纵向边界
            elif tmpPlaceLine == 'chessLineY':
                #检测为上边界，则添加对方棋子
                if dictChessLine[tmpPlaceLine][0][0] == 0:
                    tmpStr='2' + tmpStr
                #检测为下边界，则添加对方棋子
                if dictChessLine[tmpPlaceLine][-1][0] == self.rowNum-1:
                    tmpStr=tmpStr + '2'

            #检测左下边界
            elif tmpPlaceLine == 'chessLineLD':
                #检测左上边界，则添加对方棋子
                if dictChessLine[tmpPlaceLine][0][0] == 0 or dictChessLine[tmpPlaceLine][0][1] == 0:
                    tmpStr='2' + tmpStr
                #检测左下边界，则添加对方棋子
                if dictChessLine[tmpPlaceLine][-1][0] == self.rowNum-1 or dictChessLine[tmpPlaceLine][-1][1] == self.colNum-1:
                    tmpStr=tmpStr + '2'

            #检测右下边界
            elif tmpPlaceLine == 'chessLineRD':
                #检测右上边界，则添加对方棋子
                if dictChessLine[tmpPlaceLine][0][0] == 0 or dictChessLine[tmpPlaceLine][0][1] == self.colNum-1:
                    tmpStr='2' + tmpStr
                #检测右下边界，则添加对方棋子
                if dictChessLine[tmpPlaceLine][-1][0] == self.rowNum-1 or dictChessLine[tmpPlaceLine][-1][1] == 0:
                    tmpStr=tmpStr + '2'
            #--------------------------------墙体检测--------------------------------------------------

            #评估九字连线分数
            tmpScore=0
            for factor in evaluateFactor:
                if factor in tmpStr:
                    tmpScore += evaluateFactor[factor]

            #插入数据
            tmpEvaluate[tmpPlaceLine] = {
                #向字典中插入各方位九字连线原始坐标
                'chessPlanceLine':dictChessLine[tmpPlaceLine],
                #向字典中插入各方位转换后的九字连线
                'chessPlanPath':tmpStr,
                #评估各方位九字连线分数
                'evaluateScore':tmpScore,
            }
            tmpTotalScore += tmpScore
    
        #插入当前落子总分数
        tmpEvaluate['totalScore'] = tmpTotalScore
        return tmpEvaluate

if __name__=='__main__':
    cb=Chessboard()
    cb.initArrChessboard()
    cb.putChess('white', (5,4))
    cb.putChess('white', (5,5))
    
    cb.arrChessboard[5][2] = cb.whiteChess
    print(cb.scanChessboard((5,2)))
    print(cb.evaluateChess('white', cb.scanChessboard((5,2))))
    for x in cb.arrChessboard:
        print
    print(cb.arrChessboard)
