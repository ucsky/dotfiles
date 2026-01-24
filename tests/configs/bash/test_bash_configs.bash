#!/usr/bin/env bash
#
# Validate bash config files for syntax errors.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

bash -n "$REPO_ROOT/configs/bash/profile"
bash -n "$REPO_ROOT/configs/bash/rc"
