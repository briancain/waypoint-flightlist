#!/bin/bash

sudo consul agent -data-dir=consul-datadir -dev -dns-port=53 -client=192.168.1.4
