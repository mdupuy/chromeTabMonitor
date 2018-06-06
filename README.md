# chromeTabMonitor
Sometimes chrome tabs get CPU hungry, whether malicious javascript is mining bitcoin or some simple web app memory leaked all over the place after leaving it open a few days (Office365, Google Keep, etc.). This is a very simple bash script that will aid in monitoring runaway Google Tabs on a Mac, Linux and probably Win10 if you have the dev tools with bash installed.

## bash script
You can see the defaults at the top of the file. cpuThreshold is 80% per tab by default but this script will accept one command line arg to change that value. It'll watch the top 4 processes by default. Usually only the main Chrome app and one tab are offensive in my expirience. Feel free to dial this back to "2" or extend it if you want.

I suggest running this once a minute with any mechanism you prefer. If a tab is eating more CPU than your threshold for two runs of this script in a row, you'll be given an option to kill that tab. Most tabs will go over your CPU usage threshold while they render but the page renders should take less than a minute (or whatever interval you choose). Of course, playing any sort of media might run longer. You might want to set the default action to not kill the process after if the user doesn't intervene rather than actively kill it.

On a Mac, the most native (but perhaps unfamiliar) method to do this is making a [launchctl plist](https://www.google.com/search?q=launchctl+that+runs+every+minute) that runs every 60 seconds, putting it in ~/Library/LaunchAgents/  and loading it with

    launchctl load -wF ~/Library/LaunchAgents/some.60second.name.plist

Currently, the script pops up a dialog box on the Mac asking if you want to kill a CPU heavy task. If you hit cancel within 10 seconds, the task will be left alone. If you hit ok or wait 10 seconds, this script will kill that tab. If you're on a non-Mac, it'll just prompt you for a y/n answer. The same timeout and default-to-kill rules apply.

Feature requests? Let me know in the issue tracker.

I've added some very dumb logic so that the initial Chrome parent process isn't ever offered up to die.

Other ways to run this at a given interval from the terminal. Install the watch command, i.e. brew install watch

    watch -n60 path/to/this/script/chromeMon.sh
    
Simple bash

    while true; do chromeMon.sh; sleep 60; done
    
On Linux, using "crontab -e", add the line:

    */1 * * * * path/to/this/script/chromeMon.sh
