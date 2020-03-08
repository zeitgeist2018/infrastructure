#!/bin/sh

MARATHON_IP=192.168.1.100:8080

curl -X POST http://$MARATHON_IP/v2/apps -d @marathon-server.json -H 'Content-Type: application/json'
curl -X POST http://$MARATHON_IP/v2/apps -d @marathon-shell.json -H 'Content-Type: application/json'
