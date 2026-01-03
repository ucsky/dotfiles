#!/bin/bash -e
#
# Description:
# Miniconda Installation Script.
# This script automates the installation of Miniconda, a minimal installer for conda.
# It checks for an existing Miniconda installation, downloads the latest Miniconda
# installer if needed, and runs the installer. It then initializes conda for the current
# user and configures it not to auto-activate the base environment on startup.
#
# Usage:
# ./this_script.sh
# (Optional) Export ROOT_MINICONDA with a custom path before running the script.
#
# Environment Variables:
# ROOT_MINICONDA - Specifies the installation directory for Miniconda.
#                  Defaults to "$HOME/.miniconda3" if not set.
#
##

MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

# Test if conda is already installed
command -v conda >> /dev/null && HAS_CONDA=1 || HAS_CONDA=0
if [ $HAS_CONDA == 1 ];then
    echo "conda already installed"
    exit 0
fi

# Set the ROOT_MINICONDA variable to the user's home directory
# with a default path to .miniconda3 or use the provided
# ROOT_MINICONDA environment variable if it exists.
ROOT_MINICONDA="${ROOT_MINICONDA:-$HOME/.miniconda3}"

# Check if the Miniconda directory exists; if not, create
# it with all necessary parent directories.
test -d ${ROOT_MINICONDA} || mkdir -p ${ROOT_MINICONDA}

# Check if the Miniconda install script exists; if not,
# download it using wget and save it as install.sh in the
# Miniconda directory.
nlines=`wc -l ${ROOT_MINICONDA}/install.sh  | cut -d " " -f 1 `
if [ $nlines == 0 ];then
    echo "WARNING: something wrong with ${ROOT_MINICONDA}/install.sh"
    echo "         removing ${ROOT_MINICONDA}/install.sh"
    rm ${ROOT_MINICONDA}/install.sh
fi
test -f ${ROOT_MINICONDA}/install.sh \
    || wget $MINICONDA_URL \
            -O ${ROOT_MINICONDA}/install.sh

# Execute the Miniconda install script in batch mode (-b),
# allow updating an existing installation (-u), and
# specify the install prefix (-p) to the Miniconda directory.
bash ${ROOT_MINICONDA}/install.sh -b -u -p ${ROOT_MINICONDA}

# Initialize conda for the shell session, modifying the appropriate
# profile script.
${ROOT_MINICONDA}/bin/conda init

# Configure conda to not automatically activate the base environment
# when starting a shell.
${ROOT_MINICONDA}/bin/conda config --set auto_activate_base false
