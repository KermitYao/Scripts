# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'httpInterface.ui'
#
# Created by: PyQt5 UI code generator 5.15.4
#
# WARNING: Any manual changes made to this file will be lost when pyuic5 is
# run again.  Do not edit this file unless you know what you are doing.


from PyQt5 import QtCore, QtGui, QtWidgets


class Ui_Http(object):
    def setupUi(self, Http):
        Http.setObjectName("Http")
        Http.resize(784, 643)
        self.verticalLayout_2 = QtWidgets.QVBoxLayout(Http)
        self.verticalLayout_2.setObjectName("verticalLayout_2")
        self.groupBox = QtWidgets.QGroupBox(Http)
        self.groupBox.setObjectName("groupBox")
        self.horizontalLayout_2 = QtWidgets.QHBoxLayout(self.groupBox)
        self.horizontalLayout_2.setObjectName("horizontalLayout_2")
        self.requestMethod = QtWidgets.QComboBox(self.groupBox)
        self.requestMethod.setObjectName("requestMethod")
        self.requestMethod.addItem("")
        self.requestMethod.addItem("")
        self.requestMethod.addItem("")
        self.requestMethod.addItem("")
        self.horizontalLayout_2.addWidget(self.requestMethod)
        self.urlEdit = QtWidgets.QLineEdit(self.groupBox)
        self.urlEdit.setObjectName("urlEdit")
        self.horizontalLayout_2.addWidget(self.urlEdit)
        self.clearBtn = QtWidgets.QPushButton(self.groupBox)
        self.clearBtn.setObjectName("clearBtn")
        self.horizontalLayout_2.addWidget(self.clearBtn)
        self.sendBtn = QtWidgets.QPushButton(self.groupBox)
        self.sendBtn.setObjectName("sendBtn")
        self.horizontalLayout_2.addWidget(self.sendBtn)
        self.verticalLayout_2.addWidget(self.groupBox)
        self.groupBox_2 = QtWidgets.QGroupBox(Http)
        self.groupBox_2.setObjectName("groupBox_2")
        self.verticalLayout = QtWidgets.QVBoxLayout(self.groupBox_2)
        self.verticalLayout.setObjectName("verticalLayout")
        self.horizontalLayout = QtWidgets.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.label = QtWidgets.QLabel(self.groupBox_2)
        self.label.setObjectName("label")
        self.horizontalLayout.addWidget(self.label)
        self.addTableBtn = QtWidgets.QPushButton(self.groupBox_2)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Minimum, QtWidgets.QSizePolicy.Fixed)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.addTableBtn.sizePolicy().hasHeightForWidth())
        self.addTableBtn.setSizePolicy(sizePolicy)
        self.addTableBtn.setBaseSize(QtCore.QSize(0, 0))
        font = QtGui.QFont()
        font.setPointSize(15)
        font.setBold(True)
        font.setWeight(75)
        self.addTableBtn.setFont(font)
        self.addTableBtn.setObjectName("addTableBtn")
        self.horizontalLayout.addWidget(self.addTableBtn)
        self.delTableBtn = QtWidgets.QPushButton(self.groupBox_2)
        font = QtGui.QFont()
        font.setPointSize(15)
        font.setBold(True)
        font.setWeight(75)
        self.delTableBtn.setFont(font)
        self.delTableBtn.setObjectName("delTableBtn")
        self.horizontalLayout.addWidget(self.delTableBtn)
        spacerItem = QtWidgets.QSpacerItem(40, 20, QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Minimum)
        self.horizontalLayout.addItem(spacerItem)
        spacerItem1 = QtWidgets.QSpacerItem(40, 20, QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Minimum)
        self.horizontalLayout.addItem(spacerItem1)
        spacerItem2 = QtWidgets.QSpacerItem(40, 20, QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Minimum)
        self.horizontalLayout.addItem(spacerItem2)
        spacerItem3 = QtWidgets.QSpacerItem(40, 20, QtWidgets.QSizePolicy.Fixed, QtWidgets.QSizePolicy.Minimum)
        self.horizontalLayout.addItem(spacerItem3)
        self.label_3 = QtWidgets.QLabel(self.groupBox_2)
        self.label_3.setObjectName("label_3")
        self.horizontalLayout.addWidget(self.label_3)
        self.httpProxy = QtWidgets.QLineEdit(self.groupBox_2)
        self.httpProxy.setObjectName("httpProxy")
        self.horizontalLayout.addWidget(self.httpProxy)
        self.verticalLayout.addLayout(self.horizontalLayout)
        self.gridLayout = QtWidgets.QGridLayout()
        self.gridLayout.setObjectName("gridLayout")
        self.line = QtWidgets.QFrame(self.groupBox_2)
        self.line.setFrameShape(QtWidgets.QFrame.VLine)
        self.line.setFrameShadow(QtWidgets.QFrame.Sunken)
        self.line.setObjectName("line")
        self.gridLayout.addWidget(self.line, 0, 2, 1, 1)
        self.verticalLayout_3 = QtWidgets.QVBoxLayout()
        self.verticalLayout_3.setObjectName("verticalLayout_3")
        self.label_2 = QtWidgets.QLabel(self.groupBox_2)
        sizePolicy = QtWidgets.QSizePolicy(QtWidgets.QSizePolicy.Preferred, QtWidgets.QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(1)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.label_2.sizePolicy().hasHeightForWidth())
        self.label_2.setSizePolicy(sizePolicy)
        self.label_2.setObjectName("label_2")
        self.verticalLayout_3.addWidget(self.label_2)
        self.requestBody = QtWidgets.QTextEdit(self.groupBox_2)
        self.requestBody.setObjectName("requestBody")
        self.verticalLayout_3.addWidget(self.requestBody)
        self.gridLayout.addLayout(self.verticalLayout_3, 0, 3, 1, 1)
        self.requestHeader = QtWidgets.QTableWidget(self.groupBox_2)
        self.requestHeader.setObjectName("requestHeader")
        self.requestHeader.setColumnCount(2)
        self.requestHeader.setRowCount(0)
        item = QtWidgets.QTableWidgetItem()
        self.requestHeader.setHorizontalHeaderItem(0, item)
        item = QtWidgets.QTableWidgetItem()
        self.requestHeader.setHorizontalHeaderItem(1, item)
        self.requestHeader.horizontalHeader().setStretchLastSection(True)
        self.gridLayout.addWidget(self.requestHeader, 0, 1, 1, 1)
        self.verticalLayout.addLayout(self.gridLayout)
        self.verticalLayout_2.addWidget(self.groupBox_2)
        self.groupBox_3 = QtWidgets.QGroupBox(Http)
        self.groupBox_3.setObjectName("groupBox_3")
        self.horizontalLayout_3 = QtWidgets.QHBoxLayout(self.groupBox_3)
        self.horizontalLayout_3.setObjectName("horizontalLayout_3")
        self.response = QtWidgets.QTextEdit(self.groupBox_3)
        self.response.setObjectName("response")
        self.horizontalLayout_3.addWidget(self.response)
        self.verticalLayout_2.addWidget(self.groupBox_3)

        self.retranslateUi(Http)
        self.clearBtn.clicked.connect(Http.clearUrl)
        self.sendBtn.clicked.connect(Http.getUrl)
        self.addTableBtn.clicked.connect(Http.addTable)
        self.delTableBtn.clicked.connect(Http.delTable)
        QtCore.QMetaObject.connectSlotsByName(Http)

    def retranslateUi(self, Http):
        _translate = QtCore.QCoreApplication.translate
        Http.setWindowTitle(_translate("Http", "Form"))
        self.groupBox.setTitle(_translate("Http", "输入流"))
        self.requestMethod.setItemText(0, _translate("Http", "GET"))
        self.requestMethod.setItemText(1, _translate("Http", "POST"))
        self.requestMethod.setItemText(2, _translate("Http", "PUT"))
        self.requestMethod.setItemText(3, _translate("Http", "DELETE"))
        self.urlEdit.setPlaceholderText(_translate("Http", "请输入URL"))
        self.clearBtn.setText(_translate("Http", "清空"))
        self.sendBtn.setText(_translate("Http", "发送"))
        self.groupBox_2.setTitle(_translate("Http", "参数流"))
        self.label.setText(_translate("Http", "请求头:"))
        self.addTableBtn.setText(_translate("Http", "+"))
        self.delTableBtn.setText(_translate("Http", "-"))
        self.label_3.setText(_translate("Http", "HTTP 代理:"))
        self.label_2.setText(_translate("Http", "请求体:"))
        self.requestBody.setPlaceholderText(_translate("Http", "请输入消息体，例：{\'wd\':\'test\'}"))
        item = self.requestHeader.horizontalHeaderItem(0)
        item.setText(_translate("Http", "属性"))
        item = self.requestHeader.horizontalHeaderItem(1)
        item.setText(_translate("Http", "值"))
        self.groupBox_3.setTitle(_translate("Http", "输出流"))
