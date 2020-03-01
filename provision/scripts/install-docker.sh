#!/bin/bash
set -e

cd $HOME
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

sudo gpasswd -a $USER docker
newgrp docker
sudo service docker restart

sudo systemctl start docker
sudo systemctl start docker
sudo systemctl enable docker
