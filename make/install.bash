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
NAME_PYTHON_VENV="${NAME_PYTHON_VENV:-dotfiles51}"

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

setup_venv() {
  local env_name="${NAME_PYTHON_VENV}"
  local venv_root="${HOME}/.venv"
  local venv_path="${venv_root}/${env_name}"
  mkdir -p "$venv_root"
  if [ ! -d "$venv_path" ]; then
    echo "Creating venv: $venv_path"
    python3 -m venv "$venv_path"
  fi
  # Install/update requirements (idempotent)
  # shellcheck disable=SC1090
  . "$venv_path/bin/activate"
  pip install -U pip
  pip install -r "$REPO_ROOT/requirements.txt"
  deactivate || true
}

setup_workon() {
  local env_name="${NAME_PYTHON_VENV}"
  export WORKON_HOME="${HOME}/.virtualenvs"

  if ! command -v workon >/dev/null 2>&1; then
    echo "INFO: virtualenvwrapper not available; skipping workon env setup."
    return 0
  fi

  # shellcheck disable=SC1091
  source /usr/share/virtualenvwrapper/virtualenvwrapper.sh 2>/dev/null \
    || source /usr/local/bin/virtualenvwrapper.sh 2>/dev/null \
    || source "$HOME/.local/bin/virtualenvwrapper.sh" 2>/dev/null \
    || true

  if ! command -v workon >/dev/null 2>&1; then
    echo "INFO: virtualenvwrapper init not found after sourcing; skipping workon env setup."
    return 0
  fi

  if ! workon "$env_name" >/dev/null 2>&1; then
    echo "Creating virtualenvwrapper env: $env_name"
    mkvirtualenv "$env_name"
  fi
  workon "$env_name"
  pip install -U pip
  pip install -r "$REPO_ROOT/requirements.txt"
  deactivate || true
}

setup_conda() {
  local env_name="${NAME_PYTHON_VENV}"

  # Ensure `conda` is available and functional in non-interactive shells.
  if command -v conda >/dev/null 2>&1; then
    if conda info --base >/dev/null 2>&1; then
      conda_base="$(conda info --base)"
      if [ -f "$conda_base/etc/profile.d/conda.sh" ]; then
        # shellcheck disable=SC1090
        source "$conda_base/etc/profile.d/conda.sh" || true
      fi
    fi
  elif [ -f "$HOME/.miniconda3/etc/profile.d/conda.sh" ]; then
    # shellcheck disable=SC1090
    source "$HOME/.miniconda3/etc/profile.d/conda.sh" || true
  elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    # shellcheck disable=SC1090
    source "$HOME/miniconda3/etc/profile.d/conda.sh" || true
  else
    echo "INFO: conda not available; skipping conda env setup."
    return 0
  fi

  if ! command -v conda >/dev/null 2>&1; then
    echo "INFO: conda still not available after sourcing; skipping conda env setup."
    return 0
  fi

  conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
  conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true

  if ! conda env list | grep -E "^${env_name}[[:space:]]+" >/dev/null 2>&1; then
    echo "Creating conda env: $env_name"
    conda create --name "$env_name" python=3.10 -y
  fi

  # Avoid `conda activate` (requires conda init). Use conda-run instead.
  conda run -n "$env_name" python -m pip install -U pip
  conda run -n "$env_name" python -m pip install -r "$REPO_ROOT/requirements.txt"
}

case "$os" in
  linux)
    if detect_wsl; then
      echo "Detected OS: linux (WSL) (HAS_ADMIN=$HAS_ADMIN)"
      bash "$REPO_ROOT/make/install_bare-mswin-wsl.bash"
    elif detect_vbox; then
      echo "Detected OS: linux (VirtualBox) (HAS_ADMIN=$HAS_ADMIN)"
      bash "$REPO_ROOT/make/install_vbox-ubuntu.bash"
    else
      echo "Detected OS: linux (HAS_ADMIN=$HAS_ADMIN)"
      bash "$REPO_ROOT/make/install_bare-ubuntu.bash"
    fi

    # Python environments setup (idempotent)
    setup_venv
    setup_workon || true
    setup_conda || true
    ;;
  darwin)
    echo "Detected OS: macOS"
    zsh "$REPO_ROOT/make/install_bare-macos.zsh"
    # Python environments setup (idempotent)
    setup_venv
    setup_workon || true
    setup_conda || true
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

