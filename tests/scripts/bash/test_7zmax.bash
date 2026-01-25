#!/usr/bin/env bash
#
# Functional test for 7zmax (skips if 7z is unavailable).
#
set -euo pipefail

if ! command -v 7z >/dev/null 2>&1; then
  echo "Skipping: 7z not installed (install p7zip-full to run this test)."
  exit 0
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/bash/7zmax.bash"

test_file="$(mktemp)"
output_file="${test_file}.7z"
cleanup() { rm -f "$test_file" "$output_file"; }
trap cleanup EXIT

echo "This is a test file for compression." > "$test_file"

"$SCRIPT" "$test_file"

[ -f "$output_file" ] || { echo "ERROR: output file missing: $output_file" 1>&2; exit 1; }
[ -s "$output_file" ] || { echo "ERROR: output file is empty: $output_file" 1>&2; exit 1; }
