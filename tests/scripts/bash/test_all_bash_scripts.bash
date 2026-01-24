#!/usr/bin/env bash
#
# Validate all bash scripts for syntax errors and executable bit.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

fail=0
for f in "$REPO_ROOT"/scripts/bash/*; do
  [ -e "$f" ] || continue
  if [ ! -x "$f" ]; then
    echo "ERROR: not executable: $f" 1>&2
    fail=1
  fi
  bash -n "$f" || fail=1
done

# Validate installer scripts under make/
for f in "$REPO_ROOT"/make/*.bash; do
  [ -e "$f" ] || continue
  if [ ! -x "$f" ]; then
    echo "ERROR: not executable: $f" 1>&2
    fail=1
  fi
  bash -n "$f" || fail=1
done

exit "$fail"
