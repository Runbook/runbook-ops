# -*- mode: ruby -*-
# # vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with box details
servers = YAML.load_file('servers.yaml')

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Iterate through entries in YAML file
  servers.each do |servers|
    config.vm.define servers["name"] do |srv|
      srv.vm.box = servers["box"]
      srv.vm.hostname = servers["name"]
      srv.vm.network "private_network", ip: servers["ip"]
      if servers["name"] == "salt"
        srv.vm.provision "shell",
          inline: "curl -L https://bootstrap.saltstack.com -o install_salt.sh && sh install_salt.sh -M"
        srv.vm.synced_folder "./", "/root/runbook-ops"
        srv.vm.synced_folder "runbook-secretops", "/root/runbook-secretops"
      else
        srv.vm.provision "shell",
          inline: "echo 192.168.36.14 salt >> /etc/hosts"
        srv.vm.provision "shell",
          inline: "curl -L https://bootstrap.saltstack.com -o install_salt.sh && sh install_salt.sh"
      end
      srv.vm.provider :virtualbox do |vb|
        vb.name = servers["name"]
        vb.memory = servers["ram"]
#        vb.gui = true
      end
    end
  end
end
