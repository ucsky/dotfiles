#!/bin/bash
set -e
set +v

ALL_CONTAINERS="$(docker ps -qa)"
echo "Stoping all containers ..."
test -n "${ALL_CONTAINERS}" && docker stop ${ALL_CONTAINERS}

echo "Removing all containers ..."
test -n "${ALL_CONTAINERS}" && docker rm ${ALL_CONTAINERS}

echo "Removing all images ..."
ALL_IMAGES="$(docker images -qa)"
test -n "${ALL_IMAGES}" && docker rmi -f ${ALL_IMAGES}

echo "Remove all volumes ..."
ALL_VOLUMES=$(docker volume ls -q)
test -n "$ALL_VOLUMES" && docker volume rm ${ALL_VOLUMES}
ALL_VOLUMES=$(docker volume ls -qf dangling=true)
test -n "$ALL_VOLUMES" && docker volume rm ${ALL_VOLUMES}

echo "Removing all networks ..."
ALL_NETWORK=$(docker network ls -q)
set +e
test -n "$ALL_NETWORK" && docker network rm ${ALL_NETWORK}
set -e

echo "Pruning system ..."
# This sould fix overlay2 problem
docker system prune \
       --all `# -a, Remove all unused images not just dangling ones)` \
       --force `# -f, Do not prompt for confirmation` \
       # --filter `#filter   Provide filter values (e.g. 'label=<key>=<value>')` \
       # --volumes `# Prune volumes, not sure what it is really doing.` \
       # close

echo "Checking cleaning ..."
echo "Your installation should now be all fresh and clean."
echo "The following commands should not output any items:"
docker ps -a
docker images -a 
docker volume ls
echo "The following command show only show the default networks:"
docker network ls
