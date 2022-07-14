#!/bin/bash

# NOTE(briancain): This script uses 'kind' to automatically bring up a local
# kubernetes cluster. It includes optional support for configuring an
# Ingress controller node.

set -o errexit

setupIngress=$WP_K8S_INGRESS

# NOTE(briancain): This version is both the kind node version as well as the
# version of Kubernetes that kind sets up. In this case, we'd be installing
# kubernetes version 1.22.
kindVersion="${KIND_NODE_VERSION:-kindest/node:v1.23.5}"

echo "Setting up local docker registry..."
echo

reg_name='kind-registry'
reg_port='5000'
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
    registry:2 | 2>/dev/null
fi

echo "Setting up kubernetes with kind and metallb..."
echo

if [ -n "${setupIngress}" ]; then
  echo "Creating kind cluster with ingress controller..."
  echo
cat <<EOF | kind create cluster --image="$kindVersion" --config=-
  kind: Cluster
  apiVersion: kind.x-k8s.io/v1alpha4
  containerdConfigPatches:
  - |-
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
        endpoint = ["http://${reg_name}:${reg_port}"]
  nodes:
  - role: control-plane
    kubeadmConfigPatches:
    - |
      kind: InitConfiguration
      nodeRegistration:
        kubeletExtraArgs:
          node-labels: "ingress-ready=true"
    extraPortMappings:
    - containerPort: 80
      hostPort: 80
      listenAddress: "0.0.0.0"
      protocol: TCP
    - containerPort: 443
      hostPort: 443
      listenAddress: "0.0.0.0"
      protocol: TCP
EOF

else
  echo "Creating kind cluster with cluster-config.yaml..."
  echo
cat <<EOF | kind create cluster --image="$kindVersion" --config=-
  kind: Cluster
  apiVersion: kind.x-k8s.io/v1alpha4
  containerdConfigPatches:
  - |-
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
        endpoint = ["http://${reg_name}:${reg_port}"]
EOF

fi

echo "Connecting registry to cluster network..."
echo
# connect the registry to the cluster network
# (the network may already be connected)
docker network connect "kind" "${reg_name}" || true
# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo
echo "Applying metallb namespace..."
echo
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml

echo "Create secret for metallb-system node..."
echo
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

echo "Applying metallb manifest..."
echo
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml

echo
echo
echo $"Obtaining container IP to set as range in metallb-config.yaml..."
CONTAINERID=$(docker ps -a --filter="expose=6443" -q)
IPADDR=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINERID)

echo "IP Address of networked container is ${IPADDR}"
echo

echo "Automatically picking an IP range based on networked contianer IP..."

IPADDR_RANGE="$(awk -F"." '{print $1"."$2"."$3".20"}'<<<$IPADDR)-$(awk -F"." '{print $1"."$2"."$3".50"}'<<<$IPADDR)"

#read -p "Enter a range to define for metallb IP Addresses based on this container (like 172.18.0.20-172.18.0.50):`echo $'\n> '` " IPADDR_RANGE
echo "IP Address range is ${IPADDR_RANGE}"
echo

sed s/%ADDR_RANGE%/$IPADDR_RANGE/g \
   configs/metallb-config-template.yaml > configs/metallb-config-set.yaml

echo "Applying metallb-config-set.yaml with ip address range applied..."
kubectl apply -f configs/metallb-config-set.yaml

if [ -n "${setupIngress}" ]; then
  echo
  echo "Setting up NGINX ingress controller..."
  echo

  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
fi

echo
echo "Setting up Docker secrets into Kubernetes cluster"

kubectl create secret generic regcred --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson

echo
echo "Setting up metrics server into Kubernetes cluster"

kubectl apply -f insecure_metrics_server.yaml

echo
echo -e "\033[0;33mWARNING! Setting up admin role to give API access to all users."
echo -e "\033[0;33mThis is intended for DEV ONLY!"
echo -e "\033[0m"

