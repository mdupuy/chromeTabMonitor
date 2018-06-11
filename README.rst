chromeTabMonitor
===============================================================================
Sometimes chrome tabs get CPU hungry, whether malicious javascript is mining bitcoin or some simple web app memory leaked all over the place after leaving it open a few days (Office365, Google Keep, etc.). This is a very simple bash script that will aid in monitoring runaway Chrome Tabs on a Mac, Linux and probably Win10 if you have the dev tools with bash installed. This is similar to "The Great Suspender" extension in that you can reload suspended tabs but better because it only suspends or cpulimits tabs that are being offensive. 





Optional Dependency
-------------------------------------------------------------------------------
If you have the cpulimit command installed, the default behavior will be to throttle the cpu utilization to the user defined limit the offending pid rather than kill it.

    .. code-block:: bash
    
        $ brew/apt install cpulimit
        

Application Bundle (for non-Terminal loving Mac users)
-------------------------------------------------------------------------------
For those that don't know what bash is and aren't familiar with the Terminal, I've made a Mac Application that you can double-click to run. You can `download`_, unzip and open the app (you'll probably have to right click and select open the first time you run it). It will open a small terminal window in the upper-left-hand corner of your screen and watch for Chrome tabs with heavy CPU utilization once a minute. The output is simple to read but you can ignore it. If a tab eats up too much CPU for a long time, a dialog box on the Mac asking if you want to kill or cpulimit a CPU heavy task. If you hit cancel within 10 seconds, the task will be left alone. If you hit ok or wait 10 seconds, this script will kill or cpulimit that tab. To stop this app, simply close the terminal window and click the "Terminate" button when it appears.

   .. _download: https://github.com/mdupuy/chromeTabMonitor/archive/master.zip

Consider installing the cpulimit command by first installing `Homebrew`_ and then running

   .. _Homebrew: https://brew.sh/

    .. code-block:: bash
    
        $ brew install cpulimit
   
in the Terminal.

chromeMon.sh bash script (and nerdy details)
-------------------------------------------------------------------------------
For the rest you that want to run the bash script at your own interval via LaunchCtl, cron or the watch command and tweak settings:

You can see the defaults at the top of the file. cpuThreshold is 80% per tab by default but this script will accept one command line arg to change that value. It'll watch the top 4 processes by default. Usually only the main Chrome app and one tab are offensive in my expirience. Feel free to dial this back to "2" or extend it if you want.

I suggest running this once a minute with any mechanism you prefer. If a tab is eating more CPU than your threshold for two runs of this script in a row, you'll be given an option to kill or cpulimit that tab. Most tabs will go over your CPU usage threshold while they render but the page renders should take less than a minute (or whatever interval you choose). Of course, playing any sort of media might run longer. You might want to set the default action to not kill the process after if the user doesn't intervene rather than actively kill it.

On a Mac, the most native (but perhaps unfamiliar) method to do this is making a `launchctl plist`_ that runs every 60 seconds, putting it in ~/Library/LaunchAgents/  and loading it with

   .. _launchctl plist: https://www.google.com/search?q=launchctl+that+runs+every+minute

    .. code-block:: bash
    
        $ launchctl load -wF ~/Library/LaunchAgents/some.60second.name.plist

The script pops up a dialog box on the Mac asking if you want to kill or cpulimit a CPU heavy task. If you hit cancel within 10 seconds, the task will be left alone. If you hit ok or wait 10 seconds, this script will kill or cpulimit that tab. If you're on a non-Mac, it'll prompt you for a y/n answer at the terminal. The same timeout and default-to-kill/limit rules apply if you're running non-interactively.

Feature requests? Let me know in the issue tracker.

Other ways to run this at a given interval from the terminal. Install the watch command, i.e. brew install watch

    .. code-block:: bash
    
        $ watch -n60 path/to/this/script/chromeMon.sh
    
Simple bash

    .. code-block:: bash
    
        $ while true; do clear; echo 'Chrome Tab Monitor:'; chromeMon.sh; sleep 60; done
    
On Linux, using "crontab -e", add the line:

    .. code-block:: bash
    
        */1 * * * * path/to/this/script/chromeMon.sh
