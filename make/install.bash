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

detect_wsl() {
  # WSL exposes these markers in most versions.
  if [ -n "${WSL_INTEROP:-}" ] || [ -n "${WSL_DISTRO_NAME:-}" ]; then
    return 0
  fi
  if [ -r /proc/version ] && grep -qi "microsoft" /proc/version; then
    return 0
  fi
  return 1
}

detect_gitbash() {
  case "$(uname -s 2>/dev/null || true)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
  esac
  return 1
}

detect_vbox() {
  # Prefer systemd-detect-virt, otherwise check DMI strings.
  if command -v systemd-detect-virt >/dev/null 2>&1; then
    if systemd-detect-virt -v 2>/dev/null | grep -qiE 'oracle|vbox|virtualbox'; then
      return 0
    fi
  fi
  if [ -r /sys/class/dmi/id/product_name ] && grep -qi "virtualbox" /sys/class/dmi/id/product_name; then
    return 0
  fi
  if [ -r /sys/class/dmi/id/sys_vendor ] && grep -qi "oracle" /sys/class/dmi/id/sys_vendor; then
    return 0
  fi
  return 1
}

os="$(uname -s | tr '[:upper:]' '[:lower:]')"

case "$os" in
  linux)
    if detect_wsl; then
      echo "Detected OS: linux (WSL) (HAS_ADMIN=$HAS_ADMIN)"
      bash "$REPO_ROOT/make/install_bare-mswin-wsl.bash"
    elif detect_vbox; then
      echo "Detected OS: linux (VirtualBox) (HAS_ADMIN=$HAS_ADMIN)"
      bash "$REPO_ROOT/make/install_vbox-linux.bash"
    else
      echo "Detected OS: linux (HAS_ADMIN=$HAS_ADMIN)"
      bash "$REPO_ROOT/make/install_bare-linux.bash"
    fi

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
    if detect_gitbash; then
      bash "$REPO_ROOT/make/install_bare-mswin-gitbash.bash"
    else
      echo "Detected OS: Windows (MSYS/MINGW/CYGWIN)"
      echo "Run: powershell -ExecutionPolicy Bypass -File make/install_bare-mswin.ps1"
    fi
    ;;
  *)
    echo "Unsupported OS: $os" 1>&2
    echo "Try the bare installer scripts under make/." 1>&2
    exit 1
    ;;
esac

