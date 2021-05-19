#!/bin/bash

mkdir -p Programs

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

bitwarden() {
  program="$1"
  version="$2"
  os=linux
  if [[ $(uname -s) == "Darwin" ]]; then
    os=macos
  fi
  curl --location \
    "https://github.com/bitwarden/cli/releases/download/v${version}/bw-${os}-${version}.zip" \
    --output "${version}.zip"
  unzip "${version}.zip"
  chmod +x bw
}

docker-compose() {
  program="$1"
  version="$2"
  curl --location \
    "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" \
    --output docker-compose
  chmod +x docker-compose
}

scmpuff() {
  program="$1"
  version="$2"
  os=linux_x64
  if [[ $(uname -s) == "Darwin" ]]; then
    os=mac_x64
  fi
  curl --location \
    "https://github.com/mroth/scmpuff/releases/download/v${version}/scmpuff_${version}_${os}.tar.gz" \
    --output "${version}.tar.gz"
  tar --extract --file "${version}.tar.gz"
}

gcloud() {
  program="$1"
  version="$2"
  os=linux
  if [[ $(uname -s) == "Darwin" ]]; then
    os=darwin
  fi
  curl --location \
    "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${version}-${os}-$(uname -m).tar.gz" \
    --output "${version}.tar.gz"
  tar --strip-components 1 --extract --file "${version}.tar.gz"
}

fzf() {
  program="$1"
  version="$2"
  os=linux_amd64
  if [[ $(uname -s) == "Darwin" ]]; then
    os=darwin_amd64
  fi
  git clone https://github.com/junegunn/fzf .
  curl --location \
    "https://github.com/junegunn/fzf/releases/download/0.25.1/fzf-${version}-${os}.tar.gz" \
    --output "${version}.tar.gz"
  tar --directory bin --extra --file "${version}.tar.gz"
}

neovim() {
  program="$1"
  version="$2"
  os=linux64
  if [[ $(uname -s) == "Darwin" ]]; then
    os=macos
  fi
  curl --location \
    "https://github.com/neovim/neovim/releases/download/v${version}/nvim-${os}.tar.gz" \
    --output "${version}.tar.gz"
  tar --strip-components 1 --extract --file "${version}.tar.gz"
}

setup_program bitwarden 1.14.0 bw
setup_program docker-compose 1.28.2
setup_program fzf 0.25.1 bin/fzf
setup_program gcloud 326.0.0 bin/gcloud
setup_program neovim 0.4.4 bin/nvim
setup_program scmpuff 0.3.0
