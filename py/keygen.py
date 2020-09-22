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
    sum=0
    for i in range(0,times):
        if sum%10==3:
            n=4
        else:
            n=3
        sum+=n
    if str(sum)[-1]=='3':
        return sum+26
    else:
        return sum+25
    return sum

#|sum|/10=times - 26 or 25 - 3 or 4 times次
def time_de(times):
    sum=times
    if str(times)[-1]=='9':
        sum-=26
    else:
        sum-=25
    for i in range(0,sum):
        if sum%10==7:
            n=3
        else:
            n=4
        sum-=n
    return int(abs(sum/10))


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
