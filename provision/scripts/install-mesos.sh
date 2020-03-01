#!/bin/bash
set -e

# https://github.com/apache/mesos/tree/master/support/mesos-mini
docker run --detach --rm --privileged -v /opt/data/mesos:/etc -p 5050:5050 -p 5051:5051 -p 8080:8080 mesos/mesos-mini --name mesos-cluster
