#!/usr/bin/env bash
#
# Validate zsh config files for syntax errors (if zsh is installed).
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

if ! command -v zsh >/dev/null 2>&1; then
  echo "Skipping: zsh not installed."
  exit 0
fi

zsh -n "$REPO_ROOT/configs/zsh/profile"
zsh -n "$REPO_ROOT/configs/zsh/rc"
