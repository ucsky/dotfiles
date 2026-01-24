#!/usr/bin/env bash
#
# Description:
#   Bare installation for Linux:
#   - Configure bash to source dotfiles configs
#   - Optionally install packages via apt (if admin privileges are available)
#   - Optionally install userland tools (yq, miniconda) without requiring admin
#
# Usage:
#   ./make/install_bare-linux.bash
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check_admin() {
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

HAS_APT=0
if command -v apt >/dev/null 2>&1; then
  HAS_APT=1
fi

echo "Linux bare install (HAS_ADMIN=$HAS_ADMIN, HAS_APT=$HAS_APT)"

# Always: shell integration
bash "$REPO_ROOT/make/linux/setup-bash.bash"

# Optional: git aliases (env-controlled)
bash "$REPO_ROOT/make/linux/setup-git.bash" || true

# Optional: apt installs (non-fatal if no admin)
if [ "$HAS_ADMIN" = "1" ] && [ "$HAS_APT" = "1" ]; then
  bash "$REPO_ROOT/make/linux/with_apt/setup-emacs.bash" || true
  bash "$REPO_ROOT/make/linux/with_apt/setup-virtualenvwrapper.bash" || true
else
  echo "Admin or apt not available; skipping apt-based installs."
fi

# Optional: userland installs (non-fatal)
bash "$REPO_ROOT/make/linux/with_bin/setup-yq.bash" || true
bash "$REPO_ROOT/make/linux/with_bin/setup-miniconda.bash" || true

echo "Bare install completed."

