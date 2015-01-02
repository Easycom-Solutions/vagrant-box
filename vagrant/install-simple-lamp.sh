#!/bin/bash
_error=0
##########################################################################################
# Let's start with few controls to be sure that argument are OK
##########################################################################################
if [ $# -ne 4 ]; 
    then echo -e "This script requires 4 arguments to be executed as well
        usage : script.sh \$1 \$2 \$3 \$4 
        where :
        \$1 :  version of php required (php54, php55, php56)
        \$2 :  opcache memory consomption (128Mb seems to be a good start, need to be monitored)
        \$3 :  opcache number of files accelerated : need to be up than number of php files in your hosted project to be efficient
        \$4 :  y/n to secure tools path with basic credentials >> every hhtp tools like phpmyadmin will be accessible by the ip 
               or servername of the server under the tools suffix like http://localhost:8080/tools/phpmyadmin
               by default, the credentials are easycom:solutions; it can be changed by editing /var/www/default/tools/.htpasswd file
        "
        exit 1
fi

if [ ! $1 = 'php54' ] && [ ! $1 = 'php55' ] && [ ! $1 = 'php56' ]; then
        echo "bad argument for php version"
        _error=1
fi
re='^[0-9]+$'
if ! [[ $2 =~ $re ]]; then
        echo "second argument for the memory allocated to the opcode need to be an integer (ex : 128 for 128 Mb)"
        _error=1
fi
if ! [[ $3 =~ $re ]]; then
        echo "third argument need to be an integer"
        _error=1
fi
if [[ ! $4 =~ ^[Nn]$ ]] && [[ ! $4 =~ ^[Yy]$ ]]; then
        echo "the fourth argument need to be y/n statement" 
        _error=1
fi
if [[ $_error = 1 ]]; then exit 1; fi

##########################################################################################
# Now we have good argument, let's go to install few helpfull packages
##########################################################################################
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y git bzip2 gzip iptraf lsb-release update-notifier-common
sudo apt-get install -y debconf-utils 

##########################################################################################
# Let's configure dotdeb repo to get the good version of php then install php
##########################################################################################
if [[ $1 = "php55" ]]; then
	echo "-> Installation du repo dotdeb pour PHP 5.5"
	sudo sh -c 'echo "deb http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list.d/dotdeb.list'
	sudo sh -c 'echo "deb-src http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list.d/dotdeb.list'
elif [[ $1 = "php56" ]]; then
	echo "-> Installation du repo dotdeb pour PHP 5.6"
	sudo sh -c 'echo "deb http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list.d/dotdeb.list'
	sudo sh -c 'echo "deb-src http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list.d/dotdeb.list'
else
	echo "-> Installation du repo dotdeb"
	sudo sh -c 'echo "deb http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list.d/dotdeb.list'
	sudo sh -c 'echo "deb-src http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list.d/dotdeb.list'
fi	

cd /tmp
wget http://www.dotdeb.org/dotdeb.gpg
sudo apt-key add dotdeb.gpg
echo "-> Update APT with the new repository then upgrade if needed"
sudo apt-get update
sudo apt-get upgrade

echo "-> Install PHP5 and some associated libs // php5 package include the installation of apache2"
sudo apt-get install -y php5 php-pear php5-dev php5-imagick php5-gd php5-mcrypt php5-curl php5-redis php5-mysql

#
# Configure PHP 5
#
echo "-> Enable apache mod php5"
sudo a2enmod php5

if [[ $1 = "php54" ]]; then
	echo "-> Installation de l'opcode pour PHP 5.4"
	sudo pear config-set preferred_state beta
	sudo pecl install ZendOpCache
	sudo sh -c 'echo "zend_extension=/usr/lib/php5/20100525/opcache.so" > /etc/php5/mods-available/opcache.ini' 
fi	
#
# Magento 1.9 had 8273 PHP files and 1151 PHTML files out of the box, and default max_accelerated_files is 2000, so that's not enough
#
echo "-> Configure zend opcode $2M of cache and $3 files as max_accelerated_files"
cp  /etc/php5/mods-available/opcache.ini ./opcache.ini
echo "opcache.memory_consumption=$2" >> ./opcache.ini
echo "opcache.max_accelerated_files=$3" >> ./opcache.ini
sudo mv ./opcache.ini /etc/php5/mods-available/opcache.ini

echo "-> Enable opcache for PHP"
sudo php5enmod opcache

#
# Configure Apache
#
echo "-> Enable apache mod_rewrite"
sudo a2enmod rewrite

echo "-> Enable apache mod_deflate"
sudo a2enmod deflate

echo "-> Enable apache mod_headers"
sudo a2enmod headers

echo "-> Configure ServerName to lamp to avoid the classic warning message at restart"
sh -c 'echo "ServerName lamp" > /etc/apache2/conf.d/servername'

echo "-> Make the info.php file accessible via /tools/info.php"
sudo mkdir -p /var/www/default/tools
sudo sh -c 'echo "<?php phpinfo(); ?>" >> /var/www/default/tools/info.php'

echo "--> Remove default configuration"
sudo mkdir _bak
sudo mv /etc/apache2/sites-available/* _bak/
sudo mv _bak /etc/apache2/sites-available/
sudo rm -Rf /etc/apache2/sites-enabled/*

echo "--> Create the default configuration for apache (will respond to http://127.0.0.1:{port}/ or http://lamp:{port}/ "
echo "--> Tools like phpmyadmin or info.php will be only accessible throw this vhost"
echo -e '
<VirtualHost *:80>
    DocumentRoot /var/www/default

    <Directory /var/www/default>
        Options none
        AllowOverride None
	</Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    Include conf.d/*.conf.vhost-default
</VirtualHost>' > ./default

sudo mv ./default /etc/apache2/sites-available/
sudo a2ensite default

echo "--> Create the configuration our project (will respond to http://localhost:{port}/) "
echo -e '
<VirtualHost *:80>
    DocumentRoot /var/www/htdocs
	ServerAlias localhost
    <Directory /var/www/htdocs>
        Options none
        AllowOverride None
	</Directory>

    ErrorLog ${APACHE_LOG_DIR}/htdocs-error.log
    CustomLog ${APACHE_LOG_DIR}/htdocs-access.log combined
</VirtualHost>' > ./localhost

sudo mv ./localhost /etc/apache2/sites-available/
sudo a2ensite localhost
#
# Add an .htpasswd file to secure /tools alias if required 
#
if [[ $4 = "y" ]]; then
    echo "--> Secure the /tools alias by an .htpasswd file // default access are : easycom:solutions"
    echo -e '<Directory /var/www/default/tools>
    AuthUserFile /var/www/default/tools/.htpasswd
    AuthName "Accès Restreint"
    AuthType Basic
    require valid-user
    </Directory>' > ./default-tools-secure.conf.vhost-default
    sudo mv ./default-tools-secure.conf.vhost-default /etc/apache2/conf.d/
    sudo sh -c 'echo "easycom:\$apr1\$i8wJpsAS$/RA8nuih5f5NVVcv1lLxL/\n" > /var/www/default/tools/.htpasswd'
fi

#
# Add an interface for opcode stats (OpCacheGui is only compatible for php5.5+
#
if [[ ! $1 = "php54" ]]; then
    echo "-> Installation de OpCacheGUI depuis github"
    git clone https://github.com/PeeHaa/OpCacheGUI.git
    file=$(cat <<EOF
<?php
namespace OpCacheGUI;
use OpCacheGUI\I18n\FileTranslator;
use OpCacheGUI\Network\Router;
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 0);
ini_set('date.timezone', 'Europe/Paris');
\$translator = new FileTranslator(__DIR__ . '/texts', 'fr');
\$uriScheme = Router::QUERY_STRING;
\$login = [ 'username' => '', 'password' => '', 'whitelist' => [ '*' ] ];
EOF
)
    echo "$file" > OpCacheGUI/init.example.php
    sudo mv OpCacheGUI /var/www/default/tools/opcache
else
    echo "-> Installation of opcache-gui from github"
    git clone https://github.com/amnuts/opcache-gui.git
    sudo mv opcache-gui /var/www/default/tools/opcache
fi

##########################################################################################
# Install of PerconaDB 5.6 database server
##########################################################################################

echo "--> Installation of percona-server-server-56"
sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
sudo sh -c 'echo "deb http://repo.percona.com/apt wheezy main" >> /etc/apt/sources.list.d/percona.list'
sudo sh -c 'echo "deb-src http://repo.percona.com/apt wheezy main" >> /etc/apt/sources.list.d/percona.list'

sudo apt-get update
echo "--> Set "vagrant" as root password for mysql"
sudo sh -c 'echo "percona-server-server-5.6 percona-server-server/root_password password vagrant" | debconf-set-selections'
sudo sh -c 'echo "percona-server-server-5.6 percona-server-server/root_password_again password vagrant" | debconf-set-selections'
sudo apt-get install -y --force-yes percona-server-server-5.6 percona-server-client-5.6
echo "--> Execution of mysql_secure_installation"
echo -e "vagrant\nn\ny\ny\ny\ny" > tmp.txt
sudo mysql_secure_installation < tmp.txt

##########################################################################################
# Install of PHPMyAdmin for local database
##########################################################################################
echo "--> Setup debconf variables for silent install"
sudo sh -c 'echo "pphpmyadmin  phpmyadmin/app-password-confirm password vagrant" | debconf-set-selections'
sudo sh -c 'echo "pphpmyadmin  phpmyadmin/mysql/admin-pass password vagrant" | debconf-set-selections'
sudo sh -c 'echo "pphpmyadmin  phpmyadmin/password-confirm password vagrant" | debconf-set-selections'
sudo sh -c 'echo "pphpmyadmin  phpmyadmin/setup-password   password vagrant" | debconf-set-selections'
sudo sh -c 'echo "pphpmyadmin  phpmyadmin/mysql/app-pass   password" | debconf-set-selections'
sudo sh -c 'echo "pphpmyadmin  phpmyadmin/reconfigure-webserver    multiselect apache2" | debconf-set-selections'
sudo sh -c 'echo "pphpmyadmin  phpmyadmin/dbconfig-install boolean true" | debconf-set-selections'
sudo sh -c 'echo "pphpmyadmin  phpmyadmin/dbconfig-upgrade boolean true" | debconf-set-selections'
sudo apt-get install -y phpmyadmin

echo "-> Update phpmyadmin alias to be accesible by /tools/phpmyadmin only from the default vhost"
sudo sed -i 's,Alias /phpmyadmin /usr/share/phpmyadmin,# Alias /phpmyadmin /usr/share/phpmyadmin,' /etc/apache2/conf.d/phpmyadmin.conf
sudo sh -c 'echo "Alias /tools/phpmyadmin /usr/share/phpmyadmin" > /etc/apache2/conf.d/phpmyadmin.conf.vhost-default'

echo "--> Enable default vhost and restart apache"
sudo a2ensite default
sudo service apache2 restart

echo "--> End of install of the LAMP stack"


sudo pecl install xdebug
file=$(cat <<EOF
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.profiler_enable_trigger = 1
EOF
)
sudo echo "$file" > xdebug.ini
sudo mv xdebug.ini /etc/php5/mods-available/
sudo service apache2 restart
exit 0;
