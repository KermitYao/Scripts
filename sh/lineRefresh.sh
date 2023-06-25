#!/bin/bash

print_status() {
	echo -e "\e[34m Blue this is line: $1   "
	echo -e "this is line: $1+1"
	echo -e "this is line: $1+2"

}

for i in $(seq 1 30)
do
	print_status $i
	sleep 0.3
	if [ $i -eq 30 ]
	then
		echo ok
	else
		printf "\033[3A" 
	fi
done

echo -e "\e[39m"
