#!/bin/bash
#Name: Flags
#Summary: Illustration of how to use flags in a bash script
#Author: David Stockinger <https://github.com/MechMK1>, Flexo (https://stackoverflow.com/users/168175/flexo)

while test $# -gt 0; do
	case "$1" in
		-h|--help)
			echo "$0 [options] something"
			echo " "
			echo "options:"
			echo " -h, --help                show brief help"
			echo " -a, --action=ACTION       specify an action to use"
			echo " -o, --output-dir=DIR      specify a directory to store output in"
			exit 0
			;;
		-a)
			shift # shift once more because -a requires a value
			if test $# -gt 0; then
				export PROCESS=$1
			else
				echo "no process specified"
				exit 1
			fi
			shift
			;;
		--action*)
			export PROCESS=`echo "$1" | sed -e 's/^[^=]*=//g'` # use sed to get the value after =
			shift
			;;
		-o)
			shift
			if test $# -gt 0; then
				export OUTPUT="$1"
			else
				echo "no output dir specified"
				exit 1
			fi
			shift
			;;
		--output-dir*)
			export OUTPUT=`echo "$1" | sed -e 's/^[^=]*=//g'`
			shift
			;;
		*)
			#work with your final arguments here, e.g. when calling "./flags.sh foobar", you should process foobar here
			break
			;;
	esac
done

#Original author: Flexo (https://stackoverflow.com/users/168175/flexo)
#Modified by MechMK1 
