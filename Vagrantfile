# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "easycom/debian7"

  # Enable to check if the bow is outdated 
  config.vm.box_check_update = true
  
  # Configure the ram and cpu allocations
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  	v.cpus = 2
  end
  
  # Forwards port from the host to the guest and other network conf
  #config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", type: "dhcp"
  #config.vm.network "public_network"
  
  config.vm.provision :shell, inline: 'sudo mkdir -p /var/www'
  
  # Enable the shared folder to be synced by rsync > use vagrant rsync-auto 
  # command to enable the automatic transfer of files from the host to the guest
  config.vm.synced_folder "./htdocs", "/var/www/htdocs", 
  	type: "rsync", 
  	rsync__auto: true,
  	rsync__args: ["--verbose", "--archive", "--delete", "--compress"]


    config.vm.define "php54" do |php54|
      php54.vm.provision :shell, path: "./vagrant/install-simple-lamp.sh", args: "php54 128 12000 y"
      php54.vm.network "forwarded_port", guest: 80, host: 8080
    end 
    config.vm.define "php55" do |php55|
      php55.vm.provision :shell, path: "./vagrant/install-simple-lamp.sh", args: "php55 128 12000 y", keep_color: false
      php55.vm.network "forwarded_port", guest: 80, host: 8081
    end 
    config.vm.define "php56" do |php56|
      php56.vm.provision :shell, path: "./vagrant/install-simple-lamp.sh", args: "php56 128 12000 y"
      php56.vm.network "forwarded_port", guest: 80, host: 8082
    end 

    # config.vm.provision :shell, path: "../install-apache.sh", args: "php56"
 
end
