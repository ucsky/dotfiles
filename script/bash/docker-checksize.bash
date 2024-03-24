#!/bin/bash -e
#
# Description: Lists the disk usage of all the files and directories
#              within the /var/lib/docker directory in a human-readable
#              format.
#
# Usage: sudo -E $USER $ROOT_DOTFILES/script/bash/docker-checksize.bash
#
# Tags: docker, disk-usage
#
##

help (){
    sed -n '/#!/,/##/p' "$0" \
	| grep -v '#!\|##'
}
if [ "$1" == "help" ];then
    help
    exit 0
fi

command -v docker >> /dev/null && HAS_DOCKER=1 || HAS_DOCKER=0
if [ "$HAS_DOCKER" == 0 ];then
    echo "WARNING: docker not found on `hostname`."
    exit 0
fi


if test -x /var/lib/docker;then
# change directory to /var/lib/docker
pushd /var/lib/docker > /dev/null

# loop through each file and directory in /var/lib/docker
for i in `ls`; do
    # display the disk usage of the current file or directory in a human-readable format
    du -sh $i
done

# change back to the previous directory
popd > /dev/null
else
    echo "WARNING: do not have permision to go in /var/lib/docker"
fi
