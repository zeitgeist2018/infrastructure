#!/bin/bash
set -e

curl -X POST -d @gitlab.json -H "Content-type: application/json" http://localhost:8080/v2/apps
