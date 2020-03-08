# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'

config_file = File.read('cluster-config.json')
nodes = JSON.parse(config_file)["nodes"]
config_file_target = "/home/vagrant/cluster-config.json"

Vagrant.configure("2") do |config|

  nodes.each_with_index do |node, index|
    config.vm.define node["name"] do |machine|

      machine.vm.provision "shell", privileged: false, inline: <<-EOF
          echo "************* GENERATING MACHINE #{node} ***************"
      EOF

      machine.vm.hostname = node["name"]
      machine.vm.provider :virtualbox do |v, override|
        machine.vm.box = "ubuntu/trusty64"
        v.customize ["modifyvm", :id, "--memory", node["mem"]]
        v.customize ["modifyvm", :id, "--cpus", node["cpus"]]
        override.vm.hostname = node["name"]
        v.name = node["name"]
        override.vm.network :public_network, bridge: "en1: Wi-Fi (AirPort)", ip: "#{node["ip"]}"
      end

      # Data
      # config.vm.synced_folder "./data", "/opt/data"
      config.vm.provision "file", source: "./cluster-config.json", destination: config_file_target

      # Common dependencies
      machine.vm.provision "shell", path: "./provision/scripts/init.sh"
      # config.vm.provision "shell", path: "./provision/scripts/install-git.sh"
      machine.vm.provision "shell", path: "./provision/scripts/install-docker.sh"

      # Provision
      if node["role"] == "master"
        machine.vm.provision "shell", :path => "./provision/scripts/install-master.sh", :args => [config_file_target]
      elsif node["role"] == "slave"
        machine.vm.provision "shell", :path => "./provision/scripts/install-slave.sh", :args => [config_file_target]
      end
    end
  end

end
