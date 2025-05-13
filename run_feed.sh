#!/bin/bash
# 功能: 同时回放多个信号
# 使用方式：./run_feed.sh user task ip num -> 使用人名称 所属任务名称 设备ip 最大并发数
# eg. ./run_feed.sh user1 testEngine 192.168.85.239 5  -> 解释: user1这个用户，为了测试引擎，给85.239这个ip，同时回放5个信号
# 待办
# ---------- 修改feed.py 生成的命令里带user + task,方便pkill

# 配置目录,不带/
xinhao=/home/xinhao
echo "配置目录=========== $xinhao ,看看目录对不对 ！！！"
echo "配置目录=========== $xinhao ,看看目录对不对 ！！！"
echo "配置目录=========== $xinhao ,看看目录对不对 ！！！"

# 变量
cmd=$1
user=$2
task=$3
ip=$4
num=$5

# 封装start函数
start_feed() {
	# 变量
	local user=$1
	local task=$2
	local ip=$3
	local num=$4
	
	# 定义5个命令
	cmds=(
		#echo "date"
		#echo "ll"
		#echo "df -h"

		"./feed_with_user_task.py -i $ip -d $xinhao/433M/433/459/ -ut '$user $task' &"
		"./feed_with_user_task.py -i $ip -d $xinhao/900M/AEE_F100_900/drone/ -ut '$user $task' &"
		"./feed_with_user_task.py -i $ip -d $xinhao/1400M/入云龙1550/1440_28ms_2/ -ut '$user $task' &"
		"./feed_with_user_task.py -i $ip -d $xinhao/2400M/DJI\(大疆\)\(报文\)-Air_2S/2412.5-20M/ -p 8001 -ut '$user $task' &"
		"./feed_with_user_task.py -i $ip -d $xinhao/5800M/X7Pro/5800/5180/ -ut '$user $task' &"
	)
	
	# 判断变量不为空，否则退出程序
	if [[ -z "$user" || -z "$task" || -z "$ip" || -z "$num" ]]; then
		echo "错误：参数不能为空！"
		echo "用法：$0 start <user> <task> <ip> <num>"
		echo "用法：$0 stop <user task>"
		exit 1
	fi
	# 检查 num 是否为数字（可选）
	if ! [[ "$num" =~ ^[1-5]+$ ]]; then
		echo "错误：num 必须是一个数字[1-5]！"
		exit 1
	fi

	if [[ $num =~ ^[1-5]$ ]];then
		for ((i=0;i<$num;i++));do
		echo "-------- 传参 ip = $ip"
		echo "执行命令 $((i+1)): ${cmds[i]}"
		eval "${cmds[i]}"
		done
	else
		echo "输入错误,退出"
		exit
	fi
}

# 封装stop函数
stop_feed() {
	local user=$1
	local task=$2
	
	echo "stop 传参 $user $task"
	# 判断变量不为空，否则退出程序
	if [[ -z "$user" || -z "$task" ]]; then
		echo "错误：参数不能为空！"
		echo "用法：$0 stop <user task>"
		exit 1
	fi
	echo "pkill -f '$user $task'"
	pkill -f "$user $task"
}


# 主逻辑
main() {
	# 脚本加权限
	chmod +x feed.py
	chmod +x run_feed.sh
	chmod +x feed_with_user_task.py
	
	case $1 in
		start)
			if [[ $# -ne 5 ]]; then
				echo "错误：参数数量不正确！"
				echo "用法：$0 start <user> <task> <ip> <num>"
				exit 1
			fi
			
			#user=$2
			#task=$3
			#ip=$4
			#num=$5
			
			start_feed "$user" "$task" "$ip" "$num"
			;;
		stop)
			# stop_feed "$@" 这样写错误，传参不对应
			echo "命令行 stop 传参 $user $task"
			stop_feed "$user" "$task"
			;;
		*)
			echo "用法：$0 {start|stop}"
			echo "start: 启动信号回放任务"
			echo "  示例: $0 start user1 testEngine 192.168.85.239 5"
			echo "stop:  停止指定信号回放任务"
			echo "  示例: $0 stop username taskname"
			exit 1
			;;
	esac
}


# 调用,加上￥@,才能确保，传参不丢失
main "$@"