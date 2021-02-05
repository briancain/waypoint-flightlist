# K3S

## What is this?

This folder contains a helper script to help users get started with setting up
`k3s` and `kubernetes` locally. Because Waypoint requires a kubernetes (k8s) cluster
with a load balancer configured, and because setting this up is a bit non-trivial,
this folder exists to ease the pain of bringing up a kubernetes cluster locally
so users can get started quickly without figuring all of this out on their own.

## Automated

```bash
./setup-k3s.sh
```

## Uninstalling

K3s leaves behind a lot of containers with no great way of controlling them,
so if you're finished you can simply uninstall everything with the uninstall
script provided here:

```bash
./destroy-k3s.sh
```
