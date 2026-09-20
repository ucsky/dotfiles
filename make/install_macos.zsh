#!/usr/bin/env zsh
#
# Description:
#   Minimal (bare) installation for macOS:
#   - Add sourcing lines to ~/.zshrc and ~/.zprofile
#
# Usage:
#   ./make/install_macos.zsh
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${(%):-%x}")/.." && pwd)"

line_rc="test -f \"$REPO_ROOT/configs/zsh/rc\" && source \"$REPO_ROOT/configs/zsh/rc\" # dotfiles"
line_profile="test -f \"$REPO_ROOT/configs/zsh/profile\" && source \"$REPO_ROOT/configs/zsh/profile\" # dotfiles"

touch "$HOME/.zshrc" "$HOME/.zprofile"

grep -qF "$REPO_ROOT/configs/zsh/rc" "$HOME/.zshrc" 2>/dev/null || echo "$line_rc" >> "$HOME/.zshrc"
grep -qF "$REPO_ROOT/configs/zsh/profile" "$HOME/.zprofile" 2>/dev/null || echo "$line_profile" >> "$HOME/.zprofile"

###############################################################################
# Always: git global config (via [include])
###############################################################################
touch "$HOME/.gitconfig"
if ! git config --global --get-all include.path 2>/dev/null | grep -qF "$REPO_ROOT/configs/git/gitconfig"; then
  git config --global --add include.path "$REPO_ROOT/configs/git/gitconfig"
  echo "INFO: git global config linked via [include]."
fi

echo "macOS install completed."

