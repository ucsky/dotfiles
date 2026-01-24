#!/usr/bin/env bash
#
# Description:
#   Optional git aliases setup.
#
# This modifies the user's global git config. It is disabled by default.
# Enable it by exporting:
#   DOTFILES_SETUP_GIT_ALIASES=1
#
set -euo pipefail

if [ "${DOTFILES_SETUP_GIT_ALIASES:-0}" != "1" ]; then
  echo "Skipping git aliases (set DOTFILES_SETUP_GIT_ALIASES=1 to enable)."
  exit 0
fi

git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

