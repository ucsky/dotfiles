#!/usr/bin/env bash
#
# Description:
#   Uninstall dotfiles shell integration by removing the lines added by installers.
#   This is safe and idempotent (it does not delete user data by default).
#
# Usage:
#   ./make/uninstall.bash
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

remove_line() {
  local file="$1"
  local pattern="$2"
  if [ -f "$file" ]; then
    local tmp
    tmp="$(mktemp)"
    grep -F -v "$pattern" "$file" > "$tmp" && mv "$tmp" "$file" || rm -f "$tmp"
  fi
}

remove_line "$HOME/.bashrc"   "$REPO_ROOT/configs/bash/rc"
remove_line "$HOME/.profile"  "$REPO_ROOT/configs/bash/profile"
remove_line "$HOME/.zshrc"    "$REPO_ROOT/configs/zsh/rc"
remove_line "$HOME/.zprofile" "$REPO_ROOT/configs/zsh/profile"
remove_line "$HOME/.emacs"    "$REPO_ROOT/configs/emacs/emacs"

git config --global --unset-all include.path "$REPO_ROOT/configs/git/gitconfig" 2>/dev/null || true

echo "Uninstall completed (shell init lines removed where present)."
