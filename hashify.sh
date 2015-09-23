#!/bin/bash
#Name: Hashify
#Summary: Rename file to hash of file
#Author: David Stockinger <https://github.com/MechMK1>

# KNOWN BUGS ####################################################################################
# - Files starting with a dash (-) cause problems                                               #
#   Yes, it's because OpenSSL doesn't support the -- parameter thingy. It's their bug, not mine #
#   A known workaround is to prefix these files with ./                                         #
#################################################################################################

# Config ########################################################################################
#Default hash digest, will be overwritten by -g                                                 #
DGST="md5"                                                                                      #
#################################################################################################

#Enable extglob or else get_suffix_case will fail
shopt -s extglob

#Displays a nice usage menu
function show_usage
{
	echo "Usage: $0 [OPTION]... FILE..."
	echo ""
	echo "Options:"
	echo " -d       |--dry          : Enable Dry-Running. No files will be renamed"
	echo " -c       |--copy         : Copy files instead of renaming"
	echo " -f       |--force        : Force rename of unknown multi-suffix files"
	echo " -o DIR   |--out DIR      : Move files to DIR instead of their source directory"
	echo " -g DGST  |--digest DGST  : Use DGST instead of default ($DGST)"
	echo " -v       |--verbose      : Print more verbose output"
	echo " -t       |--test         : Test if all required tools are available and print report"
	echo " -h       |--help         : Show this message and exit"
}

#Echoes a message if VERBOSE is set
function verbose
{
	if [ -n "$VERBOSE" ] && [ -n "$1" ]
	then echo "${FUNCNAME[1]}: $1" >&2
	fi
}

#Returns which use-case to handle according to the files suffix, suffixes or lack thereof
function get_suffix_case
{
	local f="$(basename "$@")"
	verbose "ARGS: '$@', FILE: '$f'"
	case "$f" in
		*.tar.*);&
		*.iso.*);&
		*.o.*);&
		*.warc.*)	echo 2 #File has known multi-suffix (thanks to waddlesplash <https://github.com/waddlesplash>
				verbose "Known multi-suffix for file '$f'"
				;;

		*.*.*)		verbose "Unknown multi-suffix for file '$f'"
				if [ -n "$FORCE" ]	#File likely has dot in the middle, but you can never be sure - e.g.: SomeThing.min.js
				then
					echo 2		#If force is set, treat unknown multi-suffix file as if suffix was known
					verbose "Force is set. Treating as known multi-suffix"
				else
					echo 3		#Otherwise treat it as unknown multi-suffix
					verbose "Force not set. Treating as unknown multi-suffix"
				fi
				;;

		*.*)		echo 1 #File likely has normal suffix. Chance of failure is low
				verbose "Normal suffix for file '$f'"
				;;

		!(*.*))		echo 0 #File has no dot inside
				verbose "No suffix for '$f'"
				;;
		*)		echo -1 #Something else - will always abort
				verbose "Unknown situation for file '$f'"
				;;
	esac
}

#Tests if digest given by -g is valid
function test_digest
{
	verbose "Testing digest '$@'"
	case "$@" in
		md4|md5|ripemd160|sha|sha1|sha224|sha256|sha384|sha512|whirlpool)
			echo "0"
			verbose "Known digest found"
			;;	#Digest is whitelisted and can be passed to OpenSSL
		*)
			echo "-1"
			verbose "Unknown digest '$@'"
			;;	#Anything else will fail
	esac
}

function test_tools
{
	OK=0

	if shopt -q extglob
	then echo "Bash extglob set...OK"
	else echo "Bash extglob set...FAIL"
		OK=-1
	fi

	if which openssl > /dev/null
	then echo "OpenSSL usable.....OK"
	else echo "OpenSSL usable.....FAIL"
		OK=-1
	fi

	if which cut > /dev/null
	then echo "cut usable.........OK"
	else echo "cut usable.........FAIL <- WTF"
		OK=-1
	fi

	if which mv > /dev/null
	then echo "mv usable..........OK"
	else echo "mv usable..........FAIL <- WTF"
		OK=-1
	fi

	if which cp > /dev/null
	then echo "cp usable..........OK"
	else echo "cp usable..........FAIL <- WTF"
		OK=-1
	fi

	if which dirname > /dev/null
	then echo "dirname usable.....OK"
	else echo "dirname usable.....FAIL"
		OK=-1
	fi

	if which basename > /dev/null
	then echo "basename usable.....OK"
	else echo "basename usable.....FAIL"
		OK=-1
	fi

	echo ""

	if [ "$OK" = "0" ]
	then
		echo "Everything ok! $0 should be usable without problems!"
		echo "Protip: The author suggests leaving COMMON_SENSE on 'enabled' at all times"
	else
		echo "Some problems were detected. See above which tests failed"
	fi
}

