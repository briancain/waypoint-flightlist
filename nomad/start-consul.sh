#!/bin/bash

sudo consul agent -data-dir=consul-datadir -dev -dns-port=53 -client=192.168.0.158 #-advertise=192.168.0.158 -bind=0.0.0.0
