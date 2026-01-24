#!/usr/bin/env bash
#
# Compile all Python scripts to ensure syntax validity.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

python3 -m py_compile "$REPO_ROOT"/scripts/python3/*.py
