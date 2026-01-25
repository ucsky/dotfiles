#!/usr/bin/env bash
#
# Description:
#   Start Jupyter Notebook (delegates to scripts/python3/nb-start.py).
#
# Usage:
#   nb-start [extra jupyter notebook args...]
#
set -euo pipefail

ROOT_DOTFILES="${ROOT_DOTFILES:-$HOME/.dotfiles}"
exec python3 "$ROOT_DOTFILES/scripts/python3/nb-start.py" "$@"
