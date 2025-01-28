#!/bin/bash
#
# This script is used to test all rules in the Makefile
#
# Usage:
#   ./test_makefile.sh
#   ./test_makefile.sh -d # Dry run
#

dry_run=0

## Check if the user wants to do a dry run
if [ -n "$1" ];then
    if [ "$1" == "-d" ];then
	dry_run=1
	echo "Dry run enabled"
    fi
fi


## 1. Get all rules from the Makefile
rules=$(grep -E '^[a-zA-Z0-9_-]+:' Makefile | grep -v startlab | grep -v startnb | grep -v tests | sed 's/:.*//' | uniq)
echo -e "Found the follwing rules: \n$rules"

## 2. Test all rules
for i in $rules;do
    echo "Testing rule -> $i <-"
    if [ $dry_run == 1 ];then
	# What is -n option for make?
	# See:
	# - https://stackoverflow.com/questions/4219255/what-is-the-n-option-for-make
	# - https://www.gnu.org/software/make/manual/html_node/Options-Summary.html
	# Description: --just-print, -n
	# Explanation: Print the commands that would be executed, but do
	#              not execute them.
	make -n $i
    else
	make $i
    fi
done
