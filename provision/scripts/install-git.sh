#!/bin/bash
set -e

echo "********** Installing GIT **********"
sudo yum install git -y
git --version
