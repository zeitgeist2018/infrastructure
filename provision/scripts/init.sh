#!/bin/bash
set -e

createPassword(){
    sudo passwd centos
}

sudo yum update -y
sudo yum install -y nano
