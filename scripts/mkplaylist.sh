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
	echo " -h       |--help         : Show this message and exit"
	echo ""
	echo "Note: When -- is given as argument, all following arguments will not be interpreted as options"
}

#Echoes a message if VERBOSE is set
function verbose
{
	local MSG="$@"
	if [ -n "$VERBOSE" ] && [ -n "$MSG" ]
	then echo "${FUNCNAME[1]}: $MSG" >&2
	fi
}

#Checks if a given file is an audio file by checking its suffix
#Returns 0 if given file is an audio file, otherwise -1
#NOTE: Feel free to add more suffixes if your player supports them.
function is_audio
{
	verbose "FILE: '$@'"
	case "$@" in
		*.aif) ;&
		*.aiff);&
		*.flac);&
		*.m4a) ;&
		*.mid) ;&
		*.mp3) ;&
		*.mpa) ;&
		*.ra)  ;&
		*.ogg) ;&
		*.wav) ;&
		*.wma)
			verbose "Result: yes"
			echo "0" # Any of these is a known audio format. Feel free to add your own audio format to the list
			;;
		*)
			verbose "Result: no"
			echo "-1"
			;;
	esac
}

#Helper function. Might change this later
function print_file
{
	local FILE="$1"
	echo "${FILE#./}" #Remove preceeding ./
}

#Process a single file
function process_file
{
	local FILE="$1"
	verbose "'$FILE'"
	if [ "$(is_audio "$FILE")" = "0" ]
	then print_file "$FILE"
	fi
}

#Process a directory
function process_directory
{
	local DIR="${1%/}"
	verbose "'$DIR'"

	for f in "$DIR"/*
	do
		verbose "Found '$f'"
		if [ -f "$f" ]
		then process_file "$f" #If what has been found is a regular(!) file, process it
		elif [ -d "$f" ]
		then
			if [ -z "$NO_RECURSE" ] #If NO_RECURSE is NOT set
			then process_directory "$f" #If what has been found is a directory and NO_RECURSE is not set, process it
			else verbose "'$f' is directory, but NO_RECURSE is set" #Else, give a verbose message that it will not be processed
			fi
		else
			verbose "'$f' is neither a regular file nor directory. Skipping..." #If $f is neither a regular file or directory, skip it.
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
		-n|--no-recurse)
			NO_RECURSE=1
			shift
			;;
		-v|--verbose)
			VERBOSE="verbose"
			verbose "Verbose mode enabled"
			shift
			;;
		--)
			shift
			break
			;;
		-*)
			echo "Error: Unknown option '$1'. Aborting!" >&2
			show_usage
			exit 1
			;;
		*)
			#File parameters start here
			break
			;;
	esac
done

#If no other parameters are found, default to the current directory
if [ "$#" -lt 1 ]
then
	verbose "No file or directory arguments found. Defaulting to ."
	process_directory "."
	exit 0
fi

#Call main function with each file as parameter iteratively
for arg in "$@"
do
	if [ -f "$arg" ]
	then
		vebose "'$arg' is regular file"
		process_file "$arg"
	elif [ -d "$arg" ]
	then
		verbose "'$arg' is directory"
		process_directory "$arg"
	else
		echo "Error: '$arg' is neither a file nor directory. Skipping..." >&2
		continue
	fi
done
