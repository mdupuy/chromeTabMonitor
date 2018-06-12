#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ! [[ -x "$DIR/chromeMon.sh" ]]; then
    echo "$DIR/chromeMon.sh is not executable or found"
    exit 1
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
