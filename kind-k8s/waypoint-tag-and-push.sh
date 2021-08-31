#!/bin/bash

echo
echo "Tagging Waypoint server and on-demand runner container images..."
echo

docker tag waypoint:dev localhost:5000/waypoint:dev
docker tag waypoint-odr:dev localhost:5000/waypoint-odr:dev

echo
echo "Pushing tagged containers to local container registry..."
echo

docker push localhost:5000/waypoint:dev
docker push localhost:5000/waypoint-odr:dev  

echo
echo "Finished tagging and pushing Waypoint server and on-demand containers!"
echo
