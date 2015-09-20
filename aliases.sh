#Summary: List of aliases and functions to use in bash
#Author: David Stockinger <https://github.com/MechMK1>, various (see bottom)


#wanip: Usage: wanip
#Returns wanip
#Fails when dig is not installed or when opendns is unreachable
alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'

#xcat: Usage: xcat FILE
#Prints usable lines from config files and omits all comments, newlines, etc.
#Fails when sed is not installed or when no file is given
xcat () {
	if [ -f "$1" ]
	then sed -e '/^[[:space:]]*#/d;/^[[:space:]]*;/d;s/\r//g;/^[[:space:]]*$/d' "$1"
	fi
}

#qqq: usage: qqq
#Shuts machine down
#Depends on exact syntax of shutdown
alias qqq='sudo shutdown -h 0'

#Alias for shnsplit (part of shntool) to always use "%n %t" format
alias shnsplit='shnsplit -t "%n %t"'

#KillScreens: usage: killscreens
#Kills all detached screens
#Fails when screen, awk or xargs are not installed
killscreens () {
    screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill
}


#Please note, several code snippets were written by others.
#Should you be the author of one of these snippets, please contact me regarding propper attribution or removal from the repository
