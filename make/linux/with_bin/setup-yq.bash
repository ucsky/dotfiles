#!/usr/bin/env bash
#
# Description:
#   Install yq (Linux amd64) in $HOME/bin.
#
set -euo pipefail

BINARY="yq_linux_amd64"
VERSION="v4.43.1"
PATH_EXE="$HOME/bin/yq_$VERSION"

mkdir -p "$HOME/bin"

if [ ! -f "$PATH_EXE" ]; then
  if command -v wget >/dev/null 2>&1; then
    wget "https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz" -O - | tar xz
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz" | tar xz
  else
    echo "WARNING: neither wget nor curl found; cannot download yq." 1>&2
    exit 0
  fi
  mv "${BINARY}" "$PATH_EXE"
fi

rm -f "$HOME/bin/yq" || true
ln -s "$PATH_EXE" "$HOME/bin/yq"
