#!/bin/bash
set -e


MASTER0_IP=$1
ZK_MASTER_NUMBER=$2

echo "************** INSTALLING MASTER ON $MASTER0_IP ****************"

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
sudo chown zookeeper:zookeeper /var/lib/zookeeper
echo "server.1=$MASTER0_IP:2888:3888" | sudo tee -a /etc/zookeeper/conf/zoo.cfg


# Configure mesos
echo "Configuring Mesos"
echo 1 | sudo tee /etc/mesos-master/quorum
echo $MASTER0_IP | sudo tee /etc/mesos-master/ip
sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname


# Configure Marathon
echo "Configuring Marathon"
cat << EOF > tmp
MARATHON_MASTER=zk://$MASTER0_IP:2181/mesos
MARATHON_ZK=zk://$MASTER0_IP:2181/marathon
EOF
sudo mv tmp /etc/default/marathon


# Make masters not to run slave service
sudo stop mesos-slave || echo "Slave service not running, good!"
echo manual | sudo tee /etc/init/mesos-slave.override
sudo update-rc.d marathon enable
sudo update-rc.d chronos defaults
sudo update-rc.d chronos enable

# All ready, start services
sudo restart zookeeper
sudo start mesos-master || sudo restart mesos-master
sudo service marathon start
sudo service chronos start
