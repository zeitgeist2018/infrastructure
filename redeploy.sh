#!/bin/sh

MASTER0_IP=192.168.1.100
SLAVE0_IP=192.168.1.110

# Create cluster
vagrant destroy -f
vagrant up

# Deploy infrastructure
cd ./provision/scripts/deployments/marathon && ./marathon-test.sh
cd ../chronos && ./chronos-test.sh
