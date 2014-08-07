#!/bin/bash

if [[ -z "$1" || -z "$2" ]] ; then
  cat <<EOHELP
Usage: $(basename $0) SOURCE DESTINATION

Use a single git repository with multiple working directories.

Since only the checked out files and index is separate per working \
directory, you can merge, rebase and stash/pop freely between the different \
working directories.
EOHELP

  exit 1
fi

# for when you don't have realpath...
function abspath() {
    pushd . > /dev/null
    if [ -d "$1" ]; then
        cd "$1"
        dirs -l +0
    else
        cd "`dirname \"$1\"`"
        cur_dir=`dirs -l +0`
        if [ "$cur_dir" == "/" ]; then
            echo "$cur_dir`basename \"$1\"`"
        else
            echo "$cur_dir/`basename \"$1\"`"
        fi
    fi
    popd > /dev/null;
}

source=$(realpath "$1")
destination="$2"

mkdir "$destination"

pushd "$destination"
git init
cd .git
for i in branches config hooks info objects refs packed-refs ; do
  rm -rf $i
  ln -s "$source/.git/$i" $i
done

popd
