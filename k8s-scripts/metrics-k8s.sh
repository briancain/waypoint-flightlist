#!/bin/bash

# This script assumes Kubernetes is already setup
# Ref:
# - https://github.com/kubernetes-sigs/metrics-server

echo
echo "Applying metrics-server config..."
echo

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

echo
echo "Metrics server setup complete"
echo
