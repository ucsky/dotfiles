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

ALL_CONTAINERS="$(docker ps -qa || true)"
echo "Stopping all containers ..."
test -n "${ALL_CONTAINERS}" && docker stop ${ALL_CONTAINERS} || true

echo "Removing all containers ..."
test -n "${ALL_CONTAINERS}" && docker rm ${ALL_CONTAINERS} || true

echo "Removing all images ..."
ALL_IMAGES="$(docker images -qa || true)"
test -n "${ALL_IMAGES}" && docker rmi -f ${ALL_IMAGES} || true

echo "Removing all volumes ..."
ALL_VOLUMES="$(docker volume ls -q || true)"
test -n "${ALL_VOLUMES}" && docker volume rm ${ALL_VOLUMES} || true
ALL_VOLUMES_DANGLING="$(docker volume ls -qf dangling=true || true)"
test -n "${ALL_VOLUMES_DANGLING}" && docker volume rm ${ALL_VOLUMES_DANGLING} || true

echo "Removing all networks ..."
ALL_NETWORK="$(docker network ls -q || true)"
if [ -n "${ALL_NETWORK}" ]; then
  set +e
  docker network rm ${ALL_NETWORK}
  set -e
fi

echo "Pruning system ..."
docker system prune --all --force

echo "Done."
