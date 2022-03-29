#!/bin/bash

# NOTE: you will need to export the Vault Listen ADDR as well as the token
# to get a local vault client to talk to the server.

path_to_executable=$(which vault)
if ! [ -x "$path_to_executable" ] ; then
  >&2 echo "error: vault not defined on path"
  exit 1
fi

LISTEN_ADDR=$1
if [ -z "$LISTEN_ADDR" ] ; then
  >&2 echo "error: no listen address argument given"
  echo "Usage:"
  echo "vault_server listen_address"
  exit 1
fi

echo "Starting vault server in dev mode on ${LISTEN_ADDR}"
vault server -dev -dev-listen-address="${LISTEN_ADDR}" > vault.log 2>&1 &

echo
echo "Finished! Logs directed to local 'vault.log'"
