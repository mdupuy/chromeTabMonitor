#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! [[ -x "$DIR/chromeMon.sh" ]]; then
    echo "$DIR/chromeMon.sh is not executable or found"
    exit 1
fi

#check for cpulimit and offer to install it with Homebrew
if ! type cpulimit >> /dev/null; then
	osascript -e 'tell app "System Events" to display dialog "'"cpulimit command not installed. Do you wish to install it (via the HomeBrew package manager and Xcode command line tools)?"'" buttons {"Cancel","OK"} default button "Cancel" giving up after "10"' 
	if [ "$?" -eq "0" ]; then
		echo "Installing cpulimit"
		if ! type brew >> /dev/null; then
			echo "Installing homebrew"
			/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		fi
		brew install cpulimit
	fi
fi

#See if we have the latest version and offer to download the newest one
newVersion=$(curl --connect-timeout 2 -s https://raw.githubusercontent.com/mdupuy/chromeTabMonitor/master/chromeMon.sh|fgrep version=|head -n1|cut -d = -f2)
if ! [ -z $newVersion ]; then
	#echo newVersion $newVersion
	myVersion=$(fgrep version= "$DIR/chromeMon.sh"|head -n1|cut -d = -f2)
	if [ "$newVersion" -gt "$myVersion" ]; then 
		echo "Git version $newVersion, my version $myVersion"
		osascript -e 'tell app "System Events" to display dialog "'"There is a new version of ChromeTabMonitor available. Do you wish to download it?"'" buttons {"Cancel","OK"} default button "Cancel" giving up after "10"'
		if [ "$?" -eq "0" ]; then
			open "https://github.com/mdupuy/chromeTabMonitor/archive/master.zip"
		fi
	fi
fi


if [ -z $1 ]; then
        echo "No time interval defined, defaulting to 60 sec"
        timeout=60
else
        timeout=$1
fi

while true; do
        REPLY=
        clear
        echo "Chrome Tab Monitor running every $1 seconds" 
        "$DIR/chromeMon.sh"
        #echo "Press 'q' quit, 'k' end cpulimits, "
        read -t $timeout -p "Press 'q' quit, 'k' end cpulimits, 't' Chrome Task Manager > " -n 1 -r
        echo #newline
        #echo $REPLY

        if [[ $REPLY =~ ^[Qq]$ ]]; then
                #quitting
                break
        elif [[ $REPLY =~ ^[Kk]$ ]]; then
                "$DIR/chromeMon.sh" k
        elif [[ $REPLY =~ ^[Tt]$ ]]; then
                osascript -e 'activate application "Google Chrome"' \
                -e 'tell application "System Events"' \
                        -e 'tell process "Google Chrome"' \
                                -e 'key code 53 using {shift down, control down}' \
                        -e 'end tell' \
                -e 'end tell'
        fi                             
done

exit 0
