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

current_dir=`dirname "$0"`
dotfiles="${current_dir#./}"
dotfiles="${dotfiles%/*}"

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
mkdir -p .config/nvim
symlink .config/nvim/init.vim
mkdir -p .vim
symlink .vimrc
symlink .vim/filetype.vim
symlink .vim/ftplugin
symlink .vim/ftplugin.vim
symlink .vim/plugin
copy .vim/local.vimrc
if [[ ! -d ".vim/bundle/Vundle.vim" ]]; then
  git clone https://github.com/VundleVim/Vundle.vim.git .vim/bundle/Vundle.vim
  vim +VundleInstall +qall
fi
