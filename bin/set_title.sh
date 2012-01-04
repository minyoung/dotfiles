#!/bin/zsh

if [[ "$TERM" == screen* ]]; then
    print -Pn "\ek$1:q\e\\"
elif [[ "$TERM" == xterm* ]]; then
    print -Pn "\e]1;$1:q\a"
fi