kubectl create clusterrolebinding serviceaccounts-cluster-admin \
    --clusterrole=cluster-admin --group=system:serviceaccounts

echo
echo "Setting up Consul and Vault into Kubernetes"
echo

# Automate setting up vault and consul

# Install consul and vault into cluster
helm repo update
helm install consul hashicorp/consul --values helm/helm-consul-values.yaml
# wait until consul is reporting ready....
echo
echo "Waiting for consul pods to report ready..."
echo
while [[ $(kubectl get pods -l app=consul -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True" ]]; do echo "waiting for consul server..." && sleep 5; done
echo

helm install vault hashicorp/vault --values helm/helm-vault-values.yaml
# wait until vault is reporting ready....
echo
echo "Waiting for vault pods to report ready..."
echo
# They just need to exist, not be "Ready". Unsealing the vault pods makes them ready
sleep 15

echo
echo "Setting up vault..."
echo

# Initialize and unseal vault
# Save keys to .json file
# vault operator unseal on all vault pods
kubectl exec vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
kubectl exec vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-1 -- vault operator unseal $VAULT_UNSEAL_KEY
kubectl exec vault-2 -- vault operator unseal $VAULT_UNSEAL_KEY

echo
echo "Setting up Waypoint vault secrets for container registry..."
echo

# Set a secret
# vault login with root token
VAULT_TOKEN=$(cat cluster-keys.json | jq -r ".root_token")
# enable vault kv version 2
echo "Enabling vault kv version 2 secrets"
kubectl exec vault-0 -- /bin/sh -c "VAULT_TOKEN=$VAULT_TOKEN vault secrets enable -path=secret kv-v2"
# create secrets!!!
REG_USER=$(cat reg.json | jq -r ".registry_username")
REG_PASS=$(cat reg.json | jq -r ".registry_password")
echo "Creating the secrets..."
kubectl exec vault-0 -- /bin/sh -c "VAULT_TOKEN=$VAULT_TOKEN vault kv put secret/registry registry_username=$REG_USER registry_password=$REG_PASS"

echo "Enabling kubernetes auth for Waypoint..."
# Enable kubernetes auth
# there are 3-ish steps here which include getting the k8s cluster IP
# Add a kubectl exec vault-0 to all of these
kubectl exec vault-0 -- /bin/sh -c "VAULT_TOKEN=$VAULT_TOKEN vault auth enable kubernetes"

# Get service/kubernetes cluster-ip
KUBE_SVC_ADDR=$(kubectl describe service/kubernetes | grep IP: | awk '{print $2;}' | xargs)
kubectl exec vault-0 -- /bin/sh -c "VAULT_TOKEN=$VAULT_TOKEN vault write auth/kubernetes/config kubernetes_host=\"https://$KUBE_SVC_ADDR:443\""

kubectl exec vault-0 -- /bin/sh -c "VAULT_TOKEN=$VAULT_TOKEN vault policy write waypoint - <<EOF
path \"secret/data/registry\" {
  capabilities = [\"read\"]
}
EOF"

kubectl exec vault-0 -- /bin/sh -c "VAULT_TOKEN=$VAULT_TOKEN vault write auth/kubernetes/role/waypoint \
      bound_service_account_names=vault \
      bound_service_account_namespaces=default \
      policies=waypoint \
      ttl=24h"

# Grab the vault service addr for configuring Waypoints Vault dynamic config sourcer plugin
VAULT_SVC_ADDR=$(kubectl describe service/vault | grep IP: | awk '{print $2;}' | xargs)

echo
echo "Done! You should be ready to 'waypoint install -platform=kubernetes -accept-tos' on a local kubernetes!"
echo
echo "Vault Service Address: $VAULT_SVC_ADDR"
echo "To configure Waypoint to use the Vault dynamic config sourcer plugin, run this command after installing Waypoint:"
echo "waypoint config source-set -type=vault -config=addr=http://$VAULT_SVC_ADDR:8200 -config=token=$VAULT_TOKEN"
exit 0
