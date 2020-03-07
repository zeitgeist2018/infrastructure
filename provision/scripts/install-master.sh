#!/bin/bash
set -e

MASTER0_IP=$1
ZK_MASTER_NUMBER=$2
echo "ZK_MASTER_NUMBER=$ZK_MASTER_NUMBER"

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


# Configure mesos

echo 1 > sudo /etc/mesos-master/quorum

echo $MASTER0_IP | sudo tee /etc/mesos-master/ip
sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname


# Configure Marathon
sudo mkdir -p /etc/marathon/conf
sudo cp /etc/mesos-master/hostname /etc/marathon/conf
sudo cp /etc/mesos/zk /etc/marathon/conf/master
#sudo cp /etc/marathon/conf/master /etc/marathon/conf/zk # TODO: Copy this file and replace /mesos with /marathon, then the 'cat' below is not needed
cat <<EOF > sudo /etc/marathon/conf/zk
zk://$MASTER0_IP:2181/marathon
EOF

# Make masters not to run slave service
sudo stop mesos-slave || echo "Slave service not running, good!"
echo manual | sudo tee /etc/init/mesos-slave.override

# All ready, start services
sudo restart zookeeper
sudo start mesos-master


#MARATHON_VERSION=1.8.222
mkdir marathon
curl -O https://downloads.mesosphere.io/marathon/builds/1.8.222-86475ddac/marathon-1.8.222-86475ddac.tgz
tar xzf marathon-1.8.222-86475ddac.tgz --strip-components 1 -C marathon
cd marathon/bin
./marathon --master $(cat /etc/mesos/zk) --zk $(cat /etc/marathon/conf/zk)

#sudo start marathon
