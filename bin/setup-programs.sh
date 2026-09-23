#!/bin/bash

mkdir -p Programs

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
dotfiles="$(dirname "$script_dir")"

setup_program() {
  program="$1"
  version="$2"
  binary="${3:-$program}"
  install="${4:-$program}"

  if [[ -f "$(basename $binary)" ]]; then
    echo "Program symlink already exists: $program"
    return
  fi

  mkdir -p "Programs/$program/$version"
  pushd "Programs/$program"
  ln -s "$version" current
  cd "$version"

  "$install" "$program" "$version"

  popd
  ln -s "Programs/$program/current/$binary" .
}

brew install bat
brew install fd
brew install fzf
brew install git-delta
brew install jq
brew install lsd
brew install ripgrep
brew install scmpuff
brew install neovim
# brew install unar
brew install ouch

# brew install colima
# brew install docker-compose

# brew install awscli
# brew install --cask gcloud-cli

brew install go
