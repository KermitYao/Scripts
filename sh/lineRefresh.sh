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
		#\033 = 十六位控制码 ascll esc控制码
		<<COMMENT
			\33[0m 关闭所有属性 
			\33[1m 设置高亮度 
			\33[4m 下划线 
			\33[5m 闪烁 
			\33[7m 反显 
			\33[8m 消隐 
			\33[30m -- \33[37m 设置前景色 
			\33[40m -- \33[47m 设置背景色 
			\33[nA 光标上移n行 
			\33[nB 光标下移n行 
			\33[nC 光标右移n行 
			\33[nD 光标左移n行 
			\33[y;xH设置光标位置 
			\33[2J 清屏 
			\33[K 清除从光标到行尾的内容 
			\33[s 保存光标位置 
			\33[u 恢复光标位置 
			\33[?25l 隐藏光标 
			\33[?25h 显示光标

			echo -e
			printf
		COMMENT
		printf "\033[3A" 
	fi
done

echo -e "\e[39m"
