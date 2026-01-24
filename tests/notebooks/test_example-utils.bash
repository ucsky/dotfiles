#!/usr/bin/env bash
#
# Execute the example notebook via papermill (skips if papermill missing).
#
set -euo pipefail

if ! command -v papermill >/dev/null 2>&1; then
  echo "Skipping: papermill not installed."
  exit 0
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
NB_IN="$REPO_ROOT/notebooks/example-utils.ipynb"
NB_OUT="$(mktemp --suffix=.ipynb)"

cleanup() { rm -f "$NB_OUT"; }
trap cleanup EXIT

papermill "$NB_IN" "$NB_OUT" -p name "test"
