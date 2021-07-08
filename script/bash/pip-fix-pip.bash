#!/bin/bash -e
#
# Fix error with pip in virtualenv using non-system Python
# See: https://stackoverflow.com/questions/49478573/pip3-install-not-working-no-module-named-pip-vendor-pkg-resources
#
##
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --force-reinstall
rm -f get-pip.py
