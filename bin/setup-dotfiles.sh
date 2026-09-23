#!/bin/bash

copy() {
  cp -i "${dotfiles}/$1" "$1"
}

symlink() {
  ln -si "${dotfiles}/$1" "$1"
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
dotfiles="$(dirname "$script_dir")"

symlink .inputrc
symlink .tmux.conf
copy .tmux.local.conf

# git
symlink .gitconfig
copy .gitconfig.local

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

# vim
mkdir -p .config
symlink .config/nvim
