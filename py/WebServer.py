from wsgiref.simple_server import make_server
def application(environ, start_response):
    for t in environ:
        print('%s:%s' % (t,environ[t]))
    start_response('200 OK',[('Content-Type', 'text/html')])
    body = '<h1>Hello, %s!</h1>' % (environ['PATH_INFO'])
    return [body.encode('utf-8')]

httpd = make_server('',8000,application)
print('start scr 8000 port...')
httpd.serve_forever()