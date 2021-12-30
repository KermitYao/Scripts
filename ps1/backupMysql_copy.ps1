<#
    停止 eei 服务并备份 mysql

    遵守如下约定:
        脚本放在  mysql 服务器执行
        认为mysql 服务器为控制端
        认为eei 服务器为被控端
        默认所有地址为ip地址，而非计算机名称； 当然也可以使用  FQDN 替代ip地址

    1. eei服务器开启winrm ： enable-psremoting -force
	    当网络位置为公用网络是，还应该设置如下策略:
		Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any

	    查看状态：Get-Service WinRM

    2. 控制端需要添加被控端ip到本机信任列表：
        添加信任：Set-Item WSMan:localhost\client\trustedhosts -value 被控端ip地址 -Force
    
    3. 测试控制端到被控端是否能连通:
       测试命令： Invoke-Command  -Credential administrator -computername 被控端ip地址 -scriptblock {get-service}
       此命令将会弹出一个认证凭据窗口，输入你的用户名和密码，需要拥有管理员权限，如果是域用户，应该使用域管理账户替代。

    4. 如果明文将密码保存在脚本中会有很大的安全隐患,通过参数来生成安全的密钥用于代替密码；此密钥只能在当前系统使用，复制到别的计算机将会失效。
        生成密钥: ./backupMysql.ps1 mkpw
        之后将密钥填入 $eei_sys_secure_passwd 变量中

    5.测试脚本实际运行情况
        启用单步测试: powershell -file ./backupMysql.ps1 test

    6.设置计划任务运行脚本
        此计划任务将会运行脚本，并且输出日志到 c:\backupmysql.log
        计划任务执行命令： powershell -file ./backupMysql.ps1 >>"c:\backupmysql.log"
#>

#--------user var----------

#[EEI SERVER]

$eei_host = '192.168.30.101'
$eei_sys_username = 'administrator'
$eei_sys_secure_passwd = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000b7d3f2a3d1f0384a8b6e714a4a2400fe0000000002000000000010660000000100002000000075ac47cbb38d411e20122a3e98f9984cdeca393116072b3ee3d5b9561e33c23e000000000e800000000200002000000074dd261d1a778d770405ec6de91dc2dca02454c8c0d2b8616cdfa3f1a45d10a8200000007153b0c1b85510cbd4d0d0124f27e43fa966e7e6a95a44da3ff7679ef18b864c400000002da99cff0b4ae11b05568033f51f0c9887f78fccb4828919d13bcc0385b50bed2233c95af3d01ee4ad444a4ce4be516cfabd030d8fc40ab24675545f4d14c9cb"
$eei_service_name='EIServerSvc'

#[MYSQL SERVER]
$mysql_service_name="mysql_eset"
$mysql_database_dir="C:\eset\mysql-8.0.26-eset\data\enterpriseinspectordb"
$backup_dir="c:\backup"


#--------user var----------

#--------sys var----------

