#!/bin/bash -e
#
# Setup for linux based OS
#
##

echo "Starting $0"
echo "USERNAME=$USERNAME"
echo "whoami=`whoami`"
# Check if user as sudo
if [ "`whoami`" == root ];then
    HAS_SUDO=1
else
    groups `whoami` | egrep '\ssudo|sudo\s|\ssudo\s' >> /dev/null && HAS_SUDO=1 || HAS_SUDO=0
fi
echo "HAS_SUDO=${HAS_SUDO}"

# Check if distribution has apt
command -v apt >> /dev/null && HAS_APT=1 || HAS_APT=0
echo "HAS_APT=${HAS_APT}"

# Run all linux bash sub-setup
for i_setup in setup/linux/setup-*.bash; do
    echo "Running $i_setup"
    test -f $i_setup && ./$i_setup || true
done


# Install package with apt
if [[ $HAS_SUDO == "1" && $HAS_APT == "1" ]];then
    for i_setup in setup/linux/with_apt/setup-*.bash;do
	test -f $i_setup && ./$i_setup || true
    done
fi

# Run all linux bash sub-setup
for i_setup in setup/linux/with_bin/setup-*.bash; do
    echo "Running $i_setup"
    test -f $i_setup && ./$i_setup || true
done

echo "Finishing $0"
