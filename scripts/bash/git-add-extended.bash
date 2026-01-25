#!/usr/bin/env bash
#
# Description:
#   `git add` helper with notebook hygiene:
#   - If the file is a Jupyter notebook, clear outputs before staging.
#
# Usage:
#   git-add-extended.bash <path>
#
set -euo pipefail

FILE="${1:-}"
if [ -z "$FILE" ]; then
  echo "ERROR: missing <path> argument" 1>&2
  exit 1
fi

ext="${FILE##*.}"
if [ "$ext" = "ipynb" ]; then
  if ! command -v jupyter >/dev/null 2>&1; then
    echo "ERROR: 'jupyter' not found; cannot clear notebook outputs." 1>&2
    exit 1
  fi
  jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace "$FILE"
fi

git add "$FILE"
