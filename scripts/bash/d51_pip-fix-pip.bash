#!/usr/bin/env bash
#
# Description:
#   Fix pip in a virtualenv using non-system Python.
#   See: https://stackoverflow.com/questions/49478573/
#
# Usage:
#   d51_pip-fix-pip.bash
#
set -euo pipefail

tmp="$(mktemp)"
cleanup() { rm -f "$tmp"; }
trap cleanup EXIT

curl -fsSL https://bootstrap.pypa.io/get-pip.py -o "$tmp"
python3 "$tmp" --force-reinstall
