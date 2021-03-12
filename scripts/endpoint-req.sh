#!/bin/bash

while true; do
  curl -s -o /dev/null -w "%{http_code}\n" $1 2>&1
  sleep 10
done
