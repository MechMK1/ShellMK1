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
	echo " -h       |--help         : Show this message and exit"
}

function print_options
{
	echo "Dry  : $DRY"
	echo "Copy : $COPY"
	echo "Force: $FORCE"
	echo "Out  : $OUT"
}

#Dummy function
function process_file
{
	FILE="$1"
	echo "Processing '$FILE' now..."
}

#Main
while test $# -gt 0; do
	case "$1" in
		#Display help and exit
		-h|--help)
			show_usage
			exit 0
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
		-f|force)
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
					echo "Error: $1 requires a writable directory as parameter, '$2' given"
					exit 1
				fi
			else
				echo "Error: Missing argument DIRECTORY for $1"
				exit 1
			fi
			shift 2
			;;
		#Default case for unknown flags. Will cause problems for other arguments if they happen to start with a -
		-*)
			echo "Error: Unknown option '$1'. Aborting!"
			exit 1
			;;

		#File parameters start here
		*)
			break #Stop parsing arguments now
			;;
	esac
done

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
