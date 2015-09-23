#!/bin/bash
#Name: Verbose
#Summary: Illustrate how verbose debug output can be provided
#Author: David Stockinger <https://github.com/MechMK1>


##########
# OUTPUT EXAMPLES
# Example 1: Getting normal output
# Input:
# mechmk1@Saigyouji:~/Projects/ShellMK1$ bash verbose.sh First Second "Third and Fourth" Fifth
#
# Output:
# First
# Second
# Third and Fourth
# Fifth
#
# Example 2: Getting normal and verbose output
# Input:
# mechmk1@Saigyouji:~/Projects/ShellMK1$ bash verbose.sh --verbose First Second "Third and Fourth" Fifth
#
# Output:
# main: Verbose mode enabled
# print_arguments: ARGS is 'First'
# print_arguments: Current argument is First
# First
# print_arguments: ARGS is 'Second'
# print_arguments: Current argument is Second
# Second
# print_arguments: ARGS is 'Third and Fourth'
# print_arguments: Current argument is Third and Fourth
# Third and Fourth
# print_arguments: ARGS is 'Fifth'
# print_arguments: Current argument is Fifth
# Fifth
#
# Example 3: Getting verbose output only
# Input:
# mechmk1@Saigyouji:~/Projects/ShellMK1$ bash verbose.sh --verbose First Second "Third and Fourth" Fifth > /dev/null
#
# Output:
# main: Verbose mode enabled
# print_arguments: ARGS is 'First'
# print_arguments: Current argument is First
# print_arguments: ARGS is 'Second'
# print_arguments: Current argument is Second
# print_arguments: ARGS is 'Third and Fourth'
# print_arguments: Current argument is Third and Fourth
# print_arguments: ARGS is 'Fifth'
# print_arguments: Current argument is Fifth
##########


#Displays a nice usage menu
function show_usage
{
	echo "Usage: $0 [OPTION]... ARG..."
	echo ""
	echo " -v       |--verbose      : Print more verbose output"
	echo " -h       |--help         : Show this message and exit"
}

#Echoes a message if VERBOSE is set
function verbose
{
	local MSG="$@" #All arguments given to this function are stored in MSG
	if [ -n "$VERBOSE" ] && [ -n "$MSG" ] # If VERBOSE has been set and MSG is not empty, ...
	then echo "${FUNCNAME[1]}: $MSG" >&2  # the name of the calling function and the message will be printed to STDERR
	fi                                    # Printing to STDERR allows you to call your script with >/dev/null to only get verbose output
}

#Dummy function which prints the remaining arguments
function print_arguments
{
	ARGS="$@"
	verbose "ARGS is '$ARGS'" # This message will only be shown when VERBOSE was set

	for arg in "$ARGS" #Iterate over all arguments and print them
	do
		verbose Current argument is $arg #Verbose output does not need to be quoted
		echo "$arg"
	done
}

#Main
while test $# -gt 0; do
	case "$1" in
		#Display help and exit
		-h|--help)
			show_usage
			exit 0
			;;

		#Enable verbose output with -v or --verbose
		-v|--verbose)
			VERBOSE="verbose"
			verbose "Verbose mode enabled"
			shift
			;;

		#Default case for unknown flags
		-*)
			echo "Error: Unknown option '$1'. Aborting!" >&2
			exit 1
			;;

		#Non-flag parameters start here
		*)
			break #Stop parsing arguments now
			;;
	esac
done


#Call main function with each argument iteratively
for arg in "$@"
do
	print_arguments "$arg"
done
