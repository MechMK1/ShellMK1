#!/bin/bash
#Name: mkplaylist
#Summary: Create a playlist from a set of files and directories
#Author: David Stockinger <https://github.com/MechMK1>

#Displays a nice usage menu
function show_usage
{
	echo "Usage: $0 [OPTION]... [FILE|DIRECTORY]..."
	echo ""
	echo "Options:"
	echo " -n       |--no-recurse   : Do not recurse. Any found directories will be ignored."
	echo " -v       |--verbose      : Print more verbose output"
	echo " -t       |--test         : Test if all required tools are available and print report"
	echo " -h       |--help         : Show this message and exit"
	echo ""
	echo "Note: When -- is given as argument, all following argument will not be interpreted as options"
}

function verbose
{
	if [ -n "$VERBOSE" ] && [ -n "$1" ]
	then echo "$1" >&2
	fi
}

#TODO
function test_tools
{
	OK=0

	if shopt -q extglob
	then echo "Bash extglob set...OK"
	else echo "Bash extglob set...FAIL"
		OK=-1
	fi

	if which openssl > /dev/null
	then echo "OpenSSL usable.....OK"
	else echo "OpenSSL usable.....FAIL"
		OK=-1
	fi

	if which cut > /dev/null
	then echo "cut usable.........OK"
	else echo "cut usable.........FAIL <- WTF"
		OK=-1
	fi

	if which mv > /dev/null
	then echo "mv usable..........OK"
	else echo "mv usable..........FAIL <- WTF"
		OK=-1
	fi

	if which cp > /dev/null
	then echo "cp usable..........OK"
	else echo "cp usable..........FAIL <- WTF"
		OK=-1
	fi

	if which dirname > /dev/null
	then echo "dirname usable.....OK"
	else echo "dirname usable.....FAIL"
		OK=-1
	fi

	echo ""

	if [ "$OK" = "0" ]
	then
		echo "Everything ok! $0 should be usable without problems!"
		echo "Protip: The author suggests leaving COMMON_SENSE on 'enabled' at all times"
	else
		echo "Some problems were detected. See above which tests failed"
	fi
}

function is_audio
{
	verbose "is_audio: '$1'"
	case "$1" in
		*.aif);&
		*.aiff);&
		*.flac);&
		*.m4a);&
		*.mid);&
		*.mp3);&
		*.mpa);&
		*.ra);&
		*.ogg);&
		*.wav);&
		*.wma)
			verbose "is_audio: yes"
			echo "0" # Any of these is a known audio format. Feel free to add your own audio format to the list
			;;
		*)
			verbose "is_audio: no"
			echo "-1"
			;;
	esac
}

#Helper function. Might change this later
function print_file
{
	local FILE="$1"
	echo "$FILE"
}

function process_file
{
	local FILE="$1"
	verbose "process_file: '$FILE'"
	local IS_AUDIO=$(is_audio "$FILE")

	if [ "$IS_AUDIO" = "0" ]
	then print_file "$FILE"
	fi
}

function process_directory
{
	local DIR="${1%/}"
	verbose "process_directory: '$DIR'"

	for f in "$DIR"/*
	do
		verbose "process_directory: Found '$f'"
		if [ -f "$f" ]
		then process_file "$f"
		elif [ -d "$f" ]
		then
			if [ -z "$NO_RECURSE" ] #If NO_RECURSE is NOT set
			then process_directory "$f"
			else verbose "process_directory: '$f' is directory, but NO_RECURSE is set"
			fi
		else
			verbose "process_directory: '$f' is neither a file nor directory. Skipping..."
			continue
		fi
	done
}

#Main
while test $# -gt 0; do
	case "$1" in
		-h|--help)
			show_usage
			exit 0
			;;
		-t|--test)
			test_tools
			exit 0
			;;
		-n|--no-recurse)
			NO_RECURSE=1
			shift
			;;
		-v|--verbose)
			VERBOSE="verbose"
			shift
			;;
		--)
			shift
			break
			;;
		-*)
			echo "Error: Unknown option '$1'. Aborting!"
			show_usage
			exit 1
			;;
		*)
			#File parameters start here
			break
			;;
	esac
done

#If no other parameters are found, print error and show usage, then exit
if [ "$#" -lt 1 ]
then
	verbose "main: No file or directory arguments found. Defaulting to ."
	process_directory "."
	exit 0
fi

#Call main function with each file as parameter iteratively
for arg in "$@"
do
	if [ -f "$arg" ]
	then process_file "$arg"
	elif [ -d "$arg" ]
	then process_directory "$arg"
	else
		echo "Error: '$arg' is neither a file nor directory. Skipping..."
		continue
	fi
done
#!/bin/bash

