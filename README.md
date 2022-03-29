# Waypoint FlightList

A repository that helps users reproduce and triage issues with waypoint and the
various plugins it supports.

Inspired by the sandbox dev environment for [vagrant](https://github.com/briancain/congenial-octo-palm-tree)

## Contents

- kind+k8s
  + Uses kind to set up a local k8s cluster with metallb. Once set up, Waypoint
  server will be ready to install onto k8s
- k3s
  + Uses k3s to set up a local k8s cluster. The kind k8s approach is preferred,
  however this is an alternative to kind and works well in CI environments.
- aws-eks
  + Follow the HashiCorp Learn guide that uses Terraform to set up aws-eks
- nomad
  + Uses the local nomad dev agent to start up
- scripts
  + Various local dev bash scripts used for this project
- windows
  + _work in progress_
