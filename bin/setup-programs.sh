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

gcloud() {
  program="$1"
  version="$2"
  os=linux
  if [[ $(uname -s) == "Darwin" ]]; then
    os=darwin
  fi
  arch="$(uname -m)"
  if [[ "$arch" == arm64 ]]; then
    arch=arm
  fi
  curl --location \
    "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${version}-${os}-${arch}.tar.gz" \
    --output "${version}.tar.gz"
  tar --strip-components 1 --extract --file "${version}.tar.gz"
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
brew install unar
brew install ouch

# setup_program bitwarden 1.14.0 bw
# setup_program docker-compose 1.28.2
# setup_program gcloud 456.0.0 bin/gcloud
