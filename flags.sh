#!/bin/bash
#Name: Flags
#Summary: Illustration of how to use flags in a bash script
#Author: David Stockinger <https://github.com/MechMK1>, Flexo (https://stackoverflow.com/users/168175/flexo)

#Config
OUT="/tmp/default"

#Displays a nice usage menu
function show_usage
{
	echo "Usage: $0 [OPTIONS] FILE"
	echo ""
	echo "Options:"
	echo " -d       |--dry          : Enable Dry-Running. Only print what would happen"
	echo " -c       |--copy         : Copy something"
	echo " -f       |--force        : Force something"
	echo " -o DIR   |--out DIR      : Have an output directory"
	echo " -v       |--verbose      : Print more verbose output"
	echo " -h       |--help         : Show this message and exit"
}

#Echoes a message if VERBOSE is set
function verbose
{
	local MSG="$@"
	if [ -n "$VERBOSE" ] && [ -n "$MSG" ]
	then echo "${FUNCNAME[1]}: $MSG" >&2
	fi
}

#Only print options when --verbose is enabled
function print_options
{
	verbose "Dry  : $DRY"
	verbose "Copy : $COPY"
	verbose "Force: $FORCE"
	verbose "Out  : $OUT"
}

#Dummy function
function process_file
{
	FILE="$@" #Use $@ instead of $1 in case files contain spaces
	if [ -f "$FILE" ]
	then echo "Processing '$FILE' now..."
	else echo "Error: '$FILE' is not a file" >&2 #Always print errors to STDERR instead of STDOUT
	fi
}

#Main
while test $# -gt 0; do
	case "$1" in
		#Display help and exit
		-h|--help)
			show_usage
			exit 0
			;;
		-v|--verbose)
			VERBOSE="verbose"
			verbose "Verbose mode enabled"
			shift
			;;
		#Set a variable that dry-running has been enabled somewhere in the arguments
		-d|--dry)
			DRY=1
			shift
			;;
		#Set a variable that copying has been enabled somewhere in the arguments
		-c|--copy)
			COPY=1
			shift
			;;
		#Set a variable that forcing has been enabled somewhere in the arguments
		-f|--force)
			FORCE=1
			shift
			;;
		#Set a variable that an output directory has been specified somewhere in the arguments
		#Also, make sure the directory exists, is an actual directory and is writable
		-o|--out)
			if test $# -gt 1				#Check if -o is not the last argument, since -o requires another argument
			then
				if [ -d "${2%/}" ] && [ -w "${2%/}" ]	# -d means exists and is a directory, -w means is writable
				then					#"${2%/}" means trim the trailing slash if there is any
					OUT="${2%/}"
				else
					echo "Error: $1 requires a writable directory as parameter, '$2' given" >&2
					exit 1
				fi
			else
				echo "Error: Missing argument DIRECTORY for $1" >&2
				exit 1
			fi
			shift 2
			;;


		--)
			verbose "Encountered --. All further arguments will be treaten as \"regular\" arguments"
			shift
			break
			;;
		#Default case for unknown flags
		-*)
			echo "Error: Unknown option '$1'. Aborting!" >&2
			exit 1
			;;

		#File parameters start here
		*)
			break #Stop parsing arguments now
			;;
	esac
done


verbose "Checking if we have at least one more parameter left after shifting"
verbose This can also be done without quotes
#If no other parameters are found, print error and show usage, then exit
#This only matters if your script requires at least one non-flag input
if [ "$#" -lt 1 ]
then
	echo "Error: Missing parameter FILE"
	show_usage
	exit 1
fi

#Before processing files, let's review our set options:
print_options

#Call main function with each file as parameter iteratively
for arg in "$@"
do
	process_file "$arg"
done


#Original author: Flexo (https://stackoverflow.com/users/168175/flexo)
#Modified by MechMK1
