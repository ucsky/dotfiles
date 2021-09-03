#!/bin/bash

echo "Stop all containers"
docker stop `docker ps -qa`

echo "Remove all containers"
docker rm `docker ps -qa`

echo "Remove all images"
docker rmi -f `docker images -qa `

echo "Remove all volumes"
docker volume rm $(docker volume ls -qf)
docker volume rm $(docker volume ls -qf dangling=true)

echo "Remove all networks"
docker network rm `docker network ls -q`

echo "Your installation should now be all fresh and clean."

echo "The following commands should not output any items:"
docker ps -a
docker images -a 
docker volume ls

echo "The following command show only show the default networks:"
docker network ls

# Fix overlay2 problem
docker system prune -a
