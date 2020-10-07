#!/bin/bash
#
# Install Python version 3.6.6 from source
#
# See: https://towardsdatascience.com/building-python-from-source-on-ubuntu-20-04-2ed29eec152b
#
##
sudo apt-get update
sudo apt-get install -y build-essential checkinstall
sudo apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
cd /usr/src
if [ -d Python-3.6.6 ];then
    rm -rf Python-3.6.6
fi
sudo wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz
sudo tar xzf Python-3.6.6.tgz
cd Python-3.6.6
sudo ./configure --enable-optimizations
sudo make altinstall