$service_wait=3
$formatDate=get-date -format 'yyyyMMddHHmm'
$mysql_database_name=$mysql_database_dir.Split('\')[-1]
$backup_file="$backup_dir\${mysql_database_name}_${formatDate}"
if (! [io.Directory]::Exists(${backup_dir})){
    $newDir=New-Item -ItemType "directory" -path $backup_dir
}

#--------sys var----------

#--------function----------
#创建安全的密码字符串
function make-SecurityPasswd()
{
    $securityPasswd = Read-Host "Enter Password" -AsSecureString | ConvertFrom-SecureString
    Set-Clipboard $securityPasswd
    $securityPasswdLength = (convertTo-SecureString $securityPasswd).Length
    Write-Output $securityPasswd
    Write-Output "安全密码以复制到剪切板, 原始密码长度: ${securityPasswdLength}"
     
}

function get-status {

    try {
        $svr_object = Invoke-Command -ComputerName $eei_host -Credential $Cred -ArgumentList $eei_service_name -ScriptBlock {
            param($eei_service_name)
            get-Service $eei_service_name
            }
        if ($svr_object.name -eq "$eei_service_name"){
            if ($svr_object.status -eq "Running") {
                return "Running"
            } else {
                return "Stoppend"
            }
        } else {
            Write-Output "未获取到状态信息,可能此 [$eei_service_name] 服务不存在,退出脚本."
            exit 1
        }
    }
    catch {
        Write-Output "有一个未知的错误: [$Error]"
    }

}
#--------function----------

if ($args[0] -eq 'mkpw') {
    make-SecurityPasswd
    exit 0
}

#创建安全凭据对象
$Cred = New-Object -TypeName System.Management.Automation.PSCredential `
          -ArgumentList $eei_sys_username, ($eei_sys_secure_passwd | ConvertTo-SecureString)


if ($args -eq "test") {Read-Host "启用单步测试模式,按回车键继续"}

Write-Output " -- $eei_service_name 当前状态: [$(get-status)]"
if ($args -eq "test") {Read-Host "确认 EEI 服务器确认服务状态是否一致"}

if ($(get-status) -eq "Running") {
    Write-Output " -- 停止 $eei_service_name 服务..."
    $svr_object = Invoke-Command -ComputerName $eei_host -Credential $Cred -ArgumentList $eei_service_name -ScriptBlock {
        param($eei_service_name)
        Stop-Service $eei_service_name
        }
}

Write-Output " -- $eei_service_name 当前状态: [$(get-status)]"
if ($args -eq "test") {Read-Host "确认 EEI 服务器确认服务状态是否为 : [Stoppend]"}

Start-Sleep 3
if ($(get-status) -eq "Running") {
    Write-Output " -- 无法停止 [$eei_service_name] 服务,停止备份."
    exit 2
}


Write-Output " -- 停止 ${mysql_service_name}"
Stop-Service ${mysql_service_name}
if ($args -eq "test") {Read-Host "确认 MYSQL 服务器确认服务状态是否为 : [Stoppend]"}
$mysqlSvrStatus=(get-service $mysql_service_name).Status
Start-Sleep $service_wait
if (${mysqlSvrStatus} -eq "Stopped") {
    if ($args -eq "test") {
        write-output "Copy-item  -Path ${mysql_database_dir} -Destination ${backup_file} -Force -Recurse"
        Read-Host "确认 mysql 备份信息是否正确"
    } else {
        Copy-item  -Path ${mysql_database_dir} -Destination ${backup_file} -Force -Recurse
    }
} else {
    Write-Output "无法停止 ${mysql_service_name} 服务,停止备份"
    exit 3
}


Start-Sleep $service_wait

if ( Test-Path $backup_file) {
    Write-Output " -- 备份已完成."
} else {
    Write-Output " -- 未找到备份文件,备份失败."
}

Write-Output " -- 启动 ${mysql_service_name} 服务..."
Start-Service ${mysql_service_name}
Start-Sleep $service_wait
$mysqlSvrStatus=(get-service $mysql_service).Status
if ($args -eq "test") {Read-Host "确认 EEI 服务器确认服务状态是否为 : [Running]"}
if (${mysqlSvrStatus} -eq "Running") {
    Write-Output " -- 启动 [$mysql_service_name] 服务完成."
} else {
    Write-Output " -- 启动 [$mysql_service_name] 服务失败."
    exit 4
}

Write-Output " -- 启动 $eei_service_name 服务..."
$svr_object = Invoke-Command -ComputerName $eei_host -Credential $Cred -ArgumentList $eei_service_name -ScriptBlock {
    param($eei_service_name)
    start-Service $eei_service_name
}

if ($args -eq "test") {Read-Host "确认 EEI 服务器确认服务状态是否为 : [Running]"}
Start-Sleep 3

if ($(get-status) -eq "Running") {
    Write-Output " -- 启动 [$eei_service_name] 服务完成."
} else {
    Write-Output " -- 启动 [$eei_service_name] 服务失败."
    exit 5
}

Get-Date
if ($args -eq "test"){read-host "测试完成,然后按回车间继续"}
exit 0

