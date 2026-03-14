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

stat_owner() {
  stat -c '%u' "$1" 2>/dev/null || stat -f '%u' "$1" 2>/dev/null
}

stat_mode() {
  stat -c '%a' "$1" 2>/dev/null || stat -f '%Lp' "$1" 2>/dev/null
}

is_safe_source_file() {
  local file="$1"
  local owner mode

  [ -f "$file" ] || return 1
  [ ! -L "$file" ] || return 1

  owner="$(stat_owner "$file" 2>/dev/null || true)"
  mode="$(stat_mode "$file" 2>/dev/null || true)"
  [ -n "$owner" ] || return 1
  [ -n "$mode" ] || return 1

  case "$owner" in
    0|"$(id -u)") ;;
    *) return 1 ;;
  esac

  if [ $((8#$mode & 18)) -ne 0 ]; then
    return 1
  fi
}

source_if_safe() {
  local file="$1"
  local quiet="${2:-}"

  if ! is_safe_source_file "$file"; then
    [ "$quiet" != "quiet" ] && echo "WARNING: refusing to source unsafe shell file: $file" 1>&2
    return 1
  fi

  # shellcheck disable=SC1090
  source "$file"
}

setup_venv() {
  local env_name="${NAME_PYTHON_VENV}"
  local venv_root="${HOME}/.venv"
  local venv_path="${venv_root}/${env_name}"
  mkdir -p "$venv_root"
  if [ ! -f "$venv_path/bin/activate" ]; then
    [ -d "$venv_path" ] && rm -rf "$venv_path"
    echo "Creating venv: $venv_path"
    if ! python3 -m venv "$venv_path"; then
      local py_ver
      py_ver=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || echo "3")
      echo "INFO: venv creation failed (ensurepip not available). On Debian/Ubuntu run: sudo apt install python${py_ver}-venv"
      echo "INFO: Skipping venv setup; install will continue. Run 'make install' again after installing the package."
      return 0
    fi
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
  local sourced=0
  local candidate
  for candidate in \
    "$HOME/.local/bin/virtualenvwrapper.sh" \
    /usr/local/bin/virtualenvwrapper.sh \
    /usr/share/virtualenvwrapper/virtualenvwrapper.sh; do
    if [ -f "$candidate" ] && source_if_safe "$candidate"; then
      sourced=1
      break
    fi
  done
  if [ "$sourced" -ne 1 ]; then
      set -u
      echo "INFO: virtualenvwrapper not found; skipping workon env setup."
      echo "INFO: Install virtualenvwrapper via pip and ensure the script is owner-only writable."
      return 0
  fi

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
  local conda_exe=""
  local skipped_unsafe=""

  # Ensure `conda` is available (source script only if safe; otherwise use conda binary).
  if command -v conda >/dev/null 2>&1; then
    conda_exe="conda"
    if conda info --base >/dev/null 2>&1; then
      local conda_base
      conda_base="$(conda info --base)"
      if [ -f "$conda_base/etc/profile.d/conda.sh" ]; then
        source_if_safe "$conda_base/etc/profile.d/conda.sh" quiet || skipped_unsafe="$conda_base/etc/profile.d/conda.sh"
      fi
    fi
  elif [ -f "$HOME/.miniconda3/etc/profile.d/conda.sh" ]; then
    if is_safe_source_file "$HOME/.miniconda3/etc/profile.d/conda.sh"; then
      # shellcheck disable=SC1090
      source "$HOME/.miniconda3/etc/profile.d/conda.sh"
      conda_exe="conda"
    else
      skipped_unsafe="$HOME/.miniconda3/etc/profile.d/conda.sh"
      [ -x "$HOME/.miniconda3/bin/conda" ] && conda_exe="$HOME/.miniconda3/bin/conda"
    fi
  elif [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
    if is_safe_source_file "$HOME/miniconda3/etc/profile.d/conda.sh"; then
      # shellcheck disable=SC1090
      source "$HOME/miniconda3/etc/profile.d/conda.sh"
      conda_exe="conda"
    else
      skipped_unsafe="$HOME/miniconda3/etc/profile.d/conda.sh"
      [ -x "$HOME/miniconda3/bin/conda" ] && conda_exe="$HOME/miniconda3/bin/conda"
    fi
  fi

  if [ -z "$conda_exe" ]; then
    if [ -n "$skipped_unsafe" ]; then
      echo "WARNING: refusing to source unsafe shell file: $skipped_unsafe (fix: chmod g-w,o-w \"\$CONDA_ROOT/etc/profile.d/conda.sh\")" 1>&2
    fi
    echo "INFO: conda not available; skipping conda env setup."
    return 0
  fi

  conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
  conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true

  if ! "$conda_exe" env list | grep -E "^${env_name}[[:space:]]+" >/dev/null 2>&1; then
    echo "Creating conda env: $env_name"
    "$conda_exe" create --name "$env_name" python=3.10 -y
  fi

  # Avoid `conda activate` (requires conda init). Use conda-run instead.
  "$conda_exe" run -n "$env_name" python -m pip install -q -U pip
  if ! "$conda_exe" run -n "$env_name" python -m pip install -q -r "$REPO_ROOT/requirements.txt"; then
    echo "INFO: conda env $env_name pip install reported issues (e.g. dependency conflicts); dotfiles install continues."
  fi
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
