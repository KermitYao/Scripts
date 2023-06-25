#!/bin/bash

safeSet() {

    #禁用root远程登录
    printf "禁用root远程登录 "
    if [ -f '/etc/ssh/sshd_config' ]
    then
        cat /etc/ssh/sshd_config|grep '^PermitRootLogin.*no'  >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #关闭DNS反向解析
    printf "关闭DNS反向解析 "
    if [ -f '/etc/ssh/sshd_config' ]
    then
        cat /etc/ssh/sshd_config|grep '^UseDNS.*no' >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i 's/.*UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #开启密码过期时间
    printf "开启密码过期时间 60 天 "
    if [ -f '/etc/login.defs' ]
    then
        cat /etc/login.defs|grep '^PASS_MAX_DAYS.*60' >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i 's/.*PASS_MAX_DAYS.*/PASS_MAX_DAYS 60/g' /etc/login.defs
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #开启密码长度 9 位
    printf "开启密码长度 9 位 "
    if [ -f '/etc/login.defs' ]
    then
        cat /etc/login.defs|grep '^PASS_MIN_LEN.*9' >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i 's/.*PASS_MIN_LEN.*/PASS_MIN_LEN  9/g' /etc/login.defs
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #开启密码尝试次数  3 次
    printf "开启密码尝试次数 3 次 "
    if [ -f '/etc/pam.d/system-auth' ]
    then
        lineNum=$(cat /etc/pam.d/system-auth |grep -n "^auth"|head -n1|awk -F: '{print $1}')
        cat /etc/pam.d/system-auth|grep '^auth.*required.*pam_tally2.so.*' >/dev/null
        if [ $? -ne 0 ]
        then
            sed -i "$lineNum i\auth    required    pam_tally2.so   onerr=fail deny=2 unlock_time=60" /etc/pam.d/system-auth
            if [ $? -ne 0 ]
            then
                echo 失败,配置过程失败.
            else
                echo 成功.
            fi
        else
            echo 成功.
        fi
    else
        echo 失败,配置文件未找到.
    fi

    #新建用户
    cat /etc/passwd|grep "360epp" >/dev/null || useradd 360epp 
    if [ $? -eq 0 ]
    then
        printf '修改密码为： 360Epp1234.'
        echo "360Epp1234." |passwd --stdin 360epp >/dev/null
        if [ $? -eq 0 ]
        then
            echo 成功.
            #添加 sudo 权限
            printf "添加 sudo 权限 "
            if [ -f '/etc/sudoers' ]
            then
                cat /etc/sudoers|grep '^360epp.*ALL=(.*).*' >/dev/null
                if [ $? -ne 0 ]
                then
                    echo '360epp   ALL=(ALL)   ALL' >>/etc/sudoers
                    if [ $? -ne 0 ]
                    then
                        echo 失败,配置过程失败.
                    else
                        echo 成功.
                    fi
                else
                    echo 成功.
                fi
            else
                echo 失败,配置文件未找到.
            fi
        else
            echo 密码修改失败
        fi
    else
        echo 创建用户失败
    fi

}

main () {
    safeSet
}

main