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

	config.vm.define "bdd1" do |server|
        server.vm.network :private_network, :ip => '192.168.120.22'
        server.vm.hostname = "bdd1"
        server.hostmanager.aliases = "redis solr"
        _args="
            --install-mysql-server=yes
            --install-redis=yes
            --install-solr=yes
            --install-redis-commander=yes
            --install-memcached=yes

            --mysql-root-password=vagrant
            --mysql-allow-remote=yes
            --mysql-allow-remote-root=yes
            --mysql-createdb=yes
            --mysql-dbname=localdb
            --mysql-dbuser=localdb_user
            --mysql-dbpass=localdb_user_pass

            --redis-port=6380
            --redis-usage=cache
            --redis-max-memory=256

            --memcached-port=11211
            --memcached-max-memory=64

            --solr-version=4.10.3
            --solr-instance=local-project
            --tomcat-port=8080
            --tomcat-admin-login=root
            --tomcat-admin-password=vagrant
        "
        server.vm.provision :shell, path: "./bootstrap.sh", args: _args.gsub(/\s+/, " ").strip

        _args="
            --install-redis=yes
            --install-memcached=yes

            --redis-port=6381
            --redis-usage=session

            --memcached-port=11212
            --memcached-max-memory=96
        "
        server.vm.provision :shell, path: "./bootstrap.sh", args: _args.gsub(/\s+/, " ").strip
    end

	config.vm.define "www" do |server|
        server.vm.network :private_network, :ip => '192.168.120.21'
      	server.vm.hostname = "www"
        server.vm.provision :shell, inline: 'sudo mkdir -p /var/www'        
        server.vm.synced_folder "./htdocs", "/var/www/htdocs", type: "nfs"
        
        _args="
            --install-apache=yes
            --install-php=yes
            --install-phpmyadmin=yes
            --install-mailcatcher=yes
            --install-pagespeed=yes
            --install-ffmpeg=no

            --php-version=php56
            --php-opcache-memory=128
            --php-opcache-max-accelerated-files=12000
            --php-install-xdebug=yes
            --php-install-redis=yes
            --php-install-memcache=yes

            --php-install-composer=yes
            --php-install-drush=yes
            --php-install-drush-version=6.5.0
            --php-install-n98magerun=yes
            --php-install-wpcli=yes

            --apache-port=80
            --apache-port-ssl=443
            --apache-tools-secure=no
            --apache-localhost-aliases='www.local front.local'
            --apache-localhost-forcessl=no

            --phpmyadmin-server-ip=bdd1
            --phpmyadmin-server-port=3306
            --phpmyadmin-server-user=root
            --phpmyadmin-server-password=vagrant
            --phpmyadmin-auth-type=config
        "
        server.vm.provision :shell, path: "./bootstrap.sh", args: _args.gsub(/\s+/, " ").strip
        server.hostmanager.aliases = "www.local"
	end

    config.vm.define "front" do |server|
        server.vm.network :private_network, :ip => '192.168.120.20'
        server.vm.hostname = "front"
        _args="
            --install-varnish=yes 
            --varnish-listen-port=8080 
            --varnish-admin-listen=0.0.0.0 
            --varnish-admin-port=6082 
            --varnish-backend-ip=www 
            --varnish-backend-port=80 
            --varnish-storage-size=1G    

            --install-pound=yes
            --pound-force-ssl=yes
            --pound-force-ssl-domain=front.local
            --pound-http-port=80
            --pound-https-port=443
            --pound-backend-ip=127.0.0.1
            --pound-backend-port=8080        
        "
        server.vm.provision :shell, path: "./bootstrap.sh", args: _args.gsub(/\s+/, " ").strip
        server.hostmanager.aliases = "front.local"
    end


	if Vagrant.has_plugin?('vagrant-hostmanager')
		config.hostmanager.enabled = false
		config.vm.provision :hostmanager
  		config.hostmanager.manage_host = true
  		config.hostmanager.ignore_private_ip = false
  		config.hostmanager.include_offline = true
	end
end
