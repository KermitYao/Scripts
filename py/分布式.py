import random, time,queue,sys
from multiprocessing.managers import BaseManager

#发送的任务队列
taskQueue = queue.Queue()

#接收的任务队列
resultQueue = queue.Queue()

def getTaskQueue():
    return taskQueue

def getResultQueue():
    return resultQueue

#继承QueueManager
class QueueManager(BaseManager):
    pass

#把队列注册到网络上，callable参数关联了queue对象,因为可能有多个对象，所以每个对象需要去一个名字
QueueManager.register('getTaskQueue', callable=getTaskQueue)
QueueManager.register('getResultQueue', callable=getResultQueue)


def masterMain():
    #绑定端口和验证码
    manager = QueueManager(address=('127.0.0.1', 5000), authkey=b'abc')

    #启动queue
    manager.start()
    #通过网络访问queue对象
    task = manager.getTaskQueue()
    result = manager.getResultQueue()

    #将任务放入队列
    for i in range(10):
        n = random.randint(0,1000)
        print('Put task %d...' % n)
        task.put(n)
    #从队列读取结果
    for i in range(10):
        #本机读取
        #r = task.get(timeout=10)
        #读取远程数据
        r = result.get(timeout=10)
        print('Result: %s' % r)

    #关闭manger
    manager.shutdown()
    print('master exit.')


def workMain():
    # 把队列注册到网络上，callable参数关联了queue对象,因为可能有多个对象，所以每个对象需要去一个名字
    QueueManager.register('getTaskQueue')
    QueueManager.register('getResultQueue')

    #绑定端口和验证码
    manager = QueueManager(address=('127.0.0.1', 5000), authkey=b'abc')
    #连接到服务器
    manager.connect()

    #通过网络访问queue对象
    task = manager.getTaskQueue()
    result = manager.getResultQueue()

    #从队列读取结果
    for i in range(10):
        try:
            #读取队列
            r = task.get(timeout=10)
            print('Result: %s' % r)
            r = r + r
            #计算结果写入到结果队列
            result.put(r)
        except queue.Empty:
            print('task queue is empty.')

    print('work exit.')



if '__main__' == __name__:
    if len(sys.argv)>1:
        masterMain()
    else:
        workMain()