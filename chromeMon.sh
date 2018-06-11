#!/bin/bash

numberOfChromePIDsToWatch=4
cpuThreshold=80
userInputTimeout=10
cpulimit=2
lastRun=/tmp/chromePIDListLastRun
cpulimitList=/tmp/cpulimitChromeMon


if [ $1 ]; then
	if [ "$1" -eq "$1" ] 2>/dev/null; then
		#echo number
		echo "setting cpuThreshold to $1%"
		cpuThreshold=$1
	elif [ "$1" == "k" ]; then
		#echo not a number, this is a kill command
		echo "removing all cpulimits"
		chromePIDs=$(pgrep Chrome)
		ps A |grep [c]pulimit > $cpulimitList
		for pid in $chromePIDs; do 
			limitPID=$(fgrep $pid $cpulimitList | awk '{print $1}')
			if [ ! -z $limitPID ]; then
				echo killing $limitPID
				kill $limitPID
			fi
		done
		rm $cpulimitList
		exit 0
	else
		echo "valid arguments are a number for the cpuThreshold or 'k' to kill cpulimits"
		exit 1
	fi
fi

os=$(uname -s)
if [ "$os" == "Darwin" ]; then 
	list=$(ps -rA -o %cpu -o pid,command|grep [G]oogle\ Chrome|head -n$numberOfChromePIDsToWatch | awk '{print $1 " " $2 }')
else
#elif [ "$os" == "Linux" ]; then
	list=$(ps -A -o %cpu,pid,command --sort -%cpu|grep [G]oogle\ Chrome|head -n$numberOfChromePIDsToWatch | awk '{print $1 " " $2 }')
fi

if [ -z "$list" ]; then
	#echo "Chrome not running"
	exit 0
fi

for((i=1; $i < $(($numberOfChromePIDsToWatch * 2 + 1)); i++)); do
	#get the cpu percentage and chop off the decimal
	cpu=$(echo $list| cut -d ' ' -f$i| cut -d '.' -f1)
	if [ -z "$cpu" ]; then
		#echo "no more tabs"
		break
	fi
	i=$(($i+1))
	pid=$(echo $list| cut -d ' ' -f$i)
	echo "Process ID: $pid	CPU $cpu%"
	if [ $cpu -gt $cpuThreshold ]; then
		pidList="$pid $pidList"
		#echo $pidList
	fi
done

headProcessPID=$(pgrep -oi Google Chrome)

for pid in $pidList; do
	if [ $pid -eq $headProcessPID ];then
		#echo "Killing $pid would kill all of Chrome, nope"
		continue
	fi
	if grep -q $pid $lastRun; then

		# On a Mac? Let's pop up a nice dialogue box
		if type osascript >> /dev/null; then
                	osascript -e 'tell application "System Events"' \
                	-e 'set frontmostApplicationName to name of 1st process whose frontmost is true' \
                	-e 'end tell' \
                	-e 'tell app "System Events" to display dialog "'"Chrome PID ${pid//\"/\\\"} over ${cpuThreshold//\"/\\\"}%. Kill or cpulimit it?"'" buttons {"Cancel","OK"} default button "OK" giving up after "'"$userInputTimeout"'"' \
                	-e 'tell application frontmostApplicationName' \
                	-e 'activate' \
                	-e 'end tell'
			if [ $? -eq 0 ]; then
				REPLY=y
			fi
		else  #not on a Mac? Prompt the user in the terminal
			read -t $userInputTimeout -p "$pid came up last run, too. Kill it? [y/n] " -n 1 -r
			if [ "$?" -ne "0" ]; then
				REPLY=y
			fi
			echo  #move to a new line
		fi

		if [[ $REPLY =~ ^[Yy]$ ]]; then
			if type cpulimit >> /dev/null; then
				cpulimit --pid $pid --limit $cpulimit&
				echo "Throttling $pid to $cpulimit%"
			else
				echo "Killing $pid"
				kill -15 $pid
			fi
		fi
	fi
done

ps A|grep [c]pulimit |cut -d ' ' -f2-20
echo $pidList > $lastRun

exit 0
