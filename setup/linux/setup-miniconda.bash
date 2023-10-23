#!/bin/bash
ROOT_MINICONDA="${ROOT_MINICONDA:-~/.miniconda3}"
test ! -d ${ROOT_MINICONDA} \
    && mkdir -p ${ROOT_MINICONDA} \
	|| true
test ! -f ${ROOT_MINICONDA}/miniconda.sh \
    && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
	    -O ${ROOT_MINICONDA}/miniconda.sh \
	|| true
bash ${ROOT_MINICONDA}/miniconda.sh -b -u -p ${ROOT_MINICONDA}

test ! -d $HOME/activate && mkdir $HOME/activate || true
cat <<EOF > $HOME/activate/miniconda3 
__conda_setup="\$('${ROOT_MINICONDA}/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ \$? -eq 0 ]; then
    eval "\$__conda_setup"
else
    if [ -f "${ROOT_MINICONDA}/etc/profile.d/conda.sh" ]; then
        . "${ROOT_MINICONDA}/etc/profile.d/conda.sh"
    else
        export PATH="${ROOT_MINICONDA}/bin:\$PATH"
    fi
fi
unset __conda_setup
EOF
