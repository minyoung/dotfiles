#compdef set-ssh-key.sh

_alternative "args:~/.ssh:($(ls $HOME/.ssh))" "files:filename:_files"
