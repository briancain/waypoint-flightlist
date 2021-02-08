#!/bin/bash

function halt() {
  # TODO: set warning with y/n prompt that this will
  # volume prune
  docker stop waypoint-server
  docker rm waypoint-server
  docker volume rm waypoint-server
  docker volume prune -f
}

function demolish() {
  halt
  docker rmi hashicorp/waypoint
}

function nuke() {
  docker system prune -a -f
}
