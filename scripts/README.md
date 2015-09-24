# Scripts
This is a collection of scripts, designed to fulfill various tasks.
All of these scripts support -h or --help, so you should usually be able to figure out what they do.
Aside, all of these scripts have a small summary in their header, briefly discribing what they do.

## Hashify
### Summary
Hashify was designed to bulk-rename files to their hash-values.
By default, Hashify uses md5 to generate hashes of files, but any digest supported by OpenSSL can be used.

### Usage
```
Usage: hashify.sh [OPTION]... FILE...

Options:
 -d       |--dry          : Enable Dry-Running. No files will be renamed
 -c       |--copy         : Copy files instead of renaming
 -f       |--force        : Force rename of unknown multi-suffix files
 -o DIR   |--out DIR      : Move files to DIR instead of their source directory
 -g DGST  |--digest DGST  : Use DGST instead of default (md5)
 -v       |--verbose      : Print more verbose output
 -t       |--test         : Test if all required tools are available and print report
 -h       |--help         : Show this message and exit
```

### Examples
```
hashify IMG_0001.png # Renames IMG_0001.png to e.g. 3d20a809f7dd268f6af1d6e167c4d35e.png

hashify -c -o ~/Pictures/ ~/Download/*.png # Copy all .png files from ~/Download to ~/Pictures and name them accordingly

hashify -t # Perform a self test to see if all required tools are there and working

hashify -g sha1 IMG_0001.png # Renames IMG_0001.png to 102cc227fe4122d3aaa57dec97e8b7802ddb143f.png, using the SHA1 sum

hashify -f IMG.0001.png # Renames IMG.0001.png to 3d20a809f7dd268f6af1d6e167c4d35e.png, ignoring that .0001 might be important to its name
```

## mkplaylist
### Summary
mkplaylist was designed to quickly create a .m3u compatible playlist from a directory or a set of files (or a mix in between).
When no arguments were given, mkplaylist will use your current working directory as root for the playlist.

### Usage
```
Usage: mkplaylist.sh [OPTION]... [FILE|DIRECTORY]...
Options:
 -n       |--no-recurse   : Do not recurse. Any found directories will be ignored.
 -v       |--verbose      : Print more verbose output
 -h       |--help         : Show this message and exit

Note: When -- is given as argument, all following arguments will not be interpreted as options
```

### Examples
```
mkplaylist # Creates a playlist, taking the current working directory as root, and prints it to STDOUT

mkplaylist ~/Music > ~/Music/Music.m3u # Creates a playlist of ~/Music and writes it there as Music.m3u

mkplaylist -n ~/Download/ > ~/Music/Downloads.m3u # Creates a playlist of Downloads, but not its subdirectories, and writs it to ~/Music

mkplaylist -- -K.flac # Create a playlist containing a file called -K.flac. It's important to use -- when working with files starting with a dash
```
