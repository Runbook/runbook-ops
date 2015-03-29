#!/bin/bash
## Quicky Script to completely remove docker containers and images
## Very destructive only run if you know

echo "Cleaning up containers"
for container in `/usr/bin/docker ps -qa`
do
    /usr/bin/docker rm --force $container
done
echo "----------------------------------"
echo "Cleaning up images"
for image in `/usr/bin/docker images -q`
do
    /usr/bin/docker rmi --force $image
done
