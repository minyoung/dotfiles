#!/bin/bash

# Check for symlinks where the destination is not executable
# If the destination is not executable, remove the link
#
# This script is to be used with `symlink_execs.sh`

TARGET=""
if [ -z "$1" ]; then
    TARGET="."
else
    TARGET="$1"
fi

find -L ${TARGET} ! -perm /111 -exec rm -v {} \;
