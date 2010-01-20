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
export PAGER=less
export EDITOR=vim

if [[ -r ~/.aliasrc ]]; then
    source ~/.aliasrc
fi

# my binary paths
export PYTHONPATH=.:${HOME}/.python:${HOME}/.python/lib/python
PATH+=:${HOME}/.python/bin
PATH+=:${HOME}/.gem/ruby/1.8/bin

# blue/red $ depending on exit status of previous command
PS1='\[\e[1;32m\]\u${PROMPT_HOST} \[\e[1;34m\]\w \[\e[1;$(($??31:34))m\]\$\[\e[0m\] '

#export LC_CTYPE="zh_CN.utf8"
#export XMODIFIERS=@im=SCIM
#export GTK_IM_MODULE=scim
#export QT_IM_MODULE=scim
export XMODIFIERS=@im=uim
export GTK_IM_MODULE=uim
export QT_IM_MODULE=uim
