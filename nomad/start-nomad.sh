#!/bin/bash

path_to_executable=$(which nomad)
if ! [ -x "$path_to_executable" ] ; then
  >&2 echo "error: nomad not defined on path"
  exit 1
fi

NETWORK_INTERFACE=$1
if [ -z "$NETWORK_INTERFACE" ] ; then
  >&2 echo "error: no interface argument given"
  echo "Usage:"
  echo "start-nomad network_interface_name"
  exit 1
fi

echo "Starting nomad agent in dev mode on ${NETWORK_INTERFACE}"
nomad agent -dev -network-interface="${NETWORK_INTERFACE}" > nomad.log 2>&1 &

export NOMAD_ADDR='http://localhost:4646'

echo
echo "Finished! Logs directed to local 'nomad.log'"
