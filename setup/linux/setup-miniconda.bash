#!/bin/bash
test ! -d ~/.miniconda3 \
    && mkdir -p ~/.miniconda3 \
	|| true
test ! -f ~/.miniconda3/miniconda.sh \
    && wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
	    -O ~/.miniconda3/miniconda.sh \
	|| true
bash ~/.miniconda3/miniconda.sh -b -u -p ~/.miniconda3

test ! -d $HOME/activate && mkdir $HOME/activate || true
cat <<EOF > $HOME/activate/miniconda3 
__conda_setup="\$('/home/${USER}/.miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ \$? -eq 0 ]; then
    eval "\$__conda_setup"
else
    if [ -f "/home/${USER}/.miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/${USER}/.miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/${USER}/.miniconda3/bin:\$PATH"
    fi
fi
unset __conda_setup
EOF
