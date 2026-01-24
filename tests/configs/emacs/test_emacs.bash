#!/usr/bin/env bash
#
# Smoke-test the Emacs configuration by loading it in batch mode.
#
set -euo pipefail

if ! command -v emacs >/dev/null 2>&1; then
  echo "Skipping: emacs not installed."
  exit 0
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
CONFIG_FILE="$REPO_ROOT/configs/emacs/emacs"

emacs --batch \
  -l "$CONFIG_FILE" \
  --eval "(progn (message \"Configuration loaded successfully.\") (kill-emacs 0))" \
  >/dev/null
