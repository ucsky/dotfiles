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
     python3-virtualenvwrapper \
     virtualenvwrapper \
     virtualenvwrapper-doc \
     -y
./setup/linux/setup.bash
./setup/linux/setup-bash.bash
./setup/linux/setup-emacs.bash
cat <<EOF
Please add to .bashrc
export WORKON_HOME=\$HOME/.virtualenvs
export PROJECT_HOME=\$HOME/Documents/project
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
EOF
