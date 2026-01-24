#!/usr/bin/env bash
#
# Description:
#   Kill all running Docker containers.
#
# Usage:
#   d51_docker-stop.bash
#
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "WARNING: docker not found." 1>&2
  exit 0
fi

running="$(docker ps -q)"
if [ -n "$running" ]; then
  docker kill $running
fi
