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

# sometimes you don't have `readlink -f`
function abspath() {
  (cd "$1" && pwd -P)
}

source=$(abspath "$1")
destination="$2"

mkdir "$destination"

pushd "$destination"
git init
cd .git
for i in branches config hooks info modules objects refs packed-refs ; do
  rm -rf $i
  ln -s "$source/.git/$i" $i
done

popd
