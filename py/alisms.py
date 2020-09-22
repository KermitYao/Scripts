#-*-coding:utf-8-*-
from aliyunpublic import ALiYunPublic as ali

action={
    'Action':'SendSms',
    'Version':'2017-05-25',
    'Regionld':'cn-hangzhou',
    'PhoneNumbers':'13027011115',
    'SignName':'姚见宇',
    'TemplateCode':'SMS_131045033',
    'TemplateParam':'{\'consignee\':\'我爱你\',\'number\':\'13027011115\'}'
}
accessID = 'id'
accessKey = 'key'
sms=ali()
sms.urlPath='https://dysmsapi.aliyuncs.com/?'
sms.setAccessInfo(accessID,accessKey)
sms.setAction(action)
sms.update()
print(sms.getInfo('singture'))
print(sms.sendRequest())
