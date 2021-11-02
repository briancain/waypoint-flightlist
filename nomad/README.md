# Nomad

## Setup

This folder offers a simple way to set up nomad locally with `start-nomad`. If
you need a more fully featured Nomad cluster, use the Vagrant project directory
instead which will bring up a Nomad cluster.

## Consul DNS

To use Consul DNS, this folder provides a script to start up a consul agent
in dev mode. You'll need to make sure you update the IP address in these scripts
to be the local IP address for your machine. In my case, it was my `wlp4s0` interface IP address.

You'll also need to update the Consul hostname env var to properly use consul, since it will be
bound to the local IP and not `localhost`. You can do that with CONSUL_HTTP_ADDR:

```bash
CONSUL_HTTP_ADDR=192.168.0.158:8500 consul catalog services
```
