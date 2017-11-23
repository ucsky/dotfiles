#!/usr/bin/env bash
set -e

DATE=$(date +%Y-%m-%d)

pushd $HOME/.dotfiles > /dev/null

#----------------------------
# Script
#----------------------------
stow script -t ~/bin
pushd script/host
if [ -d $HOSTNAME ];then
    stow $HOSTNAME -t ~/bin
fi
popd
# End
popd > /dev/null
