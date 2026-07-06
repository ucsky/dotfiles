#!/usr/bin/env bash
#
# Validate bash syntax for all bash files and executable bits for entrypoints.
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

# Validate installer scripts under make/. Library files are syntax-checked but
# are not required to be executable because they are sourced by entrypoints.
for f in "$REPO_ROOT"/make/*.bash; do
  [ -e "$f" ] || continue
  case "$(basename "$f")" in
    lib_*.bash)
      ;;
    *)
      if [ ! -x "$f" ]; then
        echo "ERROR: not executable: $f" 1>&2
        fail=1
      fi
      ;;
  esac
  bash -n "$f" || fail=1
done

exit "$fail"
