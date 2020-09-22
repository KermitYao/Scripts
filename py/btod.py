#--coding:utf-8--
import sys

def bin(str):
    decNum=0
    bLen=len(str)
    pow=bLen
    if bLen > 0: 
        for n in range(0,bLen):
            pow-=1
            decNum+=int(str[n])*factorial(2, pow)
        return decNum
    else:
        return None

def hex(strs):
    decNum=0
    hexMap=['a','b','c','d','e','f','A','B','C','D','E','F']
    bLen=len(strs)
    pow=bLen
    if bLen > 0: 
        for n in range(0,bLen):
            pow-=1
            if strs[n] in hexMap:
                if hexMap.index(strs[n])>5:
                    hexn=9+hexMap.index(strs[n])-5+1
                else:
                    hexn=9+hexMap.index(strs[n])+1
            else:
                hexn=int(strs[n])
            decNum+=int(hexn)*factorial(16, pow)
        return decNum
    else:
        return None

def factorial(bin,fac):
    s=1
    for i in range(1,fac+1):
        s=bin*s
    return s

if __name__=='__main__':
    if len(sys.argv)<2:
        print('Usage:')
        print('\t{} [bin int ]'.format(__file__))
        print('\t{} 16 15f1'.format(__file__))
        exit(0)
    if sys.argv[1]=='2':
        print(bin(sys.argv[2]))
    elif sys.argv[1]=='16':
        print(hex(sys.argv[2]))
    else:
        print('Usage:')
        print('\t{} [bin int ]'.format(__file__))
        print('\t{} 16 15f1'.format(__file__))




