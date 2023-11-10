#!/bin/bash
ROOT_MINICONDA="${ROOT_MINICONDA:-$HOME/.miniconda3}"
test -d ${ROOT_MINICONDA} || mkdir -p ${ROOT_MINICONDA}
test -f ${ROOT_MINICONDA}/install.sh \
    || wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
	    -O ${ROOT_MINICONDA}/install.sh
bash ${ROOT_MINICONDA}/install.sh -b -u -p ${ROOT_MINICONDA}
${ROOT_MINICONDA}/bin/conda init
${ROOT_MINICONDA}/bin/conda config --set auto_activate_base false
