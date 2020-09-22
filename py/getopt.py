#-*-coding:utf-8-*-
import sys,getopt


try:
    opts,args=getopt.getopt(sys.argv[1:],'hyo:i:',['help','yes','out=','input='])
    for opt_name,opt_value in opts:
        if opt_name in ('-h','--help'):
            print('{}:{}, help info.'.format(opt_name,opt_value or 'noValue'))
        if opt_name in ('-y','--yes'):
            print('{}:{}, yes info.'.format(opt_name,opt_value or 'noValue'))
        if opt_name in ('-o','--out'):
            print('{}:{}, out info.'.format(opt_name,opt_value or 'noValue'))
        if opt_name in ('-i','--input'):
            print('{}:{}, input info.'.format(opt_name,opt_value or 'noValue'))       
except getopt.GetoptError  as abn:
    print(abn)



