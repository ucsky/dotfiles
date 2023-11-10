#!/bin/bash -e
#
# Description: idenpotent setup.
#
#==

distid=$(echo $(lsb_release -si)-$(lsb_release -sc) | tr '[:upper:]' '[:lower:]')

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install \
     emacs \
     -y
./setup/linux/setup.bash
./setup/linux/setup-bash.bash
./setup/linux/setup-emacs.bash
