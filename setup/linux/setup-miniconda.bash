#!/bin/bash
ROOT_MINICONDA="${ROOT_MINICONDA:-$HOME/.miniconda3}"
test ! -d ${ROOT_MINICONDA} \
    && mkdir -p ${ROOT_MINICONDA} \
	|| true
test ! -f ${ROOT_MINICONDA}/miniconda.sh \
    && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
	    -O ${ROOT_MINICONDA}/miniconda.sh \
	|| true
bash ${ROOT_MINICONDA}/miniconda.sh -b -u -p ${ROOT_MINICONDA}
${ROOT_MINICONDA}/bin/conda init
${ROOT_MINICONDA}/bin/conda config --set auto_activate_base false
