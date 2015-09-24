# Fragments
This is a collection of fragments, designed to help you build better shell scripts or understand certain patterns.
All of these fragments can be run as standalone scripts to illustrate their purpose better.
However, please keep in mind that these fragments are for educational purposes. Using them in any sort of production environment will likely require more safety measurements.

## Flags
### Summary
The Flags fragment was designed to illustrate how flags can be used in a script.
It has several optional flags and one required FILE argument.
The script should illustrate the usage of short and long flags (e.g.: `-d`, `--dry`), standalone flags (e.g. `-f`), flags with arguments (e.g.: `-o /tmp`) and special flags (e.g.: `-h`)

When the script is run, all set options are printed, then all given FILE arguments are "processed".

### Details
#### Simple flag
The procedure is simple. Create a case for the short and long option, set a variable to an appropriate value (e.g. 1 for set), then shift to the next variable.
```
-f|--flag)
	FLAG=1
	shift
	;;
```

#### Flag with argument
A flag with argument is a little more complex. At first, you have to check if there is one more parameter. If so, you have to check if it's suitable. If so, set it as usual.
If any checks fail, print an error to inform the user exactly what failed.
```
-o|--out)
	if test $# -gt 1 # Check if there is one more argument after -o or --out
	then
		if [ -d "$2" ] && [ -w "$2" ] # Check if the second argument is a directory and writable. Substitute this with any other check that may be important to you
		then
			OUT="$2"
		else
			echo "Error: $1 requires a writable directory as parameter, '$2' given" >&2 # Print an error to STDERR if the second argument is not a directory and not writable
			exit 1 # Exit, since argument errors should never be skipped
		fi
	else
		echo "Error: Missing argument DIRECTORY for $1" >&2 # Print an error ro STDERR if there is no second argument
		exit 1 # Exit, since argument errors sgould never be skipped
	fi
	shift 2 # Shift by two, since -o DIR are technically two parameters
	;;

```

#### Special flag
Some flags change the behaviour of your program, so that you don't want or need to continue checking more parameters.
In this example, we want the script to just show usage and quit. Keep in mind that it doesn't matter where -h is in the parameters for this to happen.
```
-h|--help)
	show_usage
	exit 1
	;;
```

#### Double dash
When the remote possibility exists that parameters other than flags could start with a dash (-), it's wise to have a -- case-
When -- is encountered, the loop shifts parameters once more, then stops evaluating them, allowing files like "-a" to be treaten as normal files
```
--)
	shift
	break
	;;
```

#### Malformed flag
It's recommended to catch arguments starting with a dash (-), which are not recognized by the script.
This way, you can prevent the user from thinking that a flag they input is interpreted by the program when it's actually not.  
**Note:** Put this below all other flags, otherwise the wildcard may accidently trigger.
```
-*)
	echo "Error: Unknown option '$1'. Aborting!" >&2
	exit 1
	;;

```

#### Non-flag arguments
Once no suitable flag has been encountered, it's safe to assume that non-flag arguments start now. Just break the loop and carry on below.
```
*)
	break
	;;
```

## Verbose
### Summary
The Verbose fragment was designed to illustrate how to create an easy way for your script to give additional output when the user desires so.

### verbose function
```
function verbose
{
	local MSG="$@"
	if [ -n "$VERBOSE" ] && [ -n "$MSG" ]
	then echo "${FUNCNAME[1]}: $MSG" >&2
	fi
}
```

### Usage
To use the verbose function, you will need to have a global variable named `VERBOSE` set to anything other than an empty string.
I recommend setting it to "verbose", since it makes debugging easier.

To give a possible message, just write `verbose Some Message`. Depending if `VERBOSE` has been set, this message might be printed.
All messages are prefixed by the function from which they are called. Calling `verbose foo` from a function named `bar` will result in `bar: foo` being printed.
If `verbose` was called from outside any function, the prefix will default to "main".
