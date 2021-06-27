#!/bin/bash
set -v
docker kill $(docker ps -q)
