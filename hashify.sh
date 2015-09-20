#!/bin/bash
#Name: Hashify
#Summary: Rename file to hash of file
#Author: David Stockinger <https://github.com/MechMK1>

#Enable extglob or else get_suffix_case will fail
shopt -s extglob

#Config
#Default hash digest, will be overwritten by -g
DGST="md5"

#Displays a nice usage menu and stops
function show_usage
{
	echo "Usage: $0 [OPTIONS] FILE"
	echo ""
	echo "Options:"
	echo " -d       |--dry          : Enable Dry-Running. No files will be renamed"
	echo " -c       |--copy         : Copy files instead of renaming"
	echo " -f       |--force        : Force rename of unknown multi-suffix files"
	echo " -o DIR   |--out DIR      : Move files to DIR instead of their source directory"
	echo " -g DGST  |--digest DGST  : Use DGST instead of default ($DGST)"
	echo " -h       |--help         : Show this message and exit"
}

#Returns which use-case to handle according to the files suffix, suffixes or lack thereof
function get_suffix_case
{
	case "$1" in
		*.tar.*);&
		*.iso.*);&
		*.o.*);&
		*.warc.*)	echo 2;;  #File has known multi-suffix (thanks to waddlesplash <https://github.com/waddlesplash>

		*.*.*)		if [ -n "$FORCE" ]	#File likely has dot in the middle, but you can never be sure - e.g.: SomeThing.min.js
				then echo 2		#If force is set, treat unknown multi-suffix file as if suffix was known
				else echo 3		#Otherwise treat it as unknown multi-suffix
				fi

				;;
		*.*)		echo 1;;  #File likely has normal suffix. Chance of failure is low
		!(*.*))		echo 0;;  #File has no dot inside
		*)		echo -1;; #Something else - will always abort
	esac
}

#Tests if digest given by -g is valid
function test_digest
{
	case "$1" in
		md4|md5|ripemd160|sha|sha1|sha224|sha256|sha384|sha512|whirlpool)
			echo "0"
			;;	#Digest is whitelisted and can be passed to OpenSSL
		*)
			echo "-1"
			;;	#Anything else will fail
	esac
}

#Helper function returns hash according to $FILE and $DGST
function get_hash
{
	echo "$(openssl dgst -r -$DGST $FILE 2>/dev/null | cut -d ' ' -f1)"
}

#Do actual IO work here
function commit_changes
{
	if [ -n "$COPY" ]
	then local CMD="cp"
	else local CMD="mv"
	fi

	if [ -n "$OUT" ]
	then local TARGET="$OUT"
	else local TARGET="$DIR"
	fi

	if [ -z "$DRY" ]
	then "$CMD" "$FILE" "$TARGET/$1"
	else echo "$CMD \"$FILE\" \"$TARGET/$1\""
	fi

}

#Process each file individually
function process_file {
	FILE="$1"

	if [ -f "$FILE" ]
	then
		DIR="$(dirname $FILE)"
		if [ ! -w "$DIR" ]
		then
			echo "Error: '$DIR' is not writable. Renaming not possible"
			continue
		fi
		HASH="$(openssl dgst -r -$DGST $FILE 2>/dev/null | cut -d ' ' -f1)"
		MODE="$(get_suffix_case \"$FILE\")"
		case "$MODE" in
			3)
				echo "Unknown multi-extension '${FILE#*.}'. $DGST hash for '$FILE' is '$HASH'"
				continue
				;;
			2)
				commit_changes "$HASH.${FILE#*.}"
				;;
			1)
				commit_changes "$HASH.${FILE#*.}"
				;;
			0)
				commit_changes "$HASH"
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

#Main
while test $# -gt 0; do
	case "$1" in
		-h|--help)
			show_usage
			exit 0
			;;
		-d|--dry)
			DRY=1
			shift
			;;
		-c|--copy)
			COPY=1
			shift
			;;
		-f|force)
			FORCE=1
			shift
			;;
		-o|--out)
			if test $# -gt 1
			then
				if [ -d "${2%/}" ] && [ -w "${2%/}" ]
				then
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
		-g|--digest)
			if test $# -gt 1
			then
				if [ "$(test_digest ${2})" = "0" ]
				then
					DGST="${2}"
				else
					echo "Error: $1 requires a valid message-digest, '$2' given"
					exit 1
				fi
			else
				echo "Error: Missing argument DIGEST for $1"
				exit 1
			fi
			shift 2
			;;
		-*)
			echo "Error: Unknown option '$1'. Aborting!"
			exit 1
			;;
		*)
			#File parameters start here. Will not work if files start with -, but I don't think I know anyone who names files like that
			break
			;;
	esac
done

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
