#!/bin/bash

path_to_executable=$(which vault)
if ! [ -x "$path_to_executable" ] ; then
  >&2 echo "error: vault not defined on path"
  exit 1
fi

NETWORK_INTERFACE=$1
if [ -z "$NETWORK_INTERFACE" ] ; then
  >&2 echo "error: no interface argument given"
  echo "Usage:"
  echo "vault_server network_interface_name"
  exit 1
fi

echo "Starting vault server in dev mode on ${NETWORK_INTERFACE}"
vault server -dev -dev-listen-address="${NETWORK_INTERFACE}" > vault.log 2>&1 &

echo
echo "Finished! Logs directed to local 'vault.log'"
