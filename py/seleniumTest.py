
from selenium import webdriver
from selenium.webdriver.common.by import By
import time
wd = webdriver.Edge()
wd.get('https://yjyn.top:1443')
time.sleep(1)
wd.find_element(By.NAME, 'username').send_keys('root')
wd.find_element(By.NAME, 'password').send_keys('yk@555698')
r = wd.find_element(By.TAG_NAME, 'button').text
print('r,%s' % r)
input('wait...')