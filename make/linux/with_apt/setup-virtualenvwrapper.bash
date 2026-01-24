#!/usr/bin/env bash
#
# Description:
#   Install and configure virtualenvwrapper via apt (Linux).
#   If admin/apt is not available, this script prints a message and exits successfully.
#
set -euo pipefail

if command -v workon >/dev/null 2>&1; then
  echo "workon already installed"
  exit 0
fi

if [ "${HAS_ADMIN:-0}" != "1" ]; then
  echo "No admin privileges available; skipping apt installs (virtualenvwrapper)."
  exit 0
fi

if ! command -v apt >/dev/null 2>&1; then
  echo "apt not available; skipping apt installs (virtualenvwrapper)."
  exit 0
fi

packages=(
  python3-virtualenvwrapper
  virtualenvwrapper
  virtualenvwrapper-doc
)

is_package_installed() {
  dpkg -l "$1" &>/dev/null
}

for package in "${packages[@]}"; do
  if ! is_package_installed "$package"; then
    echo "Installing package: $package"
    sudo apt install -y "$package" || true
  else
    echo "Package $package is already installed."
  fi
done

read -r -d '' VENVWRAPPER_CONFIG << 'EOF'
# START setup-virtualenvwrapper.bash
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/project
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
# END setup-virtualenvwrapper.bash
EOF

BASHRC="$HOME/.bashrc"
touch "$BASHRC"

if grep -q "# START setup-virtualenvwrapper.bash" "$BASHRC"; then
  sed -i '/# START setup-virtualenvwrapper.bash/,/# END setup-virtualenvwrapper.bash/d' "$BASHRC" || true
fi
echo "$VENVWRAPPER_CONFIG" >> "$BASHRC"

