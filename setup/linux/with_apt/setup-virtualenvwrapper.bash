#!/bin/bash

# Test if workon is already installed
command -v workon >> /dev/null && HAS_WORKON=1 || HAS_WORKON=0
if [ $HAS_WORKON == 1 ];then
    echo "workon already installed"
    exit 0
fi

# List of packages to check and potentially install
packages=(
  python3-virtualenvwrapper
  virtualenvwrapper
  virtualenvwrapper-doc
)

# Function to check if a package is installed
is_package_installed() {
  dpkg -l "$1" &> /dev/null
}

# Loop through the list of packages and install them if they are missing
for package in "${packages[@]}"; do
  if ! is_package_installed "$package"; then
    echo "Installing package: $package"
    sudo apt install "$package" -y
  else
    echo "Package $package is already installed."
  fi
done


# Define the block of text to add to .bashrc
read -r -d '' VENVWRAPPER_CONFIG << 'EOF'
# START setup-virtualenvwrapper.bash
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/project
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
# END setup-virtualenvwrapper.bash
EOF

# Define the .bashrc file location
BASHRC="$HOME/.bashrc"


# Function to add or update the virtualenvwrapper configuration in .bashrc
update_bashrc() {
  # Check if the configuration block already exists in .bashrc
  if grep -q "# START setup-virtualenvwrapper.bash" "$BASHRC"; then
    # Configuration block exists, so it needs to be replaced
    # Delete the old block
    sed -i '/# START setup-virtualenvwrapper.bash/,/# END setup-virtualenvwrapper.bash/d' "$BASHRC"
  fi
  # Append the new block
  echo "$VENVWRAPPER_CONFIG" >> "$BASHRC"
}

# Call the update function
update_bashrc

