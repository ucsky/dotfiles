#!/bin/bash -e
pushd /var/lib/docker > /dev/null
for i in `sudo ls`;do
    sudo du -sh $i;
done
popd > /dev/null

