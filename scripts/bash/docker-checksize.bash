#!/usr/bin/env bash
#
# Description:
#   Lists disk usage of items under /var/lib/docker in a human-readable format.
#
# Usage:
#   docker-checksize.bash [help]
#
set -euo pipefail

help() {
  sed -n '/^#!/,/^##/p' "$0" | grep -v '^#!\|^##'
}

if [ "${1:-}" = "help" ]; then
  help
  exit 0
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "WARNING: docker not found on $(hostname)." 1>&2
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "WARNING: docker daemon is not running or not accessible." 1>&2
  exit 0
fi

if [ ! -d /var/lib/docker ]; then
  echo "WARNING: /var/lib/docker does not exist." 1>&2
  exit 0
fi

if [ ! -r /var/lib/docker ]; then
  echo "WARNING: insufficient permissions to access /var/lib/docker" 1>&2
  exit 0
fi

pushd /var/lib/docker >/dev/null || {
  echo "WARNING: cannot access /var/lib/docker" 1>&2
  exit 0
}

for i in *; do
  [ -e "$i" ] || continue
  du -sh "$i"
done

popd >/dev/null

##
