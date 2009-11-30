#!/bin/bash

if [ -z "$1" ]; then
    echo "`basename $0` SRC_DIRECTORY"
    echo
    echo "symlinks all the executables in SRC_DIRECTORY into current directory"
    exit
fi

find "$1" -executable -type f -exec ln -s {} . \;
# find "$1" -executable -type f -exec echo {} \;

