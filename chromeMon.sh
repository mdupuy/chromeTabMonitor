#!/bin/bash

numberOfChromePIDsToWatch=4
cpuThreshold=80
#userInputTimeout=10
lastRun=/tmp/chromePIDListLastRun

if [ $1 ]; then
	echo "setting cpuThreshold to $1%"
	cpuThreshold=$1
fi

list=$(ps -rA -o %cpu -o pid,command| fgrep "Google Chrome"|head -n$numberOfChromePIDsToWatch | awk '{print $1 " " $2 }')

for((i=1; $i < $(($numberOfChromePIDsToWatch * 2 + 1)); i++)); do
	#get the cpu percentage and chop off the decimal
	cpu=$(echo $list| cut -d ' ' -f$i| cut -d '.' -f1)
	i=$(($i+1))
	pid=$(echo $list| cut -d ' ' -f$i)
	#echo cpu $cpu pid $pid
	if [ $cpu -gt $cpuThreshold ]; then
		pidList="$pid $pidList"
		#echo $pidList
	fi
done

headProcessPID=$(pgrep Google Chrome.app|head -n1)

for pid in $pidList; do
	if [ $pid -eq $headProcessPID ];then
		echo "Killing $pid would kill all of Chrome, nope"
		continue
	fi
	if grep -q $pid $lastRun; then
		#read -t $userInputTimeout -p "$pid came up last run, too. Kill it? [y/n] " -n 1 -r
		#echo    # (optional) move to a new line

                osascript -e 'tell application "System Events"' \
                -e 'set frontmostApplicationName to name of 1st process whose frontmost is true' \
                -e 'end tell' \
                -e 'tell app "System Events" to display dialog "'"Chrome PID ${pid//\"/\\\"} over ${cpuThreshold//\"/\\\"}%. Kill it?"'" buttons {"Cancel","OK"} default button "OK" giving up after 9' \
                -e 'tell application frontmostApplicationName' \
                -e 'activate' \
                -e 'end tell'
		if [ $? -eq 0 ]; then
			REPLY=y
		fi

		if [[ $REPLY =~ ^[Yy]$ ]]; then
			# do dangerous stuff
			if [ $pid -eq $headProcessPID ];then
				echo "Killing $pid would kill all of Chrome, nope"
			else
				kill $pid
			fi
		fi
	fi
done

echo $pidList > $lastRun

exit 0
