#!/bin/bash -e
#
# Setup for linux based OS
#
##

# Run all linux bash sub-setup
for i_setup in $HOME/.dotfiles/setup/linux/setup-*.bash; do
    ./$i_setup
done
