#!/bin/bash -e
#
# Setup for linux based OS
#
##

echo "Starting $0"

# Check if user as sudo
if [ "`whoami`" == root ];then
    HAS_SUDO=1
else
    groups `whoami` | egrep '\ssudo\s' >> /dev/null && HAS_SUDO=1 || HAS_SUDO=0
fi
echo "HAS_SUDO=${HAS_SUDO}"

# Check if distribution has apt
command -v apt >> /dev/null && HAS_APT=1 || HAS_APT=0
echo "HAS_APT=${HAS_APT}"

# Install package with apt
if [ [ $HAS_ROOT == "1" ] && [ $HAS_APT == "1" ] ];then
    for i_setup in setup/linux/apt/setup-*.bash;do
	./$i_setup
    done
fi

# Run all linux bash sub-setup
for i_setup in setup/linux/setup-*.bash; do
    echo "Running $i_setup"
    ./$i_setup
done

echo "Finishing $0"