#Do actual IO work here
function commit_changes
{
	if [ -n "$COPY" ]
	then	local CMD="cp"
		verbose "CMD set to 'cp'"
	else	local CMD="mv"
		verbose "CMD set to 'mv'"
	fi

	if [ -n "$OUT" ]
	then local TARGET="$OUT"
	else local TARGET="$DIR"
	fi
	verbose "TARGET set to '$TARGET'"

	if [ -z "$DRY" ]
	then
		verbose "Running $CMD now..."
		"$CMD" "$FILE" "$TARGET/$1"
	else
		verbose "Dry-run. Printing command now..."
		echo "$CMD \"$FILE\" \"$TARGET/$1\""
	fi

}

#Process each file individually
function process_file {
	FILE="$@"
	verbose "FILE: '$FILE'"

	if [ -f "$FILE" ]
	then
		verbose "'$FILE' is regular file"
		#Get directory part of filename and make sure it's writable
		DIR="$(dirname "${FILE}")"
		verbose "DIR is '$DIR'"
		if [ ! -w "$DIR" ]
		then
			echo "Error: '$DIR' is not writable. Renaming not possible" >&2
			continue
		else
			verbose "'$DIR' is writable"
		fi

		#Calculate hash and make a mini-self test.
		HASH="$(openssl dgst -r -$DGST "$FILE" 2>/dev/null | cut -d ' ' -f1)"
		if [ -z "$HASH" ]
		then
			echo "Error: Hash is empty. This should never happen. Please file a bug report at https://github.com/MechMK1/ShellMK1" >&2
			verbose "Command was 'openssl dgst -r -$DGST "$FILE" 2>/dev/null | cut -d ' ' -f1)'"
			exit 1
		fi
		verbose "Hash is '$HASH'"

		#Get rename mode. 3=unknown multi-suffix, 2=known multi-suffix, 1=normal suffix, 0=no suffix, -1=fail
		MODE="$(get_suffix_case "$FILE")"
		case "$MODE" in
			3)
				echo "Unknown multi-suffix '${FILE#*.}'. $DGST hash for '$FILE' is '$HASH'"
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
		-t|--test)
			test_tools
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
		-f|--force)
			FORCE=1
			shift
			;;
		-v|--verbose)
			VERBOSE="verbose"
			shift
			;;
		-o|--out)
			if test $# -gt 1
			then
				if [ -d "${2%/}" ] && [ -w "${2%/}" ]
				then
					OUT="${2%/}"
				else
					echo "Error: $1 requires a writable directory as parameter, '$2' given" >&2
					show_usage
					exit 1
				fi
			else
				echo "Error: Missing argument DIRECTORY for $1" >&2
				show_usage
				exit 1
			fi
			shift 2
			;;
		-g|--digest)
			if test $# -gt 1
			then
				if [ "$(test_digest "${2}")" = "0" ]
				then
					DGST="${2}"
				else
					echo "Error: $1 requires a valid message-digest, '$2' given" >&2
					show_usage
					exit 1
				fi
			else
				echo "Error: Missing argument DIGEST for $1" >&2
				show_usage
				exit 1
			fi
			shift 2
			;;
		-*)
			echo "Error: Unknown option '$1'. Aborting!" >&2
			show_usage
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
	echo "Error: Missing parameter FILE" >&2
	show_usage
	exit 1
fi

#Call main function with each file as parameter iteratively
for arg in "$@"
do
	verbose "Calling process_file with '$arg' now..."
	process_file "$arg"
done
