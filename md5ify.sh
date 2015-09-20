#!/bin/bash
#Name: MD5ify
#Summary: Rename file to md5sum of file
#Author: David Stockinger <https://github.com/MechMK1>

#Enable extglob or else get_suffix_case will fail
shopt -s extglob

#Returns which use-case to handle according to the files suffix, suffixes or lack thereof
function get_suffix_case
{
	case "$1" in
		*.tar.*);&
		*.iso.*);&
		*.o.*);&
		*.warc.*)	echo 2;;  #File has known multi-suffix (thanks to waddlesplash <https://github.com/waddlesplash>

		*.*.*)		echo 3;;  #File likely has dot in the middle, but you can never be sure - e.g.: SomeThing.min.js
		*.*)		echo 1;;  #File likely has normal suffix. Chance of failure is low
		!(*.*))		echo 0;;  #File has no dot inside
		*)		echo -1;; #Something else - will always abort
	esac
}

function show_usage
{
	echo "Usage: $0 [OPTIONS] FILE"
	echo ""
	echo "Options:"
	echo " -d|--dry: Enable Dry-Running. No files will be renamed"
	echo " -h|--help: Show this message and exit"
}

#Main function which does all the work
function process_file {
	FILE="$1"

	if [ -f "$FILE" ]
	then
		HASH="$(openssl dgst -md5 $FILE | tail -c 33)"
		DIR="$(dirname $FILE)"
		MODE="$(get_suffix_case \"$FILE\")"
		case "$MODE" in
			3)	echo "File has unknown multi-extension '${FILE#*.}'"
				echo "No suitable suffix could be found."
				echo "MD5ify will not risk damaging your file extensions. Aborting"
				echo "The MD5 sum for '$FILE' is '$HASH'"
				continue
				;;
			2)
				if [ -z "$DRY" ]
				then mv "$FILE" "$DIR/$HASH.${FILE#*.}"
				else echo "mv \"$FILE\" \"$DIR/$HASH.${FILE#*.}\""
				fi
				;;
			1)
				if [ -z "$DRY" ]
				then mv "$FILE" "$DIR/$HASH.${FILE#*.}"
				else echo "mv \"$FILE\" \"$DIR/$HASH.${FILE#*.}\""
				fi
				;;
			0)
				if [ -z "$DRY" ]
				then mv "$FILE" "$DIR/$HASH"
				else echo "mv \"$FILE\" \"$DIR/$HASH\""
				fi
				;;
			-1|*)
				echo "Unknown case. Skipping file '$FILE'"
				continue
				;;
		esac
	else
		echo "'$FILE' not a file. Skipping."
		continue
	fi
}

#When the first parameter is -h or --help, show help and exit
if [ "$1" = "-h" ] || [ "$1" = "--help" ]
then
	show_usage
	exit 0
fi

#When the first parameter is -d or --dry, set DRY and shift parameters forward
if [ "$1" = "-d" ] || [ "$1" = "--dry" ]
then DRY=1
shift
fi

#If no other parameters are found, print error and show usage, then exit
if [ "$#" -lt 1 ]
then
	echo "Error: Missing parameter FILE"
	show_usage
	exit 1
fi

#Call main function with each file as parameter iteratively
for arg in "$@"
do
	process_file "$arg"
done
