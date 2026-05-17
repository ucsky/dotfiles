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

###############################################################################
# Optional: VS Code config (if code is available)
###############################################################################
install_vscode_config() {
  if ! command -v code >/dev/null 2>&1; then
    echo "INFO: VS Code (code) not found; skipping VS Code config setup."
    return 0
  fi

  local vscode_user_dir="$HOME/Library/Application Support/Code/User"
  mkdir -p "$vscode_user_dir"

  for cfg in settings.json keybindings.json; do
    local src="$REPO_ROOT/configs/vscode/$cfg"
    local dst="$vscode_user_dir/$cfg"
    if [ ! -f "$dst" ] && [ ! -L "$dst" ]; then
      ln -s "$src" "$dst"
      echo "INFO: VS Code $cfg linked."
    else
      echo "INFO: VS Code $cfg already exists; skipping (remove manually to re-link)."
    fi
  done

  if [ -f "$REPO_ROOT/configs/vscode/extensions.txt" ]; then
    echo "INFO: Installing VS Code extensions..."
    grep -v '^\s*#' "$REPO_ROOT/configs/vscode/extensions.txt" | grep -v '^\s*$' | while read -r ext; do
      code --install-extension "$ext" --force >/dev/null 2>&1 && echo "  installed: $ext" || echo "  WARNING: failed to install $ext"
    done
  fi
}
install_vscode_config || true

echo "macOS install completed."

