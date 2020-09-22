#--coding:utf8--
import sys

#en=26+(uuid/3)
def uuid_en(uuid):
    cons_n=26
    return cons_n+int(uuid/3)

#de=(uuid-26)*3
def uuid_de(uuid):
    cons_n=26
    return (uuid-cons_n)*3

#sum=times+4 or 3 times 次+ 26 or 25
def time_en(times):
    modSum=0
    mod=times%3
    if mod==1:
        modSum=3
    elif mod==2:
        modSum=7
    intSum=(times-times%3)//3*10+modSum
    if intSum%10==3:
        n=26
    else:
        n=25
    sum=intSum+n
    return sum

#|sum|/10=times - 26 or 25 - 3 or 4 times次
def time_de(times):
    if (times-26)%10==3:
        n=26
    else:
        n=25
    srcSum=(times-n)
    mod=(srcSum%10)
    modSum=0
    if mod==3:
        modSum=1
    elif mod==7:
        modSum=2
    intSum=(srcSum-modSum)/10*3
    sum=intSum+modSum
    return int(sum)
if __name__=='__main__':
    if len(sys.argv)>3:
        if sys.argv[1]=='-e' or sys.argv[1]=='/e':
            uuiden=uuid_en(int(sys.argv[2]))
            timeen=time_en(int(sys.argv[3]))
            print(str(uuiden)+'-'+str(timeen))
        elif sys.argv[1]=='-d' or sys.argv[1]=='/d':
            uuidde=uuid_de(int(sys.argv[2]))
            timede=time_de(int(sys.argv[3]))
            print(str(uuidde)+'-'+str(timede))
        else:
            print('参数错误! 0011')
    else:
        print('参数错误! 0012')

