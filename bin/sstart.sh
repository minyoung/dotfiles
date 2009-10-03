#!/bin/bash

# arg checking
if [ -z "$1" ]; then
    echo "`basename $0` NAME"
    echo
    echo "starts a screen sessing using \${HOME}/.screen/NAME.rc as the config file"
    exit
fi

# Note: no aruments passed to screen except specifying config file...
FILE="${HOME}/.screen/${1}.rc"
if [ -f "$FILE" ]; then
    screen -c "${FILE}"
else
    echo "Config for ${1} (${FILE}) does not exist"
fi

