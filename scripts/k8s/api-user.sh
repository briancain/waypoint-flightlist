#!/bin/bash

# WARNING: this essentially lets the user make any kind of API request
# use for dev only

kubectl create clusterrolebinding serviceaccounts-cluster-admin \
  --clusterrole=cluster-admin --group=system:serviceaccounts
