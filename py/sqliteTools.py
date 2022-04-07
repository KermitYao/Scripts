#!/bin/python3
import sqlite3
import time

class SqliteTools():
    def __init__(self):
        self.dbName='test.db'
        self.tableName='test'
        self.connectSqlite = sqlite3.connect(self.dbName)
        self.cursor = self.connectSqlite.cursor()

    def execute(self, sqliteCmd):
        self.cursor.execute(sqliteCmd)
        self.connectSqlite.commit()

    def createTable(self):
        createTableCmd='''
        CREATE TABLE IF NOT EXISTS {0}(
            id INTEGER PRIMARY KEY  NOT NULL, 
            name TEXT  NOT NULL, 
            time TEXT, 
            url TEXT, 
            content TEXT
            )
        '''.format(db.tableName)
        self.execute(createTableCmd)

    def dropTable(self):
        dropTableCmd='DROP TABLE IF EXISTS {0}'.format(self.tableName)
        self.execute(dropTableCmd)

    def close(self):
        self.cursor.close()
        self.connectSqlite.close()

#格式化时间
def formatTime(times,type=1):
    if times != None:
        m=time.localtime(float(times))
        tm={'year':m.tm_year,
            'mon':m.tm_mon,
            'mday':m.tm_mday,
            'hour':m.tm_hour,
            'min':m.tm_min,
            'sec':m.tm_sec,
        }
        for v in tm:
            if tm[v]<10:
                tm[v]='0'+str(tm[v])
            else:
                tm[v]=str(tm[v])
        if type == 1:
            m='{}-{}-{} {}:{}:{}'.format(tm['year'],tm['mon'],tm['mday'],tm['hour'],tm['min'],tm['sec'])
        elif type == 2:
            m='{}{}{}{}{}{}'.format(tm['year'],tm['mon'],tm['mday'],tm['hour'],tm['min'],tm['sec'])
        elif type == 3:
            m='{}-{}-{}'.format(tm['year'],tm['mon'],tm['mday'])
        return m
    return None

if __name__ == '__main__':
    db = SqliteTools()
    dbCmd = 'select * from test'
    dbInsert = 'INSERT INTO test ("name", "time", "url", "content") VALUES ("{0}", "{1}","{2}","{3}" )'.format("", formatTime(time.time()), "https://yjyn.top:1443", "abcdefg")
    dbSelect = 'select name from test where name="jianyu.yao"'
    db.createTable()
    #db.execute(dbInsert)
    db.execute(dbSelect)
    print(len(db.cursor.fetchall()))
    db.close()