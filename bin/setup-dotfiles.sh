#!/bin/bash

copy() {
  cp -i "${dotfiles}/$1" "$1"
}

symlink() {
  ln -si "${dotfiles}/$1" "$1"
}

current_dir=`dirname "$0"`
dotfiles="${current_dir%/*}"

symlink .inputrc
symlink .tmux.conf

# git
copy .gitconfig
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
copy .localrc

# bin
mkdir -p bin
symlink bin/count-commands.py

# vim
mkdir -p .vim
symlink .vimrc
symlink .vim/filetype.vim
symlink .vim/ftplugin
symlink .vim/ftplugin.vim
symlink .vim/plugin
copy .vim/local.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim
vim +VundleInstall +qall
