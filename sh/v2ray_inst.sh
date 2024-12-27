#!/bin/bash


function inst_v2ray() {
    ufw allow 26889
    ufw status
    curl -0 https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh|bash
}


function write_json() {

    if [ -f /usr/local/etc/v2ray/config.json ]
    then
        mv /usr/local/etc/v2ray/config.json /usr/local/etc/v2ray/config.json.bak
    fi

cat>/usr/local/etc/v2ray/config.json <<EOF


{
"log":{
    "loglevel":"debug",
    "access":"var/log/v2ray/access.log",
    "error":"var/log/v2ray/error.log"
},
"inbounds":[
    {
    "port":"26889",
    "protocol":"vmess",
    "settings":{
        "clients": [
        {
            "id": "1919982e-4bd6-46db-2bca-d98c3f5806b7",
            "alterid": 0
        }
        ]
    }
    }
],

"outbounds": [
    {
    "protocol": "freedom",
    "settings": {},
    "tag": "black"
    }
],

"routing":{
    "rules":[
    {
        "type":"field",
        "outboundTag":"black",
        "domain":[
        "domain:pass.pass"
        ]
    }
    ]
}

}

EOF


}


function main() {
    echo start install v2ray...
    inst_v2ray
    echo write config...
    write_json
    systemctl enable v2ray
    systemctl stop v2ray
    systemctl start v2ray
    systemctl status v2ray
    ss -antpl
}

main