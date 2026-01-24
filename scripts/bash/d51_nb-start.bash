#!/usr/bin/env bash
#
# Description:
#   Start Jupyter Notebook (delegates to scripts/python3/d51_nb-start.py).
#
# Usage:
#   d51_nb-start [extra jupyter notebook args...]
#
set -euo pipefail

ROOT_DOTFILES="${ROOT_DOTFILES:-$HOME/.dotfiles}"
exec python3 "$ROOT_DOTFILES/scripts/python3/d51_nb-start.py" "$@"
