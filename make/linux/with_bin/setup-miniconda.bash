#!/usr/bin/env bash
#
# Description:
#   Miniconda installation script (Linux).
#
set -euo pipefail

MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"

if command -v conda >/dev/null 2>&1; then
  echo "conda already installed"
  exit 0
fi

ROOT_MINICONDA="${ROOT_MINICONDA:-$HOME/.miniconda3}"
mkdir -p "$ROOT_MINICONDA"

installer="$ROOT_MINICONDA/install.sh"

if [ -f "$installer" ] && [ "$(wc -l "$installer" | awk '{print $1}')" -eq 0 ]; then
  echo "WARNING: empty installer at $installer, removing."
  rm -f "$installer"
fi

if [ ! -f "$installer" ]; then
  if command -v wget >/dev/null 2>&1; then
    wget "$MINICONDA_URL" -O "$installer"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "$MINICONDA_URL" -o "$installer"
  else
    echo "WARNING: neither wget nor curl found; cannot download miniconda." 1>&2
    exit 0
  fi
fi

bash "$installer" -b -u -p "$ROOT_MINICONDA"

"$ROOT_MINICONDA/bin/conda" init || true
"$ROOT_MINICONDA/bin/conda" config --set auto_activate_base false || true
