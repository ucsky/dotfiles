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

if rg -n 'HOME/micromamba\b' "$REPO_ROOT/Makefile" "$REPO_ROOT/make/install.bash" >/dev/null 2>&1; then
  echo "ERROR: micromamba defaults must use the dotted \$HOME/.micromamba, not \$HOME/micromamba." 1>&2
  exit 1
fi

for wf in "$REPO_ROOT"/.github/workflows/*.yml "$REPO_ROOT"/.github/workflows/*.yaml; do
  [ -e "$wf" ] || continue
  if ! grep -Eq '^permissions:' "$wf"; then
    echo "ERROR: $(basename "$wf") must declare top-level 'permissions:' (least privilege)." 1>&2
    exit 1
  fi
  # Third-party actions must be pinned to a full commit SHA (tags are mutable).
  # Local actions (./path) and docker:// references are exempt.
  unpinned="$(grep -En '^[[:space:]]*(-[[:space:]]+)?uses:[[:space:]]' "$wf" \
    | grep -Ev 'uses:[[:space:]]*["'\'']?(\./|docker://)' \
    | grep -Ev 'uses:[[:space:]]*["'\'']?[^@[:space:]]+@[0-9a-f]{40}([[:space:]"'\'']|$)' || true)"
  if [ -n "$unpinned" ]; then
    echo "ERROR: $(basename "$wf") has actions not pinned to a full commit SHA:" 1>&2
    echo "$unpinned" 1>&2
    exit 1
  fi
done

echo "Repository security checks passed."
