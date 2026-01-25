#!/usr/bin/env bash
#
# Description:
#   Export all historical versions of a file from a git repository.
#   Inspired by: https://stackoverflow.com/questions/12850030/
#
# Usage:
#   git-export-all-file-versions.bash <path/to/file>
#
set -euo pipefail

EXPORT_TO="${EXPORT_TO:-/tmp/all_versions_exported}"
GIT_PATH_TO_FILE="${1:-}"

USAGE="Usage: $(basename "$0") <path/to/file> (run from the git repo root)"

if [ -z "$GIT_PATH_TO_FILE" ]; then
  echo "ERROR: missing argument. $USAGE" 1>&2
  exit 1
fi

if [ ! -f "$GIT_PATH_TO_FILE" ]; then
  echo "ERROR: file '$GIT_PATH_TO_FILE' does not exist. $USAGE" 1>&2
  exit 1
fi

mkdir -p "$EXPORT_TO"

GIT_SHORT_FILENAME="$(basename "$GIT_PATH_TO_FILE")"

COUNT=0
git rev-list --all --objects -- "$GIT_PATH_TO_FILE" | cut -d ' ' -f1 | while read -r h; do
  COUNT=$((COUNT + 1))
  COUNT_PRETTY="$(printf "%04d" "$COUNT")"
  COMMIT_DATE="$(git show "$h" | head -3 | grep 'Date:' | awk '{print $4"-"$3"-"$6}' || true)"
  if [ -n "$COMMIT_DATE" ]; then
    git cat-file -p "${h}:${GIT_PATH_TO_FILE}" > "${EXPORT_TO}/${COUNT_PRETTY}.${COMMIT_DATE}.${h}.${GIT_SHORT_FILENAME}" || true
  fi
done

echo "Result stored to ${EXPORT_TO}"
