#!/bin/bash

echo "Setting up k3s..."
echo

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--docker" sh -

echo "Waiting for services to come online...this may take a while..."
echo

# grab k3s k8s config
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

until kubectl get all
do
    echo ...
    sleep 1
done

echo "Done! You should be ready to 'waypoint install -platform=kubernetes -accept-tos' on a local kubernetes!"
exit 0
