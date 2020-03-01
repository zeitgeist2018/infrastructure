# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Basics
  config.vm.box = "centos/7"
  config.vm.box_version = "1905.1"

  # Network
  config.vm.network "forwarded_port", guest: 5050, host: 5050 #,host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8080, host: 8080 #,host_ip: "127.0.0.1"
  config.vm.network "public_network"

  # Data
  config.vm.synced_folder "./data", "/opt/data"
#   config.vm.provision "file", source: "", destination: ".gitconfig"

  # Provision dependencies
#   config.vm.provision "shell", path: "./provision/scripts/init.sh"
#   config.vm.provision "shell", path: "./provision/scripts/install-git.sh"
#   config.vm.provision "shell", path: "./provision/scripts/install-docker.sh"

  # Provision infrastructure
  config.vm.provision "shell", path: "./provision/scripts/install-mesos.sh"
#   config.vm.provision "shell", path: "./provision/scripts/deployments/gitlab.sh"
#   config.vm.provision "shell", path: "./provision/scripts/deployments/artifactory.sh"
#   config.vm.provision "shell", path: "./provision/scripts/deployments/jenkins.sh"
#   config.vm.provision "shell", path: "./provision/scripts/deployments/circle-ci.sh"
end
