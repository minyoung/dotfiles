# /etc/skel/.bashrc:
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
if [[ -f ~/.dir_colors ]]; then
	eval `dircolors -b ~/.dir_colors`
else
	eval `dircolors -b /etc/DIR_COLORS`
fi

# Change the window title of X terminals 
case $TERM in
	xterm*|rxvt*|Eterm)
		#PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
                PROMPT_COMMAND='echo -ne "\033]0;${USER}:${PWD/$HOME/~}\007"'
		;;
	screen)
		#PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
                PROMPT_COMMAND='echo -ne "\033_${USER}:${PWD/$HOME/~}\033\\"'
		;;
esac

shopt -s histappend

# environment variables
export HISTCONTROL=ignorespace:ignoredups:erasedups

[[ -r ${HOME}/.aliasrc ]] && source ${HOME}/.aliasrc

# TP_RED=`tput setaf 1`
# TP_GREEN=`tput setaf 2`
# TP_YELLOW=`tput setaf 3`
# TP_BLUE=`tput setaf 4`
# TP_MAGENTA=`tput setaf 5`
# TP_CYAN=`tput setaf 6`
# TP_WHITE=`tput setaf 7`

# TP_BOLD=`tput bold`
# TP_RST=`tput sgr0`

# blue/red $ depending on exit status of previous command
PS1='\[\e[1;32m\]\u${PROMPT_HOST} \[\e[1;34m\]\w \[\e[1;$(($??31:34))m\]\$\[\e[0m\] '

