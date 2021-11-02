#!/bin/bash

# This script spins until a container exists, then spits out the docker command
# Sometimes this is useful if the container is quickly cleaned up before you can catch it

while true; do docker ps -a | grep runner | awk '{print $1}' | xargs -L 1 docker inspect ; done 
