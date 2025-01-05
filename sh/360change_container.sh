#!/bin/bash
get_container_index() {
    docker_yml=$1
    container=$2
    #source_str=$(cat $docker_yml|grep -E '^[\ ]{2,4}[a-z0-9-]+:$')
    source_str="lcs: nsqd: nsqlookupd: nginx: cactus-mysql: cactus-redis: cactus-mongo: p2p: cactus-cascade: cactus-fdfs: cactus-nginx: cactus-naceng: cactus-clickhouse: cactus-ecbclient: cactus-zdxa: cactus-iam: cactus-mss: networks:"
    n=0
    str_array=
    for i in $source_str
    do
        str_array[$n]=$i
        ((n++))
    done
    #echo ${str_array[@]}

    n=0
    for i in ${str_array[@]}
    do
        #echo $i
        if [ "$i" == "$container" ]
        then
            container_index=$n
            break
        fi
        ((n++))
    done
    container_next=${str_array[$((n+1))]}
    #echo $container_next

}

change_container() {
    if [ $# -lt 1 ]
    then
        echo args input error...
        return 1
    fi
    docker_yml="/home/s/lcsd/docker-compose.yml"
    cp -f $docker_yml $docker_yml.$(date +%Y%m%d%H%M%S)
    if [ ! -f $docker_yml ]
    then
        echo Not found yml config...
        return 1
    fi
    flag=0
    flag_down=0
    image_path=./alpine-3.17.2.tar
    for name in $@
    do
        echo -----------------------------------
        container_name="$name:"
        line_current_container=
        line_current_container=$(cat $docker_yml|grep -E "^[\ ]*${container_name}$" -n|awk -F: '{print $1}')
        if [ -z ${line_current_container} ]
        then
            echo current container name : [$name]
            echo Not found container,check input please...
            continue
        fi
        if [ $flag_down -eq 0 ]
        then
            docker load -i $image_path
            docker-compose -f $docker_yml down
            flag_down=1
        fi
        echo current container name : [$name]
        echo container_name line : [$line_current_container]
        get_container_index $docker_yml "$container_name"
        line_next_container=
        if [ -z ${container_next} ]
        then
            line_next_container=$((line_current_container+50))
        else
            line_next_container=$(cat $docker_yml|grep -m 1 -E ".*${container_next}$" -n|awk -F: '{print $1}')
        fi
        echo change line : [$line_current_container - $line_next_container]
        mv /data/docker/$name /data/docker/$name.$(date +%Y%m%d%H%M%S) >/dev/null
        sed -i "$line_current_container,$((line_next_container-1)) {s/^/#/}" $docker_yml
        sed -i "${line_current_container}i #\n    ${name}:\n        image: alpine:3.17.2\n        container_name: ${name}\n        tty: true\n" $docker_yml
        flag=1
    done
    if [ $flag -eq 1 ]
    then 
        docker-compose -f $docker_yml up -d
    fi
    echo docker-compose change complete.
}

change_container "$@"