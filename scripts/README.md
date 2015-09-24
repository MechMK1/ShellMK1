# Scripts
This is a collection of scripts, designed to fulfill various tasks.
All of these scripts support -h or --help, so you should usually be able to figure out what they do.
Aside, all of these scripts have a small summary in their header, briefly discribing what they do.

## Hashify
Hashify was designed to bulk-rename files to their hash-values.
That means, IMG_00001.png would be renamed to 3d20a809f7dd268f6af1d6e167c4d35e.png, for example.
This can be pretty useful if you have a lot of files without any semantic naming, such as images you downloaded sometime.
Just keep in mind that moving files around can potentially overwrite other files, so if you work with REALLY important files, you should ~~not use my scripts~~ make a backup first.

Usage is simple: `hashify IMG_00001.png`

## mkplaylist
mkplaylist was designed to quickly create a .m3u compatible playlist from a directory or a set of files (or a mix in between).
When no arguments were given, mkplaylist will use your current working directory as root for the playlist.
mkplaylist will only create a relative playlist. That means it depends on how you access the playlist for it to work.
An example of a music library:

```
Music
├── Alstroemeria Records
│   ├── KILLED DANCEHALL
│   │   ├── 01 Undercover.aiff
│   │   ├── 02 Romantic Children.aiff
│   │   └── ...
│   └── Lovelight
│       ├── 01 Lovelight.aiff
│       ├── 02 Bad Apple.aiff
│       └── ...
└── Children Of Bodom
    └── Are You Dead Yet?
        ├── 01 Living Dead Beat.aiff
        ├── 02 Are You Dead Yet_.aiff
        └── ...
```
When generating a playlist for "Music/", you will have to put the playlist in "Music/Playlist.m3u".
When opening the playlist via `file://`, `http://` or similar schemas, most players should recognize the relative paths and search for the files accordingly.
Should you have problems with that, please send me a bug report.
