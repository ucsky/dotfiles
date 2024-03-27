#!/bin/bash
BINARY=yq_linux_amd64
VERSION=v4.43.1
PATH_EXE=$HOME/bin/yq_$VERSION
test ! -d $HOME/bin && mkdir $HOME/bin || true
test ! -f $PATH_EXE \
    && (wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY}.tar.gz -O - \
	     | tar xz \
	    && mv ${BINARY} $PATH_EXE \
    ) \
    || true
test -L $HOME/bin/yq && rm $HOME/bin/yq || true
ln -s $PATH_EXE $HOME/bin/yq
. $HOME/.profile
if [ -f install-man-page.sh ] && [ -f yq.1 ];then
    ./install-man-page.sh
    rm install-man-page.sh
    rm yq.1
fi
