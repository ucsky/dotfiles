#!/bin/bash -e
#
# My add alias function for git
#
##
if [ -n "$1" ];then
    FILE=$1
else
    echo "ERROR: FILE=\$1 is missing"
    exit 1
fi
filename=$(basename -- "$FILE")
extension="${filename##*.}"
if [ $extension == "ipynb" ];then
    jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace "$FILE"
fi
git add "$FILE"

