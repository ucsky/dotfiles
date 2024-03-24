#!/bin/bash

BINARY=yq_linux_amd64
VERSION=v4.2.0
PATH_EXE=$HOME/bin/yq_$VERSION
test ! -d $HOME/bin && mkdir $HOME/bin || true
test ! -f $PATH_EXE \
    && (wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - \
	     | tar xz \
	    && mv ${BINARY} $PATH_EXE \
    ) \
    || true
