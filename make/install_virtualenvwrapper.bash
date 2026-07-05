#!/usr/bin/env bash
#
# Description:
#   Install virtualenvwrapper for the current user (userland-only, no admin
#   privileges required). Idempotent: skips if already installed.
#
# Usage:
#   ./make/install_virtualenvwrapper.bash
#
set -euo pipefail

candidates=(
  "$HOME/.local/bin/virtualenvwrapper.sh"
  /usr/local/bin/virtualenvwrapper.sh
  /usr/share/virtualenvwrapper/virtualenvwrapper.sh
)

for candidate in "${candidates[@]}"; do
  if [ -f "$candidate" ]; then
    echo "virtualenvwrapper already installed: $candidate"
    exit 0
  fi
done

command -v python3 >/dev/null 2>&1 || {
  echo "ERROR: python3 not found; cannot install virtualenvwrapper." 1>&2
  exit 1
}

if ! python3 -m pip --version >/dev/null 2>&1; then
  echo "INFO: pip module not found; bootstrapping via ensurepip --user..."
  python3 -m ensurepip --user >/dev/null || {
    echo "ERROR: pip is not available and ensurepip failed. On Debian/Ubuntu run: sudo apt install python3-pip" 1>&2
    exit 1
  }
fi

echo "Installing virtualenvwrapper via pip (--user)..."
python3 -m pip install --user -q -U pip
python3 -m pip install --user -q virtualenvwrapper

for candidate in "${candidates[@]}"; do
  if [ -f "$candidate" ]; then
    chmod go-w "$candidate" 2>/dev/null || true
    echo "virtualenvwrapper installed: $candidate"
    echo "Run 'make install' (or 'DOTFILES_PY_ENV=workon make startlab') to set up the workon env."
    exit 0
  fi
done

echo "WARNING: virtualenvwrapper installed via pip but virtualenvwrapper.sh was not found in expected locations." 1>&2
echo "Check your pip user-install script path (e.g. run: python3 -m site --user-base)." 1>&2
exit 1
