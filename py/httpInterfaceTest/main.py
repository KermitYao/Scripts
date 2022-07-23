import sys
import re
import requests
import os
from PyQt5.QtCore import QThread, pyqtSignal
from PyQt5 import QtCore
from PyQt5.QtGui import QIcon
from PyQt5 import QtWidgets
from PyQt5.QtWidgets import QApplication, QWidget, QTableWidgetItem, QMessageBox, QCompleter
from ui import Ui_Http as Ui

# 开启QT多线程,以解决阻塞问题
class NewThread(QThread):
    updateData = pyqtSignal(str)
    def __init__(self, parent=None):
        super(NewThread, self).__init__(parent)
        self.url = None
        self.method = None
        self.headers = None
        self.data = None
        self.proxies = None

    def run(self):
        response = {}
        try:
            self.timeOut = 6
            if self.method == 'GET':
                r = requests.get(self.url, proxies=self.proxies, timeout=self.timeOut, headers=self.headers, params=self.data)
            elif self.method == 'POST':
                r = requests.post(self.url, proxies=self.proxies, timeout=self.timeOut, headers=self.headers, data=self.data)
            elif self.method == 'PUT':
                r = requests.put(self.url, proxies=self.proxies, timeout=self.timeOut, headers=self.headers, params=self.data)
            elif self.method == 'DELETE':
                r = requests.delete(self.url, proxies=self.proxies, timeout=self.timeOut, headers=self.headers, params=self.data)
            else:
                r = requests.get(self.url, proxies=self.proxies, timeout=self.timeOut, headers=self.headers, params=self.data)

            response['status'] = True
            response['response'] = r
        except Exception as e:
            response['status'] = False
            response['response'] = e

        if response['status']:
            responseHeaderContent = ''
            for item in response['response'].headers:
                responseHeaderContent = responseHeaderContent + item + ': ' + response['response'].headers[item] + '\n'
            requestHeaderContent = ''
            for item in response['response'].request.headers:
                requestHeaderContent = requestHeaderContent + item + ': ' + response['response'].request.headers[
                    item] + '\n'
            outContent = '''
    已编码URL: {0}
    - - - - - - - - - - - - - - - - - - - -
    状态码: {1}
    - - - - - - - - - - - - - - - - - - - -
    请求头:
    {2}
    - - - - - - - - - - - - - - - - - - - -
    响应头:
    {3}
    - - - - - - - - - - - - - - - - - - - -
    内容:
    {4}
                '''.format(response['response'].url, response['response'].status_code, requestHeaderContent,
                           responseHeaderContent,
                           response['response'].text)
        else:
            outContent = '''
                请求出现错误:
                    {0}
                '''.format(str(response['response']))
        self.updateData.emit(outContent)

class MainWindow(QWidget):
    def __init__(self, parent=None):
        super(QWidget, self).__init__(parent)
        self.ui = Ui()
        self.ui.setupUi(self)
        self.setWindowTitle('Http 接口测试')
        self.setWindowIcon(QIcon('logo.png'))
        self.ui.requestHeader.insertRow(0)
        self.browserHeader_1 = QTableWidgetItem('User-Agent')
        self.ui.requestHeader.setItem(0, 0, self.browserHeader_1)
        self.browserHeader_2 = QTableWidgetItem(
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:99.0) Gecko/20100101 Firefox/99.0')
        self.ui.requestHeader.setItem(0, 1, self.browserHeader_2)

        self.autoComplete()

    # 配置自动补全
    def autoComplete(self):
        self.completer = QCompleter(self.getCompleteList())

        #设置匹配模式 三种: Qt.MatchStartsWith 开头匹配 默认
        #                Qt.MatchContains 内容匹配
        #                Qt.MatchEndsWith 结尾匹配
        self.completer.setFilterMode(QtCore.Qt.MatchContains)

        # 设置补全模式 三种: QCompleter.PopupCompletion（默认）
        #                 QCompleter.InlineCompletion 行内补全
        #                 QCompleter.UnfilteredPopupCompletion 全显补全
        self.completer.setCompletionMode(QtWidgets.QCompleter.PopupCompletion)
        self.ui.urlEdit.setCompleter(self.completer)
        self.ui.httpProxy.setCompleter(self.completer)

    # 获取自动补全数据
    def getCompleteList(self, path='complete.db'):
        if os.path.isfile(path):
            with open(path, mode='r') as f:
                s = lambda s: s.replace('\n', '')
                return list(map(s, f.readlines()))
        else:
            return []
    # 保存自动补全数据
    def setCompleteList(self, content='', path='complete.db'):
        if len(content) > 0:
            if not content in self.getCompleteList():
                with open(path, mode='a') as f:
                    f.write(content + '\n')
                self.autoComplete()
        else:
            return False

    def updateEdit(self, outContent):
        self.ui.response.setText(outContent)
        self.ui.sendBtn.setEnabled(True)

    # 点击发送按钮
    def getUrl(self):
        requestUrl = self.ui.urlEdit.text()
        if not requestUrl:
            msgBox = QMessageBox(QMessageBox.Warning, '警告', 'URL不能为空,请检查!')
            msgBox.exec_()
            return 1
        if not re.match(r'https?://.*\..*', requestUrl):
            msgBox = QMessageBox(QMessageBox.Warning, '警告', 'URL输入不合法,请检查!')
            msgBox.exec_()
            return 1

        httpProxy = self.ui.httpProxy.text()
        if httpProxy:
            if not re.match(r'https?://.*\..*', httpProxy):
                msgBox = QMessageBox(QMessageBox.Warning, '警告', 'HTTP代理地址输入不合法,请检查!')
                msgBox.exec_()
                return 1
            else:
                self.setCompleteList(httpProxy)
        # 为Widgets设置补全
        self.setCompleteList(requestUrl)
        requestMethod = self.ui.requestMethod.currentText()

        # 获取消息头表数据
        requestHeaderDict = {}
        if self.ui.requestHeader.rowCount():
            requestHeaderRowCount = self.ui.requestHeader.rowCount()
            for x in range(0, requestHeaderRowCount):
                if not self.ui.requestHeader.item(0,0) == None:
                    requestHeaderDict[self.ui.requestHeader.item(x, 0).text()] = self.ui.requestHeader.item(x, 1).text()

        requestBody = self.ui.requestBody.toPlainText()
        if requestBody:
            try:
                requestBody = eval(requestBody)
            except Exception as e:
                msgBox = QMessageBox(QMessageBox.Warning, '警告', '消息体输入不合法,请检查!')
                msgBox.exec_()
                return 1

        # 开启子线程
        self.thread = NewThread()
        self.thread.url = requestUrl.lstrip().rstrip()
        self.thread.method = requestMethod
        self.thread.headers = requestHeaderDict
        self.thread.data = requestBody
        self.thread.proxies = {
            'http': httpProxy,
            'https': httpProxy,
        }
        self.thread.updateData.connect(self.updateEdit)
        self.thread.start()
        self.ui.sendBtn.setEnabled(False)

    def clearUrl(self):
        self.ui.urlEdit.clear()

    def addTable(self):
        self.ui.requestHeader.insertRow(0)

    def delTable(self):
        self.ui.requestHeader.removeRow(self.ui.requestHeader.currentRow())

if __name__ == '__main__':
    app = QApplication(sys.argv)
    mw = MainWindow()
    mw.show()
    sys.exit(app.exec_())
