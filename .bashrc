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
alias ls="ls --color=auto"

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

# environment variables
export HISTCONTROL=ignoreboth
export PAGER=less
export EDITOR=vim
export TERM=xterm-256color

# common commands
alias duh='du -h --max-depth=1'
alias l='ls -al'
alias ll='ls -l'
alias la='ls -a'
alias rr='rm -fr'
alias j='jrun'
alias lz='unzip -l'
alias p='python'
alias ip='ipython'
alias vm='valgrind --leak-check=full'

# fix some typos
alias sl='ls'
alias amke='make'

# my binary paths
export PYTHONPATH=.:${HOME}/.python:${HOME}/.python/lib/python
PATH+=:${HOME}/bin
PATH+=:${HOME}/.python/bin
PATH+=:${HOME}/.gem/ruby/1.8/bin

# blue/red $ depending on exit status of previous command
PS1='\[\e[1;32m\]\u${PROMPT_HOST} \[\e[1;34m\]\w \[\e[1;$(($??31:34))m\]\$\[\e[0m\] '

export XDG_CONFIG_HOME=~/.config
export XDG_DATA_HOME=~/.cache

export LANG=en_GB.UTF-8

#export LC_CTYPE="zh_CN.utf8"
#export XMODIFIERS=@im=SCIM
#export GTK_IM_MODULE=scim
#export QT_IM_MODULE=scim
export XMODIFIERS=@im=uim
export GTK_IM_MODULE=uim
export QT_IM_MODULE=uim
