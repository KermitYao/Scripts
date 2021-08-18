#!/usr/bin/python3
#-*- coding: utf-8 -*-
import os
import traceback
from Chessboard import Chessboard


#画出当前棋盘
def createChessboardCui(cb):
    whiteChessCount=0
    blackChessCount=0
    print('\n')
    print('\n')
    print('坐标'+'\t', end='')
    for x in range(cb.colNum):
        spaceNum='   ' if x < 9 else '  '
        print(x, end=spaceNum)
    print('\n\n')

    for x in range(cb.rowNum):
        print(x,'\t',end='')
        for y in range(cb.colNum):

            #给棋子着色
            if cb.arrChessboard[x][y] == cb.blackChess:
                blackChessCount += 1
                #如果为五子连珠则闪烁
                if (x, y) in cb.winChess:
                    print('{0}'.format(cb.arrChessboard[x][y]), end="  ")
                    #print('\033[4;30m{0}\033[0m'.format(cb.arrChessboard[x][y]), end="  ")
                else:
                    print('{0}'.format(cb.arrChessboard[x][y]), end="  ")
                    #print('\033[0;30m{0}\033[0m'.format(cb.arrChessboard[x][y]), end="  ")
            elif cb.arrChessboard[x][y] == cb.whiteChess:
                whiteChessCount += 1
                #如果为五子连珠则闪烁
                if (x, y) in cb.winChess:
                    print('{0}'.format(cb.arrChessboard[x][y]), end="  ")
                    #print('\033[4;37m{0}\033[0m'.format(cb.arrChessboard[x][y]), end="  ")
                else:
                    print('{0}'.format(cb.arrChessboard[x][y]), end="  ")
                    #print('\033[1;37m{0}\033[0m'.format(cb.arrChessboard[x][y]), end="  ")
            else:
                print(cb.arrChessboard[x][y]+'' ,end="  ")
        print("\n")
    cb.chessCount = {
        'whiteChessCount':whiteChessCount,
        'blackChessCount':blackChessCount,
    }

    return cb.chessCount

def titlePrint(level='info', action='tips', how='stand optput', msg='^^^', clear=True):
    if clear:
        if os.name == 'nt':
            os.system("cls")
            pass
        else:
            os.system('clear')
            pass
    else:
        pass

    print('\n**** {0} --- {1} --- {2} --- {3} ****\n'.format(level, action, how, msg))
    return True




#游戏过程调用
def startGame(firstput='AI', aifirsputrange=3):
    cb=Chessboard()
    firstPut = firstput
    aiFirsPutRange=aifirsputrange
    title=None
    initReturn=cb.initArrChessboard()
    flag=firstPut
    aiEvaluateScore=0
    userEvaluateScore=0
    exitFlag=('end', 'quit', 'exit', 'close', 'q')
    if flag == 'USER':
        titlePrint(level='info', action='落子', msg='用户先手,请落子')
    while True:
        createChessboardCui(cb)
        try:
            #玩家落子
            if flag == 'USER':
            #获取用户坐标
                print('\t\t(x,y) | flush | last | quit\n')
                userInput=input('请输入棋子坐标(例如: 1,2):')
                endFlas=False
                if userInput in exitFlag:
                    break
                if userInput == 'flush':
                    titlePrint(how='USER', msg='已重新开局')
                    cb.initArrChessboard()
                    continue
                if userInput == 'last':
                    titlePrint(how='USER', msg='已悔棋')
                    cb.lastChessboard()
                    continue

                userInputX, userInputY=userInput.split(',')
                titlePrint(level='info', action='落子', how='AI', msg='坐标:{}'.format((userInputX, userInputY)))
                userInputX, userInputY=int(userInputX), int(userInputY)
                #越界处理
                if userInputX > cb.rowNum -1 or userInputY > cb.colNum - 1:
                    titlePrint(level='error', action='落子', how='USER', msg='坐标:{},坐标越界'.format((userInputX, userInputY)))
                    continue
                if userInputX < 0 or userInputY < 0:
                    titlePrint(level='error', action='落子', how='USER', msg='坐标:{},坐标越界'.format((userInputX, userInputY)))
                    continue
                if cb.arrChessboard[userInputX][userInputY] == cb.nullChess:
                    cb.putChess('white', (userInputX, userInputY))
                    dictChessLine = cb.scanChessboard((userInputX, userInputY))
                    userEvaluateScore = cb.evaluateChess('while', dictChessLine)
                    #当分数大于一定的值则表示出现五子连珠，则扫描五子坐标
                    if userEvaluateScore['totalScore'] >= 100000:
                        userFiveChess = cb.getFiveChess('white', userEvaluateScore)
                        cb.winChess = userFiveChess
                        while True:
                            titlePrint(level='info', action='落子', how='USER', msg='坐标:{0}, 五子:{1}, 评分:{2}'.format(([userInputX], [userInputY]), userFiveChess, userEvaluateScore['totalScore']))
                            createChessboardCui(cb)
                            titlePrint(level='info', action='结束', how='USER', msg='USER 已经获得胜利,输入 flush 重新开局', clear=False)
                            aiEndInput=input('Input "flush" to again the game, And input "exit" to exit the game.:')
                            if aiEndInput == 'flush':
                                titlePrint(msg='{0}先手,请落子'.format(firstPut))
                                cb.initArrChessboard()
                                flag=firstPut
                                break
                            elif aiEndInput in exitFlag:
                                return True
                    else:
                        flag = 'AI'
                else:
                    titlePrint(level='error', action='落子', how='USER', msg='坐标:{},此处已落子'.format((userInputX, userInputY)))
            else:
                #AI落子
                aiPlace=cb.aiPut('mid')[0]['chessPlance']
                print(aiPlace)
                cb.putChess('black', aiPlace)
                dictChessLine = cb.scanChessboard(aiPlace)
                aiEvaluateScore = cb.evaluateChess('black', dictChessLine)
                titlePrint(level='info', action='落子', how='AI', msg='坐标:{0}, 评分:{1}'.format(aiPlace, aiEvaluateScore['totalScore']))
                #当分数大于一定的值则表示出现五子连珠，则扫描五子坐标
                if aiEvaluateScore['totalScore'] >= 100000:
                    aiFiveChess = cb.getFiveChess('black', aiEvaluateScore)
                    cb.winChess = aiFiveChess
                    while True:
                        titlePrint(level='info', action='落子', how='AI', msg='坐标:{0}, 五子:{1}, 评分:{2}'.format(aiPlace, aiFiveChess, aiEvaluateScore['totalScore']))
                        createChessboardCui(cb)
                        titlePrint(level='info', action='结束', how='AI', msg='AI 已经获得胜利,输入 flush 重新开局', clear=False)
                        aiEndInput=input('Input "flush" to again the game, And input "exit" to exit the game.:')
                        if aiEndInput == 'flush':
                            titlePrint(msg='{0}先手,请落子'.format(firstPut))
                            cb.initArrChessboard()
                            flag=firstPut
                            break
                        elif aiEndInput in exitFlag:
                            return True 
                else:
                    flag = 'USER'

        except Exception as e:
            titlePrint(msg='输入有误:{0}'.format(e))
            exc = traceback.format_exc()
            print(exc)


if __name__=='__main__':
    startGame()

