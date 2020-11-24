#!/bin/bash

echo "Creating kind cluster with cluster-config.yaml..."
kind create cluster --config cluster-config.yaml

echo "Applying metallb namespace..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml

echo "Create secret for metallb-system node..."
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

echo "Applying metallb manifest..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml

# docker inspect <container_id with ip>
# grep and grab IPAddress and set inside metallb-config.yaml
