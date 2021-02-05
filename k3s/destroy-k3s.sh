#!/bin/bash

echo "Uninstalling k3s..."
echo

echo "WARNNING: this will stop and remove all running docker containers"
echo

echo "Running k3s uninstall scripts..."
echo

source /usr/local/bin/k3s-killall.sh
source /usr/local/bin/k3s-uninstall.sh

echo "Stopping and removing all docker containers..."

docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

echo "Uninstall complete!"
