#!/bin/sh

CHRONOS_IP=192.168.1.100:4400

curl -L -H 'Content-Type: application/json' -X POST -d @chronos-test.json $CHRONOS_IP/scheduler/iso8601
