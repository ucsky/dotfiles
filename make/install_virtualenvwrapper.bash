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

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=make/lib_pip.bash
source "$REPO_ROOT/make/lib_pip.bash"

if [ -n "${VIRTUAL_ENV:-}" ]; then
  echo "ERROR: a virtualenv is active (\$VIRTUAL_ENV=$VIRTUAL_ENV)." 1>&2
  echo "Run 'deactivate' first: 'pip install --user' does not work inside an active virtualenv." 1>&2
  exit 1
fi

command -v python3 >/dev/null 2>&1 || {
  echo "ERROR: python3 not found; cannot install virtualenvwrapper." 1>&2
  exit 1
}

# Print the first existing virtualenvwrapper.sh candidate; fail if none exists.
_find_virtualenvwrapper_sh() {
  local candidate
  while IFS= read -r candidate; do
    if [ -f "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done < <(virtualenvwrapper_candidates)
  return 1
}

# Report a successful install (and tighten permissions); fail if not found.
_report_virtualenvwrapper_installed() {
  local sh_path
  sh_path="$(_find_virtualenvwrapper_sh)" || return 1
  chmod go-w "$sh_path" 2>/dev/null || true
  echo "virtualenvwrapper installed: $sh_path"
  echo "Run 'make install' (or 'DOTFILES_PY_ENV=workon make startlab') to set up the workon env."
}

if sh_path="$(_find_virtualenvwrapper_sh)"; then
  echo "virtualenvwrapper already installed: $sh_path"
  exit 0
fi

if ! python3 -m pip --version >/dev/null 2>&1; then
  echo "INFO: pip module not found; bootstrapping via ensurepip --user..."
  python3 -m ensurepip --user >/dev/null || {
    echo "ERROR: pip is not available and ensurepip failed. On Debian/Ubuntu run: sudo apt install python3-pip" 1>&2
    exit 1
  }
fi

echo "Installing virtualenvwrapper via pip (--user)..."
_pip_install_fallback python3 --user -q -U pip
_pip_install_user_pkg python3 virtualenvwrapper

_report_virtualenvwrapper_installed && exit 0

# pip may report success without writing virtualenvwrapper.sh if it already
# considers the package "installed satisfied" (e.g. a prior run left the
# dist-info in place but the script file itself missing/deleted). Force a
# reinstall of just this package to make pip re-extract its data files.
echo "INFO: virtualenvwrapper.sh missing after install; forcing reinstall..." 1>&2
# Do not abort under `set -e`: fall through to the diagnostic warning below.
_pip_install_pep668 python3 --user -q --force-reinstall --no-deps virtualenvwrapper || true

_report_virtualenvwrapper_installed && exit 0

echo "WARNING: virtualenvwrapper installed via pip but virtualenvwrapper.sh was not found in expected locations." 1>&2
echo "Check your pip user-install script path (e.g. run: python3 -m site --user-base)." 1>&2
exit 1
