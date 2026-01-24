#!/usr/bin/env bash
#
# Description:
#   Install dotfiles by running the appropriate bare installer for the current OS,
#   then bootstrap developer tooling where possible.
#
# Usage:
#   ./make/install.bash
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check_admin() {
  # True if we can run privileged commands (root or passwordless sudo).
  if [ "$(id -u)" -eq 0 ]; then
    return 0
  fi
  if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

HAS_ADMIN=0
if check_admin; then
  HAS_ADMIN=1
fi
export HAS_ADMIN

os="$(uname -s | tr '[:upper:]' '[:lower:]')"

case "$os" in
  linux)
    echo "Detected OS: linux (HAS_ADMIN=$HAS_ADMIN)"
    bash "$REPO_ROOT/make/install_bare-linux.bash"

    # Tooling bootstrap (non-fatal if something is missing)
    (cd "$REPO_ROOT" && make setup-venv) || true
    (cd "$REPO_ROOT" && make setup-workon) || true
    (cd "$REPO_ROOT" && make setup-miniconda) || true
    ;;
  darwin)
    echo "Detected OS: macOS"
    zsh "$REPO_ROOT/make/install_bare-macos.zsh"
    ;;
  msys*|mingw*|cygwin*)
    echo "Detected OS: Windows (MSYS/MINGW/CYGWIN)"
    echo "Run: powershell -ExecutionPolicy Bypass -File make/install_bare-mswin.ps1"
    ;;
  *)
    echo "Unsupported OS: $os" 1>&2
    echo "Try the bare installer scripts under make/." 1>&2
    exit 1
    ;;
esac

