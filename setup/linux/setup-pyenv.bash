#!/bin/bash


# List of packages to check and potentially install
packages=(
    make
    build-essential
    libssl-dev
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    wget
    curl
    llvm
    libncurses5-dev
    libncursesw5-dev
    xz-utils
    tk-dev
    libffi-dev
    liblzma-dev
    git
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

test -d $HOME/.pyenv || curl https://pyenv.run | bash


# Define the block of text to add to .bashrc
read -r -d '' PYENV_CONFIG << 'EOF'
# START setup-pyenv.bash
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
# END setup-pyenv.bash
EOF

# Define the .bashrc file location
BASHRC="$HOME/.bashrc"


# Function to add or update the pyenv configuration in .bashrc
update_bashrc() {
  # Check if the configuration block already exists in .bashrc
  if grep -q "# START setup-pyenv.bash" "$BASHRC"; then
    # Configuration block exists, so it needs to be replaced
    # Delete the old block
    sed -i '/# START setup-pyenv.bash/,/# END setup-pyenv.bash/d' "$BASHRC"
  fi
  # Append the new block
  echo "$PYENV_CONFIG" >> "$BASHRC"
}

# Call the update function
update_bashrc

