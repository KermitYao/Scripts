#-*-coding:utf-8-*-
import sys
def print_test(str):
    print(str)
    def _call(func):
        def wrapper(*args, **kwargs):
            print('test')
            print('add func---func:%s,tupl:%s' % sys._getframe().f_code.co_name,args)
            return func(*args, **kwargs)
        return wrapper
    return _call

@print_test('abcdefg')
def say_hello(n):
    print('hello *%s*!---func:%s' % (n,sys._getframe().f_code.co_name))
    return True
print(say_hello)
print(say_hello(123))