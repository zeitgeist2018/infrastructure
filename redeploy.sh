#!/bin/sh

# Create cluster
vagrant destroy -f
vagrant up

# Deploy infrastructure
cd ./provision/scripts/deployments/marathon && ./marathon-test.sh
cd ../chronos && ./chronos-test.sh
