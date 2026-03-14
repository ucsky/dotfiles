#!/usr/bin/env bash
#
# Repository security regression checks.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if rg -n 'eval[[:space:]]+"\\$cmd"' "$REPO_ROOT/scripts/bash/mset-get-info.bash" >/dev/null 2>&1; then
  echo "ERROR: mset-get-info.bash must not use eval." 1>&2
  exit 1
fi

if rg -n 'export \$\(grep -v' "$REPO_ROOT/configs/bash/rc" >/dev/null 2>&1; then
  echo "ERROR: configs/bash/rc still uses unsafe dotenv loading." 1>&2
  exit 1
fi

if ! grep -F 'DOTFILES_INSTALL_MINICONDA:-0' "$REPO_ROOT/make/install_linux.bash" >/dev/null 2>&1; then
  echo "ERROR: Miniconda install must be opt-in." 1>&2
  exit 1
fi

if rg -n 'proceeding without verification' "$REPO_ROOT/make/install_linux.bash" >/dev/null 2>&1; then
  echo "ERROR: install_linux.bash must not run unverified installers." 1>&2
  exit 1
fi

if rg -n -v '^([A-Za-z0-9._-]+==[^#[:space:]]+)([[:space:]]+#.*)?$|^[[:space:]]*$' \
  "$REPO_ROOT/requirements.txt" >/dev/null 2>&1; then
  echo "ERROR: requirements.txt must contain only exact pins." 1>&2
  exit 1
fi

echo "Repository security checks passed."
