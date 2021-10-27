#!/bin/bash

# Helper Script for profiling performance issues
# This script refreshes an apps status a bunch of times to populate Waypoint Servers Database

declare -i iterations=0

while true; do
  # TODO turn app into an argument
  time waypoint status -app=tetris -refresh
  iterations+=1

  echo
  echo "$iterations total refreshes"
  echo

  sleep 2
done
