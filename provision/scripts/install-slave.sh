#!/bin/bash
set -e

MASTER0_IP=$1
SLAVE_IP=$2
MESOS_VERSION=1.9.0

cd $HOME
mkdir mesos
cd mesos

# Install packages
sudo add-apt-repository universe

sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install openjdk-8-jdk -y

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "DISTRO=$DISTRO"
echo "CODENAME=CODENAME"
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get update -y
sudo apt-get install mesosphere -y

# Configure zookeeper

cat <<EOF > sudo /etc/mesos/zk
zk://$MASTER0_IP:2181/mesos
EOF

cat <<EOF > sudo /etc/zookeeper/conf/myid
$ZK_MASTER_NUMBER
EOF

cat <<EOF > sudo /etc/zookeeper/conf/zoo.cfg
server.1=$MASTER0_IP:2888:3888
EOF


sudo stop zookeeper
sudo stop mesos-master
echo manual | sudo tee /etc/init/zookeeper.override
echo manual | sudo tee /etc/init/mesos-master.override


echo $SLAVE_IP | sudo tee /etc/mesos-slave/ip
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

sudo start mesos-slave
