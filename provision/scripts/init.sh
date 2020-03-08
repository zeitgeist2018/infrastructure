#!/bin/bash
set -e

sudo apt-get update -y  > /dev/null 2>&1
sudo apt-get upgrade -y  > /dev/null 2>&1
sudo apt-get install -y nano > /dev/null 2>&1
