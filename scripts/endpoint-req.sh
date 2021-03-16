#!/bin/bash

while true; do
  echo "$(date)"
  curl -s -o /dev/null -w "response_code=%{http_code}\n" $1 2>&1
  echo "executing 'waypoint logs'"
  echo
  waypoint logs > /dev/null 2>&1 &
  export APP_PID=$!
  sleep 10
  kill -INT $APP_PID
done
