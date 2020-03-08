#!/bin/bash
set -e

sudo apt-get install -y jq > /dev/null 2>&1

CFG_FILE=$1
IP_ADDRESS=$(hostname -I | awk '{print $2}')
CFG_MASTER_IPS=$(cat $CFG_FILE | jq -r -c '.nodes | .[] | select(.role == "master").ip' | paste -sd, -)
CFG_MASTER_IPS_WITH_PORTS=$(cat $CFG_FILE | jq -r -c '.nodes | .[] | select(.role == "master").ip + ":2181"' | paste -sd, -)
#ZK_MASTER_ID=$(cat $CFG_FILE | jq -r --arg IP_ADDRESS "$IP_ADDRESS" -c '.nodes | .[] | select(.ip == $IP_ADDRESS).zookeeperNodeId')
ZK_SERVER_DESCRIPTORS=$(cat $CFG_FILE | jq -c '.nodes | .[] | select(.role == "master") | "server." + (.zookeeperNodeId|tostring) + "=" + .ip + ":2888:3888"')
ZK_QUORUM=1 # TODO: Calculate quorum automatically

echo "************** INSTALLING SLAVE ON $IP_ADDRESS ****************"

# Obtain version list with `apt-cache policy mesos`
MESOS_VERSION="1.9.0-2.0.1.ubuntu1404"

cd $HOME

# Install packages
#sudo add-apt-repository universe

echo "Installing Java"
sudo add-apt-repository ppa:openjdk-r/ppa > /dev/null 2>&1
sudo apt-get update -y > /dev/null 2>&1
sudo apt-get upgrade -y > /dev/null 2>&1
sudo apt-get install openjdk-8-jdk -y > /dev/null 2>&1

echo "Installing Mesosphere"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "DISTRO=$DISTRO"
echo "CODENAME=$CODENAME"
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get update -y > /dev/null 2>&1
sudo apt-get install mesos=$MESOS_VERSION -y > /dev/null 2>&1

# Configure zookeeper
echo "Configuring ZooKeeper"
echo "zk://$CFG_MASTER_IPS_WITH_PORTS/mesos" | sudo tee /etc/mesos/zk
sudo chown zookeeper:zookeeper /var/lib/zookeeper

sudo stop zookeeper || true
sudo stop mesos-master || true
echo manual | sudo tee /etc/init/zookeeper.override
echo manual | sudo tee /etc/init/mesos-master.override


echo $IP_ADDRESS | sudo tee /etc/mesos-slave/ip
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname
echo "docker,mesos" | sudo tee /etc/mesos-slave/containerizers

sudo start mesos-slave

sudo useradd --no-create-home marathon || echo "Marathon user already exists"
mkdir -p /var/lib/mesos/slaves || echo "Mesos slaves folder already exists"
