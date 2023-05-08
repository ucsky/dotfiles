#!/bin/bash -e
#
# Usage: sudo ./docker-checksize.bash
#
# Lists the disk usage of all the files and directories within
# the /var/lib/docker directory in a human-readable format.
# 
# change directory to /var/lib/docker
pushd /var/lib/docker > /dev/null

# loop through each file and directory in /var/lib/docker
for i in `ls`; do
    # display the disk usage of the current file or directory in a human-readable format
    du -sh $i
done

# change back to the previous directory
popd > /dev/null
