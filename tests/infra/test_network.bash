#!/usr/bin/env bash
#
# Simple network connectivity checks (non-flaky).
# This test should not fail in restricted environments; it is informational.
#
set -euo pipefail

if command -v getent >/dev/null 2>&1; then
  getent hosts github.com >/dev/null 2>&1 || true
fi

if command -v curl >/dev/null 2>&1; then
  curl -fsSL --max-time 5 https://example.com >/dev/null 2>&1 || true
fi

echo "Network checks completed."
