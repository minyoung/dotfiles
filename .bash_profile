# /etc/skel/.bash_profile

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
[[ -f ~/.bashrc ]] && . ~/.bashrc

# add @host to after name so I know where I am
PS1='\[\e[1;32m\]\u@\h \[\e[1;34m\]\w \[\e[1;$(($??31:34))m\]\$\[\e[0m\] '

