#!/bin/bash

copy() {
	cp -i "${dotfiles}/$1" "$1"
}

symlink() {
	relative_path=$(dirname "$1")
	if [[ "$relative_path" != "." ]]; then
		relative_path=$(echo "$relative_path" | sed -E "s|[^/]+|..|g")
	fi
	ln -si "${relative_path}/${dotfiles}/$1" "$1"
}

current_dir=$(dirname "$0")
dotfiles="${current_dir#./}"
dotfiles="${dotfiles%/*}"

symlink .inputrc
symlink .tmux.conf

# git
symlink .gitconfig
copy .gitconfig.local
symlink .gitaliases

# shell
symlink .aliasrc
symlink .bash_logout
symlink .bash_profile
symlink .bashrc
symlink .sh
symlink .zlogout
symlink .zprofile
symlink .zsh
symlink .zshrc
symlink .fzf.zsh
copy .localrc

# bin
mkdir -p bin
symlink bin/count-commands.py

# vim
mkdir -p .config
symlink .config/nvim
