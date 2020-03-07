# -*- mode: ruby -*-
# vi: set ft=ruby :

master_ip = "192.168.1.100"
cluster = {
  "mesos.master-0" => { :role => "master", :ip => master_ip, :cpus => 1, :mem => 512 },
  "mesos.slave-0" => { :role => "slave", :ip => "192.168.1.110", :cpus => 1, :mem => 512 }
}

Vagrant.configure("2") do |config|
  cluster.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|
      cfg.vm.provider :virtualbox do |vb, override|

        # Basics
        config.vm.box = "ubuntu/trusty64"
        vb.customize ["modifyvm", :id, "--memory", info[:mem], "--cpus", info[:cpus], "--hwvirtex", "on"]

        # Network
        override.vm.hostname = hostname
        vb.name = hostname
        override.vm.network :public_network, ip: "#{info[:ip]}"
        config.vm.network "forwarded_port", guest: 5050, host: 5050, auto_correct: true
        config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true

        # Data
        #   config.vm.synced_folder "./data", "/opt/data"
        #   config.vm.synced_folder "./data/logs/zookeeper", "/var/logs/zookeeper"
        #   config.vm.provision "file", source: "", destination: ".gitconfig"

        # Provision dependencies
        config.vm.provision "shell", path: "./provision/scripts/init.sh"
        # config.vm.provision "shell", path: "./provision/scripts/install-git.sh"
        config.vm.provision "shell", path: "./provision/scripts/install-docker.sh"

        # Provision infrastructure
        if info[:role] == "master"
            config.vm.provision "shell", :path => "./provision/scripts/install-master.sh", :args => [info[:ip], index+1]
        else info[:role] == "slave"
            config.vm.provision "shell", :path => "./provision/scripts/install-slave.sh", :args => [master_ip, info[:ip]]
        end

      end # end provider
    end # end config
   end # end cluster
end
