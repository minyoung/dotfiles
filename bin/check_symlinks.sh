#!/bin/bash

# Checks all the symlinks in the current directory
# If the symlink is broken, remove the link
TARGET=""
if [ -z "$1" ]; then
    TARGET="."
else
    TARGET="$1"
fi

find -L ${TARGET} -type l -exec rm -v {} \;
# find ${TARGET} -type l -print0 | xargs -0 -L 1 test_symlink.sh

