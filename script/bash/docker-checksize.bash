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
    echo "WARNING: docker not found on $(hostname)."
    exit 0
fi

# Check if docker daemon is running
if ! docker info > /dev/null 2>&1; then
    echo "WARNING: docker daemon is not running or not accessible."
    exit 0
fi

# Check if /var/lib/docker exists and is accessible
if [ ! -d /var/lib/docker ]; then
    echo "WARNING: /var/lib/docker does not exist."
    exit 0
fi

# Check if we have read permission on the directory
if [ ! -r /var/lib/docker ]; then
    echo "WARNING: do not have permission to access /var/lib/docker"
    exit 0
fi

# change directory to /var/lib/docker
pushd /var/lib/docker > /dev/null || {
    echo "WARNING: do not have permission to access /var/lib/docker"
    exit 0
}

# loop through each file and directory in /var/lib/docker
# Use proper quoting to handle spaces in filenames
for i in *; do
    # Skip if no files found (glob expansion)
    [ -e "$i" ] || continue
    # display the disk usage of the current file or directory in a human-readable format
    du -sh "$i"
done

# change back to the previous directory
popd > /dev/null
