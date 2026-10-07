#!/usr/bin/env bash
#
# Description:
#   Shared pip/virtualenvwrapper helpers sourced by make/install.bash and
#   make/install_virtualenvwrapper.bash. Defines functions only; no side
#   effects on source.
#

# Run `pip install` with the given args, retrying with --break-system-packages
# if the system Python refuses due to PEP 668 (externally-managed-environment),
# e.g. Debian 12+/Ubuntu 23.04+.
_pip_install_pep668() {
  local pip_exe="$1"
  shift
  local output
  if output=$("$pip_exe" -m pip install "$@" 2>&1); then
    return 0
  fi
  if printf '%s' "$output" | grep -q "externally-managed-environment"; then
    echo "INFO: system Python is externally managed (PEP 668); retrying with --break-system-packages..." 1>&2
    if output=$("$pip_exe" -m pip install --break-system-packages "$@" 2>&1); then
      return 0
    fi
  fi
  echo "$output" 1>&2
  return 1
}

_pip_install_fallback() {
  local pip_exe="$1"
  shift
  if _pip_install_pep668 "$pip_exe" "$@" >/dev/null 2>&1; then
    return 0
  fi
  # Fallback for pip bug with JSON API (common in pip<25 on Python 3.12+):
  # download wheel directly via urllib (which works in this env) and install locally.
  local tmpdir
  tmpdir="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf '$tmpdir'" RETURN
  local url
  url="$("$pip_exe" -c "
import json, urllib.request, re
data = json.loads(urllib.request.urlopen(
    urllib.request.Request('https://pypi.org/simple/pip/',
    headers={'Accept': 'application/vnd.pypi.simple.v1+json'})).read())
wheels = [f for f in data['files'] if f['filename'].endswith('-py3-none-any.whl')]
print(sorted(wheels, key=lambda x: [int(p) for p in re.findall(r'\d+', x['filename'])], reverse=True)[0]['url'])
")" || true
  [ -n "$url" ] || return 1
  local whl_name="${url##*/}"
  local whl_path="$tmpdir/$whl_name"
  "$pip_exe" -c "
import urllib.request
urllib.request.urlretrieve('$url', '$whl_path')
" && _pip_install_pep668 "$pip_exe" --no-index "$whl_path"
}

# Install a package with `pip install --user`, with PEP 668 retry.
_pip_install_user_pkg() {
  local pip_exe="$1"
  shift
  _pip_install_pep668 "$pip_exe" --user -q "$@"
}

# Paths where `pip install --user` may place virtualenvwrapper.sh, across
# Linux and macOS Python layouts (the user-base bin dir varies by platform).
virtualenvwrapper_candidates() {
  echo "$HOME/.local/bin/virtualenvwrapper.sh"
  echo "/usr/local/bin/virtualenvwrapper.sh"
  echo "/usr/share/virtualenvwrapper/virtualenvwrapper.sh"
  if command -v python3 >/dev/null 2>&1; then
    local user_base
    user_base="$(python3 -m site --user-base 2>/dev/null || true)"
    [ -n "$user_base" ] && echo "$user_base/bin/virtualenvwrapper.sh"
  fi
}

# Succeed if $1 is a usable venv whose activation really selects its own
# interpreter. Venvs are not relocatable: if $HOME moved since creation,
# `activate` and console-script shebangs still point at the old path, so
# `python` silently resolves to the system interpreter (PEP 668 errors).
venv_is_healthy() {
  local venv="$1"
  [ -x "$venv/bin/python" ] && [ -f "$venv/bin/activate" ] || return 1
  "$venv/bin/python" -c 'import sys; raise SystemExit(sys.prefix == sys.base_prefix)' >/dev/null 2>&1 || return 1
  (
    set +eu
    unset VIRTUAL_ENV
    # shellcheck disable=SC1090,SC1091
    . "$venv/bin/activate" >/dev/null 2>&1
    resolved="$(command -v python)" || exit 1
    [ "$(cd "$(dirname "$resolved")" && pwd -P)" = "$(cd "$venv/bin" && pwd -P)" ]
  )
}

# Install requirements into venv $1 using its own interpreter explicitly
# (never relies on PATH, so it can never fall through to system Python).
venv_install_requirements() {
  local venv="$1"
  local requirements="$2"
  local py="$venv/bin/python"
  if ! venv_is_healthy "$venv"; then
    echo "WARNING: refusing to pip install into unhealthy venv: $venv" 1>&2
    return 1
  fi
  _pip_install_fallback "$py" -q -U pip \
    || echo "WARNING: pip self-upgrade failed in $venv; continuing with current pip." 1>&2
  if ! "$py" -m pip install -q -r "$requirements"; then
    echo "WARNING: requirements install failed in $venv." 1>&2
    return 1
  fi
}
