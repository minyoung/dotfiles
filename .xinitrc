#!/bin/sh

# .profilerc seems to be sourced already
# [[ -r ${HOME}/.profilerc ]] && source ${HOME}/.profilerc

# start xautolock
xautolock -secure &

# set the key repeat delay a bit lower
xset r rate 200 25
xset m 500 50
# set the keyboard mouse acceleration
xkbset ma 20 20 20 100 10

# use the right alt key as the compose key
setxkbmap -model pc104 -layout us -option "compose:ralt"

# set some locale environment stuff
export LANG=en_GB.UTF-8
export XMODIFIERS=@im=ibus
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
ibus-daemon -d -x

