import time,os,time,random,threading

def runSubThread(msg,n):
    print('Run child thread %s (%s)...' % (msg, os.getpid()))
    print('current thread (%s)...' % threading.current_thread())
    startTime = time.time()
    #验证测试变量共享,先加后减，理论应该持平，但是因为各个线程赋值时序不一致，可能会导致结果错误
    for i in range(20000000):
        #获取锁
        lock.acquire()
        try:
            chageN(n)
        finally:
            #一定要释放锁，否则会永远阻塞
            lock.release()
    #time.sleep(random.randrange(10))
    endTime = time.time()
    print('Task %s runs %0.2f seconds.' % (msg, (endTime - startTime)))


def chageN(n):
    global balance
    balance = balance + n
    balance = balance - n
    #print(balance,n)
    

#多进程
def multiThread():
    print('child thread will start.')

    '''
    #创建子线程,传输执行函数和参数,args只接受一个对象,可以是元组、列表、或者dict，不能是字符串,会被当做参数列表传递给子线程
    t = threading.Thread(target=runSubThread, args=('test',))
    #启动子进程
    t.start()
    #打印当前线程总数，包括自身
    print('current active thread count: %s' % threading.active_count())
    #阻塞,等待进程终止, 默认 timeout = None, 可以设置阻塞时间
    t.join(timeout=4)
    '''


    #共享变量测试， 验证测试变量共享,先加后减，理论应该持平，但是因为各个线程赋值时序不一致，可能会导致结果错误
    t1 = threading.Thread(target=runSubThread, args=('test',5))
    t2 = threading.Thread(target=runSubThread, args=('test',8))
    t1.start()
    t2.start()
    t1.join()
    t2.join()



    '''
    #多进程测试
    for i in range(200):
        threading.Thread(target=runSubThread, args=(i,)).start().join()
        #启动子进程
        #t.start()
        #打印当前线程总数，包括自身
        print('current active thread count: %s' % threading.active_count())
        #阻塞,等待进程终止, 默认 timeout = None, 可以设置阻塞时间
        #t.join(timeout=4)
    '''
    
    print('child thread end.')
    return
balance= 0

#加线程锁，可以解决线程变量不同步问题；原理是，未获得锁则阻止当前线程执行
lock = threading.Lock()
def main():

    
    multiThread()
    print ('value balance : ',balance)

if __name__ == "__main__":
    main()