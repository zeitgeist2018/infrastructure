#!/bin/bash
set -e

MASTER0_IP=$1
SLAVE_IP=$2

echo "************** INSTALLING SLAVE ON $SLAVE_IP ****************"

MESOS_VERSION=1.9.0

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
sudo apt-get install mesosphere -y > /dev/null 2>&1

# Configure zookeeper
echo "Configuring ZooKeeper"
echo "zk://$MASTER0_IP:2181/mesos" | sudo tee /etc/mesos/zk
echo $ZK_MASTER_NUMBER | sudo tee sudo /etc/zookeeper/conf/myid
#sudo cp /etc/zookeeper/conf/zoo.cfg /etc/zookeeper/conf/zoo.cfg.bak
# dataDir=/var/lib/zookeeper
sudo chown zookeeper:zookeeper /var/lib/zookeeper
echo "server.1=$MASTER0_IP:2888:3888" | sudo tee -a /etc/zookeeper/conf/zoo.cfg


# Configure mesos
echo "Configuring Mesos"
echo 1 | sudo tee /etc/mesos-master/quorum
echo $MASTER0_IP | sudo tee /etc/mesos-master/ip
sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname


sudo stop zookeeper || true
sudo stop mesos-master || true
echo manual | sudo tee /etc/init/zookeeper.override
echo manual | sudo tee /etc/init/mesos-master.override


echo $SLAVE_IP | sudo tee /etc/mesos-slave/ip
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

sudo start mesos-slave
