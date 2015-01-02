Vagrant Box for LAMP/LEMP stack ready to develop
===========

This repository provides a very simple way to start a new PHP project with all useful tools that you need
------------------------------------------------------------------------
* A box based on [Debian7](https://www.debian.org/index.fr.html) up to date when vagrant up
* This box is a very lightweight installation > just the kernel and those package : 
	* git 
	* bzip2 
	* gzip 
	* iptraf 
	* lsb-release 
	* update-notifier-common
* A personnalized motd show up some useful information about the server when user connect throw ssh
* Based on this Vagrantfile, you will be able to start up from one to many server to emulate a production environment.

__For now__
* You can setup a VM based on PHP 5.4, 5.5 or 5.6 
* The machine comes with Apache, PerconaDB and PhpMyAdmin
* The opcode is enable and can be monitored by /tools/opcode alias

__Roadmap__
* It's possible to configure multiple vm's and setup services on targeted vm to emulate production envrionnement
* All vm's are monitored by [zabbix](http://www.zabbix.com/)
* 

__This vagrant box and install script use this services : __

<img src="https://www.vagrantup.com/images/logo_vagrant-81478652.png" alt="logo of Vagrant" style="height:60px" height="60" />    <img src="http://www.itx-server.com/image/data/logos/virtualbox_logo.png" alt="logo of VirtualBox" height="60" />    <img src="http://media.laruche.com/2012/11/debian-logo-horizontal.gif" alt="logo of debian"  height="60"  />     <img src="http://www.technologix.be/sites/default/files/field/image/apache-logo.png" alt="logo of apache" height="60" />     <img src="https://s3-eu-west-1.amazonaws.com/shailan.static/wp-content/uploads/nginx-logo-1.png" alt="logo of nginx" height="60" />    <img src="http://upload.wikimedia.org/wikipedia/en/5/5e/Xdebug-logo.png" alt="logo of xdebug" height="60" />    <img src="http://php.net/images/logos/php-med-trans-light.gif" alt="logo of php" height="60" /><img src="http://www.percona.com/static/images/logo_percona_server_new.png" alt="logo of percona" height="60" />    <img src="http://www.zabbix.com/img/logo/zabbix_logo_500x131.png" alt="logo of php" height="60" />