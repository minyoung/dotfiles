#!/bin/sh

PATH+=:${HOME}/bin/System/Executables

# start xautolock
xautolock -secure &

# set the key repeat delay a bit lower
xset r rate 200 25
# set the keyboard mouse acceleration
xkbset ma 20 20 20 100 10

# use the right win key as the compose key
setxkbmap -model pc104 -layout us -option "compose:rwin"

# set some environment variables
export LANG=en_GB.UTF-8
export XDG_CONFIG_HOME=${HOME}/.local/config
export XDG_DATA_HOME=${HOME}/.local/share

