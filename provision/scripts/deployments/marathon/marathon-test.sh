#!/bin/sh

MARATHON_IP=192.168.1.100:8080

curl -X PUT http://$MARATHON_IP/v2/apps/hostname -d @marathon-server.json -H 'Content-Type: application/json'
curl -X PUT http://$MARATHON_IP/v2/apps/shell -d @marathon-shell.json -H 'Content-Type: application/json'
curl -X PUT http://$MARATHON_IP/v2/apps/pacman -d @marathon-pacman.json -H 'Content-Type: application/json'
