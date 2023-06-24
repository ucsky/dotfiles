#!/bin/bash -e
#
# Description:
#   First install and update.
#
#==

distid=$(echo $(lsb_release -si)-$(lsb_release -sc) | tr '[:upper:]' '[:lower:]')

./setup/linux/setup.bash
./setup/linux/setup-bash.bash
./setup/linux/setup-emacs.bash

