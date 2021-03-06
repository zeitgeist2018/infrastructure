#!/bin/bash
set -e

sudo apt-get install -y jq > /dev/null 2>&1

CFG_FILE=$1
IP_ADDRESS=$(hostname -I | awk '{print $2}')
CFG_MASTER_IPS=$(cat $CFG_FILE | jq -r -c '.nodes | .[] | select(.role == "master").ip' | paste -sd, -)
CFG_MASTER_IPS_WITH_PORTS=$(cat $CFG_FILE | jq -r -c '.nodes | .[] | select(.role == "master").ip + ":2181"' | paste -sd, -)
ZK_MASTER_ID=$(cat $CFG_FILE | jq -r --arg IP_ADDRESS "$IP_ADDRESS" -c '.nodes | .[] | select(.ip == $IP_ADDRESS).zookeeperNodeId')
ZK_SERVER_DESCRIPTORS=$(cat $CFG_FILE | jq -c '.nodes | .[] | select(.role == "master") | "server." + (.zookeeperNodeId|tostring) + "=" + .ip + ":2888:3888"')
ZK_QUORUM=1 # TODO: Calculate quorum automatically

echo "CFG_MASTER_IPS=$CFG_MASTER_IPS"
echo "CFG_MASTER_IPS_WITH_PORTS=$CFG_MASTER_IPS_WITH_PORTS"
echo "ZK_MASTER_ID=$ZK_MASTER_ID"
echo "ZK_SERVER_DESCRIPTORS=$ZK_SERVER_DESCRIPTORS"

echo "************** INSTALLING MASTER ON $IP_ADDRESS ****************"

# Obtain version list with `apt-cache policy mesos`
MESOS_VERSION="1.9.0-2.0.1.ubuntu1404"
MARATHON_VERSION="1.7.189-0.1.20190125215327.ubuntu1404"
CHRONOS_VERSION="2.5.1-0.1.20171211074431.ubuntu1404"

cd $HOME

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
sudo apt-get install mesos=$MESOS_VERSION marathon=$MARATHON_VERSION chronos=$CHRONOS_VERSION -y > /dev/null 2>&1

# Configure zookeeper
echo "Configuring ZooKeeper"
echo "zk://$CFG_MASTER_IPS_WITH_PORTS/mesos" | sudo tee /etc/mesos/zk
echo $ZK_MASTER_ID | sudo tee sudo /etc/zookeeper/conf/myid
sudo chown zookeeper:zookeeper /var/lib/zookeeper
echo $ZK_SERVER_DESCRIPTORS | sudo tee -a /etc/zookeeper/conf/zoo.cfg


# Configure mesos
echo "Configuring Mesos"
echo $ZK_QUORUM | sudo tee /etc/mesos-master/quorum
echo $IP_ADDRESS | sudo tee /etc/mesos-master/ip
sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname


# Configure Marathon
echo "Configuring Marathon"
cat << EOF > tmp
MARATHON_MASTER=zk://$CFG_MASTER_IPS_WITH_PORTS/mesos
MARATHON_ZK=zk://$CFG_MASTER_IPS_WITH_PORTS/marathon
EOF
sudo mv tmp /etc/default/marathon

# Make masters not to run slave service
sudo stop mesos-slave || echo "Slave service not running, good!"
echo manual | sudo tee /etc/init/mesos-slave.override
sudo update-rc.d marathon enable

# All ready, start services
sudo restart zookeeper
sudo start mesos-master || sudo restart mesos-master
sudo service marathon start
sudo service chronos start
