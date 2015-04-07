#!/bin/bash
## Quick and dirty saolution to clean up containers for supervisor
## Docker will restart containers but we want them to be managed by supervisor
## so some manual clean up may be required

## Get List of Container ID's
CONTAINERS=$(/usr/bin/docker ps -a | grep latest | grep Exited | awk '{print $1}')

## For each container id remove it
for CID in $CONTAINERS
do
  /usr/bin/docker rm --force $CID
done
