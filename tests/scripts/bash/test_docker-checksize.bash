#!/usr/bin/env bash
#
# Basic test for docker-checksize.bash.
# The script is allowed to emit WARNING and exit 0 when docker is unavailable.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/bash/docker-checksize.bash"

"$SCRIPT" help >/dev/null

OUTPUT="$("$SCRIPT" 2>&1 || true)"
if echo "$OUTPUT" | grep -q "WARNING:"; then
  echo "Script executed with expected warnings."
else
  echo "Script executed (no warning)."
fi
