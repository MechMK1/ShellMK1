#!/bin/bash
#Name: MD5ify
#Summary: Rename file to md5sum of file
#Author: David Stockinger <https://github.com/MechMK1>

#Enable extglob or else getExts will fail
shopt -s extglob

#Returns which use-case to handle according to the files suffix, suffixes or lack thereof
function getExts
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

function showusage
{
	echo "Usage: $0 [OPTIONS] FILE"
	echo ""
	echo "Options:"
	echo " -d|--dry: Enable Dry-Running. No files will be renamed"
}

function processFile {
	FILE="$1"

	if [ -f "$FILE" ]
	then
		HASH="$(openssl dgst -md5 $FILE | tail -c 33)"
		MODE="$(getExts \"$FILE\")"
		case "$MODE" in
			3)	echo "File has unknown multi-extension '${FILE#*.}'"
				echo "No suitable suffix could be found."
				echo "MD5ify will not risk damaging your file extensions. Aborting"
				echo "The MD5 sum for '$FILE' is '$HASH'"
				continue
				;;
			2)
				if [ -z "$DRY" ]
				then mv "$FILE" "$HASH.${FILE#*.}"
				else echo "mv \"$FILE\" \"$HASH.${FILE#*.}\""
				fi
				;;
			1)
				if [ -z "$DRY" ]
				then mv "$FILE" "$HASH.${FILE#*.}"
				else echo "mv \"$FILE\" \"$HASH.${FILE#*.}\""
				fi
				;;
			0)
				if [ -z "$DRY" ]
				then mv "$FILE" "$HASH"
				else echo "mv \"$FILE\" \"$HASH\""
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

#When the first parameter is -d or --dry
if [ "$1" = "-d" ] || [ "$1" = "--dry" ]
then DRY=1
shift
fi

if [ "$#" -lt 1 ]
then
	echo "Error: Missing parameter FILE"
	showusage
	exit 1;
fi

for arg in "$@"
do
	processFile "$arg"
done
