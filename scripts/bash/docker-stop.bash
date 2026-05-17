#!/usr/bin/env bash
#
# Description:
#   Kill all running Docker containers.
#
# Usage:
#   docker-stop.bash
#
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "WARNING: docker not found." 1>&2
  exit 0
fi

mapfile -t running < <(docker ps -q)
if [ "${#running[@]}" -gt 0 ]; then
  docker kill "${running[@]}"
fi
