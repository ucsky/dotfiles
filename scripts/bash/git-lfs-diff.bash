#!/usr/bin/env bash
#
# Description:
#   Compare the working tree version of a Git LFS-tracked file with the version in HEAD.
#
# Usage:
#   gitlfsdiff <path/to/file>
#
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $(basename "$0") <path/to/file>" 1>&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git not found." 1>&2
  exit 1
fi

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "ERROR: not inside a git repository." 1>&2
  exit 1
fi

if ! command -v git-lfs >/dev/null 2>&1 && ! git lfs version >/dev/null 2>&1; then
  echo "ERROR: git-lfs not available." 1>&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
FILE_ABS="$(realpath "$1")"
FILE_REL="$(realpath --relative-to="$REPO_ROOT" "$FILE_ABS")"

if ! git ls-tree -r HEAD -- "$FILE_REL" >/dev/null 2>&1; then
  echo "ERROR: '$FILE_REL' does not exist in HEAD." 1>&2
  exit 1
fi

if ! git lfs ls-files | grep -F -q "$FILE_REL"; then
  echo "ERROR: '$FILE_REL' is not tracked by Git LFS." 1>&2
  exit 1
fi

HEAD_TMP="$(mktemp)"
cleanup() { rm -f "$HEAD_TMP"; }
trap cleanup EXIT

if ! git show "HEAD:$FILE_REL" | git lfs smudge >"$HEAD_TMP" 2>/dev/null; then
  echo "ERROR: failed to retrieve '$FILE_REL' from HEAD." 1>&2
  exit 1
fi

if file "$FILE_ABS" | grep -qi "text"; then
  diff -u "$HEAD_TMP" "$FILE_ABS"
else
  diff <(xxd "$HEAD_TMP") <(xxd "$FILE_ABS")
fi
