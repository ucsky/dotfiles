#!/bin/bash -e

# change directory to /var/lib/docker
pushd /var/lib/docker > /dev/null

# loop through each file and directory in /var/lib/docker
for i in `sudo ls`; do
    # display the disk usage of the current file or directory in a human-readable format
    du -sh $i
done

# change back to the previous directory
popd > /dev/null
