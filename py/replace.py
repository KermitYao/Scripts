#!/bin/python3

import os,sys,re

def replaceContent(path,keyDict):
    with open(path, 'r',encoding='utf-8') as f:
        allLines=f.readlines()
    with open(path, 'w+',encoding='utf-8') as f:
        n=0
        for line in allLines:
            n+=1
            print("\r\t当前进度: %s/%s 行, 文档: %s" % (n, len(allLines), path) ,end='')
            content=line
            for key in keyDict:
                #print("替换:%s, 到: %s" % (keyDict[key], key))
                content=re.sub(keyDict[key],key,content)
            f.writelines(content)
        print("\n")
    return True

def main(path):
    pattern=r"(.html|.js)$"
    keyDict={
        'Vulnerability risk statistics':'漏洞风险统计',
        'Asset risk statistics':'资产风险统计',
        'Service risk statistics':'服务风险统计',
        'audit report':'审计报告',
        'Task Ovverview':'任务概述',
        'Risk statistics':'风险统计',
        'Operating System Risk Statistics':'操作系统风险统计',
        '01.Operating system details':'01.操作系统详细',
        '02.Service details':'02. 服务详细',
        '03.Asset Details':'03. 资产详细',
        '04.Vulnerability details':'04. 漏洞详细',
        '4、Summary':'四、总结',
        'Low risk':'低危',
        'Medium risk':'中危',
        'high risk':'高危',
        'Safe':'安全',
        'Total number of vulnerabilities':'总漏洞数',
        'Number of assets':'资产数',
        'Certification status':'认证状态',
        'No authentication':'无认证',
        'Not supported':'不支持',
        '1. Scanning time':'1. 扫描时间',
        '2. Scan results':'2. 扫描结果',
        '3. Scanning distribution':'3. 漏洞分布',
        'detailed':'详细',
        'summary':'总结',
        'host information':'主机信息',
        'service information':'服务信息',
        'sNumber of services':'服务数量',
        'Custom reports':'自定义报告',
        'Report name':'报表名称',
        'Complete':'完成', 
        'Repor personnel':'报告人员',
        'Date':'日期',
        'Report type':'报表类型',
        '1.Task':'1. 任务',
        'Task name':'任务名称',
        'Scan status':'扫描状态',
        'Scan template':'扫描模板',
        'Execution method':'执行方式',
        'Now start':'立即执行',
        'Take time':'耗时',
        'Targets':'扫描目标',
        'Exclude targets':'排除目标',
        'Start time':'开始时间',
        'End time':'结束时间',
        '2.Summary':'2. 汇总',
        ' Number of vulnerabilities':'漏洞数量',
        'Asset statistics':'资产统计',
        'Hight risk':'高危',
        'Moderate risk':'中危',
        'Low risk':'低危',
        'Security':'安全',
        'Total':'合计',
        'Service list':'服务列表',
        'Operating System Statistics':'操作系统统计',
        'Number of assets':'资产数量',
        'Please enter the vulnerability name to query':'请输入要查询的漏洞名称',
        'Name':'名称',
        'Operating System':'操作系统',
        '3. Detailed':'3. 详细',
        'ID':'序号',
        'Product':'所属产品',
        'Supplier':'供应商',
        'Version':'版本',
        '03 Asset List':'03资产列表',
        'Risk level':'风险等级',
        'Port':'端口',
        'Please select':'请选择',
        'Device Type':'设备类型',
        'unknown':'未知',
        'Manager':'管理程序',
        'Route':'路由器',
        '4.Summary':'4.总结',
        'Impact assets':'影响资产',
        'Solution':'解决方案',
        'Host report':'主机报表',
        'Service information':'2. 服务信息',
        'MAC address':'MAC 地址',
        '1.Host information':'1. 主机信息',
        'Number of service ':'服务数量',
        'Vulnerability Details':'漏洞详情',
        'Evidence list':'证据列表',
        'Reference information list':'参考信息列表',
        'Describe':'描述',
        'Category':'类别',
        'Evidence':'证据',
        'Source':'来源'
        }
    print("\t扫描目录:%s \n\t替换的文件类型:%s\n\t替换的关键字:%s \n" % (path, pattern, keyDict))
    print('\n')
    for r,d,f in os.walk(path):
        #print("r:%s, d:%s, f:%s" % (r,d,f))
        for name in f:
            if re.search(pattern, name):
                fullPath=os.path.join(r,name)

                replaceContent(fullPath,keyDict)
    return



if __name__ == '__main__':
    main(sys.argv[1])