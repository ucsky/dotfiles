#!/bin/bash -e
#
# Description: Lists the disk usage of all the files and directories
#              within the /var/lib/docker directory in a human-readable
#              format.
#
# Usage: sudo ./docker-checksize.bash
#
# Tags: docker, disk-usage
#
##

# change directory to /var/lib/docker
pushd /var/lib/docker > /dev/null

# loop through each file and directory in /var/lib/docker
for i in `ls`; do
    # display the disk usage of the current file or directory in a human-readable format
    du -sh $i
done

# change back to the previous directory
popd > /dev/null
