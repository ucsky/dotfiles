#!/bin/bash
#
# This pre-commit hook clears output cells in Jupyter notebooks.

# bash strict mode
set -o errexit
set -o pipefail
set -o nounset

IFS=$'\n\t'

# Collect staged files (NUL-delimited for safety)
STAGED=()
while IFS= read -r -d '' f; do
  STAGED+=("$f")
done < <(git diff --cached --name-only -z --diff-filter=ACMR)

IPYNB_FILES=()
for f in "${STAGED[@]}"; do
  case "$f" in
    *.ipynb|*.IPYNB) IPYNB_FILES+=("$f") ;;
  esac
done

if [ "${#IPYNB_FILES[@]}" -eq 0 ]; then
  exit 0
fi

if ! command -v jupyter >/dev/null 2>&1; then
  echo "ERROR: 'jupyter' is required to clean notebook outputs." 1>&2
  echo "Install it (e.g. 'make setup-venv') and retry the commit." 1>&2
  exit 1
fi

for file in "${IPYNB_FILES[@]}"; do
  echo "Clearing outputs in: $file"
  jupyter nbconvert --ClearOutputPreprocessor.enabled=True --clear-output --inplace "$file"
  git add "$file"
done

exit 0
