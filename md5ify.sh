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
		*.warc.*)	echo 2;;  #File has known multi-suffix (thanks to waddlesplash <https://github.com/waddlesplash>

		*.*.*)		echo 3;;  #File likely has dot in the middle, but you can never be sure - e.g.: SomeThing.min.js
		*.*)		echo 1;;  #File likely has normal suffix. Chance of failure is low
		!(*.*))		echo 0;;  #File has no dot inside
		*)		echo -1;; #Something else - will always abort
	esac
}

FILE="$1"
#Set DRY to any value to enable dry-running
DRY=

if [ -f "$FILE" ]
then
	HASH="$(openssl dgst -md5 $FILE | tail -c 33)"
	MODE="$(getExts \"$FILE\")"
	case "$MODE" in
		3)	echo "File has unknown multi-extension '${FILE#*.}'"
			echo "No suitable suffix could be found."
			echo "MD5ify will not risk damaging your file extensions. Aborting"
			echo "The MD5 sum for '$FILE' is '$HASH'"
			exit 1
			;;
		2)	echo "File has a know double-extension '${FILE#*.}'"
			echo "Renaming '$FILE' to '$HASH.${FILE#*.}'"
			if [ -z "$DRY" ]
			then mv "$FILE" "$HASH.${FILE#*.}"
			else echo "Dry-run only!"
			fi
			exit 0
			;;
		1)
			echo "File has ${FILE#*.} extension"
			echo "Renaming '$FILE' to '$HASH.${FILE#*.}'"
			if [ -z "$DRY" ]
			then mv "$FILE" "$HASH.${FILE#*.}"
			else echo "Dry-run only!"
			fi
			exit 0
			;;
		0)
			echo "File has no extension"
			echo "Renaming '$FILE' to '$HASH'"
			if [ -z "$DRY" ]
			then mv "$FILE" "$HASH"
			else echo "Dry-run only!"
			fi
			exit 0
			;;
		-1|*)
			echo "Unknown case. Aborting!"
			exit 1;;
	esac
else
	echo "error File '$FILE' not a file or none-existent"
	echo "Usage: $0 FILE"
	exit 1
fi
