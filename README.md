Photoimport.pl
==============

Small perl scripts to import Pictures taken with a digital camera. 

I use find2perl the explore the filesystem recursively.

Usage:
-----

    photoimport -s [full path to source directory] -d [full path to destination directory]

    -s    [source_directory]
    -d    [destination_directory]
    -e    "[event]" (e.g: "This awesome party")
    -o    overwrite all existing files
    -k    keep modified files in their current version.
    -v    Verbose Mode.
    -q    Quiet Mode.

**It will overwrite modified files by default.**
