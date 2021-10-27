#!/bin/bash

declare -i iterations=0

while true; do
  waypoint up -var image="localhost:5000/tetris" -var registry_local=false

  declare -i i=0
  while (( ++i <= 10 )); do
    time waypoint status -app=tetris -refresh
    sleep 2
  done

  iterations+=1
  echo
  echo "$iterations total iterations"
  echo "$i total refreshes"
  echo

  sleep 2
done
