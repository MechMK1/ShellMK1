#!/bin/bash
#Name: MD5ify
#Summary: Rename file to md5sum of file
#Author: David Stockinger <https://github.com/MechMK1>

function getExts
{
	case "$1" in
		*.tar.*)	echo 2;;
		*.*.*)		echo 3;;
		*.*)		echo 1;;
		*)		echo 0;;
	esac
}

function renameToHash
{
	mv "$1" "$2"
}

FILE="$1"
HASH=

if [ -f "$FILE" ]
then
	HASH="$(openssl dgst -md5 $FILE | tail -c 33)"
	MODE="$(getExts \"$FILE\")"
	case "$MODE" in
		3)	echo "File has unknown double extension '${FILE#*.}'"
			echo "No suitable suffix could be found."
			echo "MD5ify will not risk damaging your file extensions. Aborting"
			echo "The MD5 sum for '$FILE' is '$HASH'"
			exit 1
			;;
		2)	echo "File has .tar.* double extension. Will be preserved."
			echo "Renaming '$FILE' to '$HASH.${FILE#*.}'"
			renameToHash "$FILE" "$HASH.${FILE#*.}"
			exit 0
			;;
		1)
			echo "File has ${FILE#*.} extension"
			echo "Renaming '$FILE' to '$HASH.${FILE#*.}'"
			renameToHash "$FILE" "$HASH.${FILE#*.}"
			exit 0
			;;
		0)
			echo "File has no extension"
			echo "Renaming '$FILE' to '$HASH'"
			renameToHash "$FILE" "$HASH"
			exit 0
			;;
		*)
			echo "Unknown case. Aborting!"
			exit 1;;
	esac
else
	echo "error File '$FILE' not a file or none-existent"
	echo "Usage: $0 FILE"
	exit 1
fi
