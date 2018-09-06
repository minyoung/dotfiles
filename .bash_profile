# /etc/skel/.bash_profile

[[ -r ~/.profilerc ]] && source ~/.profilerc

# add @hostname to after name so I know where I am
if [[ -z ${HOST_PROMPT} ]]; then
    HOST_PROMPT="@`hostname`"
fi

# This file is sourced by bash for login shells.  The following line
# runs your .bashrc and is recommended by the bash info pages.
[[ -f ~/.bashrc ]] && . ~/.bashrc

