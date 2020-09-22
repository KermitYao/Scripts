#!/bin/python3

from html.parser import HTMLParser
import requests

#重写parser实例
class HtmlParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.flagLiStart = False
        #self.flagLiEnd = False
        self.tagState = False
    
    #标签开始, attrs 为标签属性.   tag 可以配合  handle_endtag， 做内容过滤。
    def handle_starttag(self, tag, attrs):
        if tag == 'li':
            self.flagLiStart = True
        if self.flagLiStart:
            if tag == 'a':
                for a, v in attrs:
                    if a == 'href':
                        self.tagState = True
                        print('属性:{0}, 值:{1}'.format(a, v))
    def handle_endtag(self, tag):
        if tag == 'li':
            self.flagLiStart = False
            #self.flagLiEnd = True
    #标签内容。        
    def handle_data(self, data):
        if self.tagState:
            print('data:%s' % data)
            self.tagState=False

parser = HtmlParser()
webTxt = requests.get('http://yjyn.top:6081')
parser.feed(webTxt.text)
parser.close
