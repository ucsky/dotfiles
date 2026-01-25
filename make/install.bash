#!/usr/bin/env bash
#
# Description:
#   Install dotfiles by running the appropriate installer for the current OS,
#   then bootstrap developer tooling where possible.
#   This installer is userland-only and does not require admin privileges.
#
# Usage:
#   ./make/install.bash
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME_PYTHON_VENV="${NAME_PYTHON_VENV:-dotfiles51}"

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
  python -m pip install -q -U pip
  python -m pip install -q -r "$REPO_ROOT/requirements.txt"
  deactivate || true
}

setup_workon() {
  local env_name="${NAME_PYTHON_VENV}"
  export WORKON_HOME="${HOME}/.virtualenvs"
  # virtualenvwrapper scripts are often NOT compatible with `set -u` (nounset).
  # Disable nounset for the whole setup_workon section and re-enable on exit.
  set +u

  # virtualenvwrapper provides `workon`/`mkvirtualenv` as shell functions.
  # Do NOT check `command -v workon` before sourcing, or it may appear "missing".
  # Userland-only: check userland paths first, then system paths as fallback.
  #
  # shellcheck disable=SC1091
  source "$HOME/.local/bin/virtualenvwrapper.sh" 2>/dev/null \
    || source /usr/local/bin/virtualenvwrapper.sh 2>/dev/null \
    || source /usr/share/virtualenvwrapper/virtualenvwrapper.sh 2>/dev/null \
    || {
      set -u
      echo "INFO: virtualenvwrapper not found; skipping workon env setup."
      echo "INFO: Install virtualenvwrapper via pip: pip install virtualenvwrapper"
      return 0
    }

  if ! command -v workon >/dev/null 2>&1; then
    set -u
    echo "INFO: virtualenvwrapper init not found after sourcing; skipping workon env setup."
    return 0
  fi
  if ! command -v mkvirtualenv >/dev/null 2>&1; then
    set -u
    echo "INFO: mkvirtualenv not available after sourcing; skipping workon env setup."
    return 0
  fi

  # Determine whether the env exists without relying on `workon` return codes.
  if [ ! -d "${WORKON_HOME}/${env_name}" ]; then
    echo "Creating virtualenvwrapper env: $env_name"
    mkvirtualenv "$env_name" >/dev/null 2>&1 || {
      set -u
      echo "WARNING: failed to create virtualenvwrapper env '$env_name'; skipping."
      return 0
    }
  fi

  # `set -e` can be brittle with `workon` in non-interactive shells; guard explicitly.
  set +e
  workon "$env_name" >/dev/null 2>&1
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    set -u
    echo "WARNING: failed to activate virtualenvwrapper env '$env_name' (rc=$rc); skipping."
    return 0
  fi
  python -m pip install -q -U pip
  python -m pip install -q -r "$REPO_ROOT/requirements.txt"
  deactivate || true
  set -u
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
  conda run -n "$env_name" python -m pip install -q -U pip
  conda run -n "$env_name" python -m pip install -q -r "$REPO_ROOT/requirements.txt"
}

case "$os" in
  linux)
    echo "Detected OS: linux (userland-only)"
    bash "$REPO_ROOT/make/install_linux.bash"
    # Python environments setup (idempotent)
    setup_venv
    setup_workon || true
    setup_conda || true
    ;;
  darwin)
    echo "Detected OS: macOS"
    zsh "$REPO_ROOT/make/install_macos.zsh"
    # Python environments setup (idempotent)
    setup_venv
    setup_workon || true
    setup_conda || true
    ;;
  msys*|mingw*|cygwin*)
    echo "Detected OS: Windows (MSYS/MINGW/CYGWIN)"
    echo "Run: powershell -ExecutionPolicy Bypass -File make/install_mswin.ps1"
    ;;
  *)
    echo "Unsupported OS: $os" 1>&2
    echo "Try the installer scripts under make/." 1>&2
    exit 1
    ;;
esac

