# -*- mode: ruby -*-
# vi: set ft=ruby :

master_ip = "192.168.1.100"
cluster = [
    {:name => "mesos.master-0", :role => "master", :ip => master_ip, :cpus => 1, :mem => 1024},
    {:name => "mesos.slave-0", :role => "slave", :ip => "192.168.1.110", :cpus => 2, :mem => 2048}
]

Vagrant.configure("2") do |config|

    cluster.each_with_index do |opts, index|
      config.vm.define opts[:name] do |machine|

        machine.vm.provision "shell", privileged: false, inline: <<-EOF
          echo "************* GENERATING MACHINE #{opts} ***************"
        EOF

        machine.vm.hostname = opts[:name]
        machine.vm.provider :virtualbox do |v, override|
          machine.vm.box = "ubuntu/trusty64"
          v.customize ["modifyvm", :id, "--memory", opts[:mem]]
          v.customize ["modifyvm", :id, "--cpus", opts[:cpus]]
          override.vm.hostname = opts[:name]
          v.name = opts[:name]
          override.vm.network :public_network, bridge: "en1: Wi-Fi (AirPort)", ip: "#{opts[:ip]}"
        end

        # Data
        #   config.vm.synced_folder "./data", "/opt/data"
        #   config.vm.synced_folder "./data/logs/zookeeper", "/var/log/zookeeper"
        #   config.vm.synced_folder "./data/logs/mesos", "/var/log/mesos"
          # config.vm.synced_folder "./data/logs/marathon", "/var/log/marathon"
        #   config.vm.provision "file", source: "", destination: ".gitconfig"

        # Common dependencies
        machine.vm.provision "shell", path: "./provision/scripts/init.sh"
        # config.vm.provision "shell", path: "./provision/scripts/install-git.sh"
        machine.vm.provision "shell", path: "./provision/scripts/install-docker.sh"

        # Provision
        if opts[:role] == "master"
          machine.vm.provision "shell", :path => "./provision/scripts/install-master.sh", :args => [opts[:ip], index + 1]
        elsif opts[:role] == "slave"
          machine.vm.provision "shell", :path => "./provision/scripts/install-slave.sh", :args => [master_ip, opts[:ip]]
        end
      end
    end

end
