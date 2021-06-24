#!/bin/bash

# Safe-ish way to stop waypoint server and remove it
function destroy() {
  # TODO: set warning with y/n prompt that this will
  # volume prune
  docker stop waypoint-server
  docker stop waypoint-runner
  docker rm waypoint-server
  docker rm waypoint-runner
  docker volume rm waypoint-server
  docker volume rm waypoint-runner
  docker volume prune -f
}

# Safe-ish way to stop waypoint server and runner
function halt() {
  docker stop waypoint-server
  docker stop waypoint-runner
}

# Destroy everything
function demolish() {
  halt
  docker rmi hashicorp/waypoint
}

# Use with caution
function nuke() {
  docker system prune -a -f
}

# Stops and removes all containers, cleans up networks and volumes
function cleanup_docker() {
  docker stop $(docker ps -a -q)
  docker rm $(docker ps -a -q)
  docker system prune -f
  docker volume prune -f
}

function watch_waypoint_server() {
  docker logs -f $(docker ps -aqf "name=waypoint-server")
}
