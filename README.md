# Waypoint FlightList

A repository that helps users reproduce and triage issues with waypoint and the
various plugins it supports.

Inspired by the sandbox dev environment for [vagrant](https://github.com/briancain/congenial-octo-palm-tree)

## Contents

- kind+k8s
  + Uses kind to set up a local k8s cluster with metallb. Once set up, Waypoint
  server will be ready to install onto k8s
- EKS
  + _work in progress_
- nomad
  + Uses the local nomad dev agent to start up
- windows
  + _work in progress_
