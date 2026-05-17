#!/usr/bin/env bash
#
# Description:
#   Wipe *all* Docker containers/images/volumes/networks and run system prune.
#   This is destructive. Use with extreme caution.
#
# Usage:
#   docker-wipe.bash
#
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker not found." 1>&2
  exit 1
fi

mapfile -t ALL_CONTAINERS < <(docker ps -qa || true)
echo "Stopping all containers ..."
if [ "${#ALL_CONTAINERS[@]}" -gt 0 ]; then
  docker stop "${ALL_CONTAINERS[@]}" || true
fi

echo "Removing all containers ..."
if [ "${#ALL_CONTAINERS[@]}" -gt 0 ]; then
  docker rm "${ALL_CONTAINERS[@]}" || true
fi

echo "Removing all images ..."
mapfile -t ALL_IMAGES < <(docker images -qa || true)
if [ "${#ALL_IMAGES[@]}" -gt 0 ]; then
  docker rmi -f "${ALL_IMAGES[@]}" || true
fi

echo "Removing all volumes ..."
mapfile -t ALL_VOLUMES < <(docker volume ls -q || true)
if [ "${#ALL_VOLUMES[@]}" -gt 0 ]; then
  docker volume rm "${ALL_VOLUMES[@]}" || true
fi
mapfile -t ALL_VOLUMES_DANGLING < <(docker volume ls -qf dangling=true || true)
if [ "${#ALL_VOLUMES_DANGLING[@]}" -gt 0 ]; then
  docker volume rm "${ALL_VOLUMES_DANGLING[@]}" || true
fi

echo "Removing all networks ..."
mapfile -t ALL_NETWORK < <(docker network ls -q || true)
if [ "${#ALL_NETWORK[@]}" -gt 0 ]; then
  set +e
  docker network rm "${ALL_NETWORK[@]}"
  set -e
fi

echo "Pruning system ..."
docker system prune --all --force

echo "Done."
