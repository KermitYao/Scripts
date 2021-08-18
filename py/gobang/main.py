#!/usr/bin/python3
#-*- coding: utf-8 -*-

if __name__ == '__main__':
    UI = 'Gui'
    if UI == 'Cui':
        import GameCui
        #The value is 'USER' or 'AI' for 'firstput' args 
        GameCui.startGame(firstput='USER')
    else:
        import GameGui
        GameGui.startGame()

