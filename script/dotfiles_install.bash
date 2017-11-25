#!/usr/bin/env bash

set -e

DATE=$(date +%Y-%m-%d)

pushd $HOME/.dotfiles > /dev/null

#----------------------------
# Script
#----------------------------
stow script -t ~/bin


popd > /dev/null
