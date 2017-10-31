#!/bin/bash

if [[ -z "$1" ]]; then
  ssh-add -l
  exit 1
fi

ssh-add -D
for path in "$@"; do
  if [[ -r "$HOME/.ssh/$path" ]]; then
    path="$HOME/.ssh/$path"
  fi
  if [[ -r "$path" ]]; then
    ssh-add "$path"
  else
    echo "ssh key not found: $path"
  fi
done
