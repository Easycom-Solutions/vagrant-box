#!/bin/bash

##########################################################################################
# Let's start with help statement
##########################################################################################
if [[ $# = 0 ]]; then
	echo 'This script require some arguments to do something, try --help to show options'
	exit 0;
fi

bold=`tput bold`
normal=`tput sgr0`
green=`tput bold; tput setaf 2`

usage=$(cat <<EOF
This script requires some arguments
usage : ./$(basename "$(test -L "$0" && readlink "$0" || echo "$0")") --option1=value --option2=value [[option...]]
where options are :
	${green}Arguments to tell if a service will be installed by the script${normal}
	${bold}--install-varnish${normal} 		: yes/no statement
	${bold}--install-pound${normal} 		: yes/no statement, pound is usefull to get https works with varnish
	${bold}--install-nginx${normal} 		: yes/no statement >> TODO >> not implemented for now 
	${bold}--install-apache${normal} 		: yes/no statement
	${bold}--install-php${normal} 			: yes/no statement, this will install php5-fpm and configure apache2 if installed
	${bold}--install-phpmyadmin${normal} 		: yes/no statement, note that this should be yes only if install-apache and install-php argument are on yes to, this will install mysql-client
	${bold}--install-mysql-server${normal} 		: yes/no statement
	${bold}--install-mysql-client${normal} 		: yes/no statement
	${bold}--install-redis${normal} 		: yes/no statement
	${bold}--install-solr${normal} 			: yes/no statement
	${bold}--install-zabbix-server${normal} 	: yes/no statement >> TODO >> not implemented for now 
	${bold}--install-zabbix-client${normal} 	: yes/no statement >> TODO >> not implemented for now 
	${bold}--install-redmin${normal} 		: yes/no statement >> TODO >> not implemented for now 
	${bold}--install-redis-commander${normal}	: yes/no statement
	${bold}--install-mailcatcher${normal}		: yes/no statement
	${bold}--install-pagespeed${normal}		: yes/no statement
	${bold}--install-memcached${normal}		: yes/no statement
	${bold}--install-ffmpeg${normal}		: yes/no statement

	${green}Required arguments if '--install-mysql-server=yes'${normal}
	${bold}--mysql-root-password${normal} 		: define the password for mysql's server root user
	${bold}--mysql-allow-remote${normal} 		: yes/no statement (default: yes), define if the mysql server will listen on 0.0.0.0 (yes) or 127.0.0.1 (no)
	${bold}--mysql-allow-remote-root${normal} 	: yes/no statement (default: yes), define if the mysql's user 'root' can login remotely (need --mysql-allow-remote=yes)
	${bold}--mysql-createdb${normal}		: yes/no statement
	${bold}--mysql-dbname${normal} 			: required if --mysql-createdb=yes, define the name of the database to create
	${bold}--mysql-dbuser${normal} 			: required if --mysql-createdb=yes, define the name of the user that manage the database
	${bold}--mysql-dbpass${normal} 			: required if --mysql-createdb=yes, define the password of the database's user

	${green}Required arguments if '--install-php=yes'${normal}
	${bold}--php-version${normal} 				: version of php to install, valid value are [[php54, php55, php56]]
	${bold}--php-opcache-memory${normal} 			: (integer), opcache memory consomption (128Mb seems to be a good start, need to be monitored)
	${bold}--php-opcache-max-accelerated-files${normal} 	: (integer), opcache number of files accelerated : need to be up than number of php files in your hosted project to be efficient

	${green}Optionnals arguments if '--install-php=yes' to install some pecl extensions${normal}
	${bold}--php-install-xdebug${normal}			: yes/no statement
	${bold}--php-install-redis${normal}			: yes/no statement
	${bold}--php-install-memcache${normal}			: yes/no statement
	${bold}--php-install-uploadprogress${normal}		: yes/no statement

	${green}Optionnals arguments if '--install-php=yes' to install some cli tools ${normal}
	${bold}--php-install-composer${normal}			: yes/no statement
	${bold}--php-install-drush${normal}			: yes/no statement
	${bold}--php-install-drush-version${normal}			: (optionnal, default value : 6.5.0)
	${bold}--php-install-magerun${normal}		: yes/no statement
	${bold}--php-install-wpcli${normal}			: yes/no statement

	${green}Required arguments if '--install-apache=yes'${normal}
	${bold}--apache-port${normal} 			: (integer - default:80), define listened port by apache
	${bold}--apache-ssl-port${normal} 		: (integer - default:443), define listened port by apache for ssl
	
		${green}A default vhost will be set to access some usefull tools${normal}
		${bold}--apache-tools-secure${normal} 		: yes/no statement 
		${bold}--apache-tools-username${normal} 	: username if '--apache-tools-secure=yes'
		${bold}--apache-tools-pass${normal} 		: password if '--apache-tools-secure=yes'
	
		${green}If file conf/localhost.vhost if found, it will be put in place of default generated configuration${normal}
		${bold}--apache-localhost-aliases${normal} 	: Project aliases (like 'local.front local.www1 local.www2') to configure project vhost (named 'localhost'), this will update localhost.vhost imported from project if exist
		${bold}--apache-localhost-forcessl${normal} 	: Define if the project must use only ssl, may not work if localhost.vhost was imported and doesn't contain the required lines '# Rewrite' (look in the script for details)

	${green}Required arguments if '--install-phpmyadmin=yes'${normal}
	${bold}--phpmyadmin-server-ip${normal} 		: if you set '127.0.0.1', the script will set socket use instead of ip
	${bold}--phpmyadmin-server-port${normal} 	: (integer - default:3306) required if don't use socket and custom port was define on mysql-server
	${bold}--phpmyadmin-server-user${normal} 	: (default : root)
	${bold}--phpmyadmin-server-password${normal}	: required
	${bold}--phpmyadmin-auth-type${normal}	: (string, 'cookie' or 'config')

	${green}Required arguments if '--install-redis=yes'${normal}
	${bold}--redis-port${normal} 		: required, define the port used by redis
	${bold}--redis-usage${normal} 		: required (string : 'session' or 'cache'), cache instance will use only memory and don't write on disk
	${bold}--redis-max-memory${normal}	: (integer - optionnal), if --redis-usage=cache, this argument will allow to limit memory usage

	${green}Required arguments if '--install-redmin=yes'${normal}
	${bold}--redmin-server-ip${normal} 		: required

	${green}Required arguments if '--install-commander=yes'${normal}
	${bold}--redis-commander-server-port${normal} 	: TODO // not implemented
	${bold}--redis-commander-server-host${normal} 	: TODO // not implemented
	${bold}--redis-commander-port${normal}		: (default: 8081)
	${bold}--redis-commander-listen${normal}	: (default: 0.0.0.0)
	${bold}--redis-commander-url${normal}		: required to enable entry in index.html file
	
	${green}Required arguments if '--install-memcached=yes'${normal}
	${bold}--memcached-port${normal} 		: required, define the port used by memcached instance (ex : 11211)
	${bold}--memcached-max-memory${normal}	: (integer - optionnal), this argument will allow to limit memory usage (ex : 64 for 64mb)

	${green}Required arguments if '--install-varnish=yes'${normal}
	${bold}--varnish-listen-port${normal} 	: (default: 80)
	${bold}--varnish-admin-listen${normal} 	: (default: 0.0.0.0)
	${bold}--varnish-admin-port${normal}	: (default: 6082)
	${bold}--varnish-backend-ip${normal} 	: The minimum number of worker threads to start (\$((800/<Number of CPU cores>)))
	${bold}--varnish-backend-port${normal} 	: The Maximum number of worker threads to start
	${bold}--varnish-storage-size${normal}	: size like 1G or percentage of free memory like 90%

	${green}Required arguments if '--install-solr=yes'${normal}
	${bold}--solr-version${normal} 		: (default: 4.10.3)
	${bold}--solr-instance${normal} 	: required string value (ex : default, magento, drupal, etc)
	${bold}--solr-instance-url${normal} 	:  required to enable entry in index.html file
	${bold}--tomcat-port${normal} 		: (default: 8080)
	${bold}--tomcat-admin-login${normal} 	: required
	${bold}--tomcat-admin-password${normal} : required

	${green}Required arguments if '--install-pound=yes'${normal}
	${bold}--pound-force-ssl${normal} 		: yes/no statement, default no
	${bold}--pound-force-ssl-domain${normal} 	: required string value (ex : front.local)
	${bold}--pound-http-port${normal} 		: (default: 80)
	${bold}--pound-https-port${normal} 		: (default: 443)
	${bold}--pound-backend-ip${normal} 		: (default: 127.0.0.1)
	${bold}--pound-backend-port${normal} 		: (default: 8080)

EOF
)


##########################################################################################
# Collect arguments and define vars
##########################################################################################
_error=0

for i in "$@"
do
	key="$i"
	case $key in
		--install-varnish=*)
			_install_varnish_="${i#*=}"
			shift;;
		--install-pound=*)
			_install_pound_="${i#*=}"
			shift;;
		--install-nginx=*)
			_install_nginx_="${i#*=}"
			shift;;
		--install-apache=*)
			_install_apache_="${i#*=}"
			shift;;
		--install-php=*)
			_install_php_="${i#*=}"
			shift;;
		--install-phpmyadmin=*)
			_install_phpmyadmin_="${i#*=}"
			shift;;
		--install-mysql-server=*)
			_install_mysql_server_="${i#*=}"
			shift;;
		--install-mysql-client=*)
			_install_mysql_client_="${i#*=}"
			shift;;
		--install-redis=*)
			_install_redis_="${i#*=}"
			shift;;
		--install-solr=*)
			_install_solr_="${i#*=}"
			shift;;
		--install-zabbix-server=*)
			_install_zabbix_server_="${i#*=}"
			shift;;
		--install-zabbix-client=*)
			_install_zabbix_client_="${i#*=}"
			shift;;
		--install-pagespeed=*)
			_install_pagespeed_="${i#*=}"
			shift;;
		--install-redmin=*)
			_install_redmin_="${i#*=}"
			shift;;
		--install-redis-commander=*)
			_install_redis_commander_="${i#*=}"
			shift;;
		--install-mailcatcher=*)
			_install_mailcatcher_="${i#*=}"
			shift;;
		--install-memcached=*)
			_install_memcached_="${i#*=}"
			shift;;
		--install-ffmpeg=*)
			_install_ffmpeg_="${i#*=}"
			shift;;

		--mysql-root-password=*)
			_mysql_root_password_="${i#*=}"
			shift;;
		--mysql-allow-remote=*)
			_mysql_allow_remote_="${i#*=}"
			shift;;
		--mysql-allow-remote-root=*)
			_mysql_allow_remote_root_="${i#*=}"
			shift;;
		--mysql-createdb=*)
			_mysql_createdb_="${i#*=}"
			shift;;
		--mysql-dbname=*)
			_mysql_dbname_="${i#*=}"
			shift;;
		--mysql-dbuser=*)
			_mysql_dbuser_="${i#*=}"
			shift;;
		--mysql-dbpass=*)
			_mysql_dbpass_="${i#*=}"
			shift;;


		--php-version=*)
			_php_version_="${i#*=}"
			shift;;
		--php-opcache-memory=*)
			_php_opcache_memory_="${i#*=}"
			shift;;
		--php-opcache-max-accelerated-files=*)
			_php_opcache_max_accelerated_files_="${i#*=}"
			shift;;
		--php-install-xdebug=*)
			_php_install_xdebug_="${i#*=}"
			shift;;
		--php-install-redis=*)
			_php_install_redis_="${i#*=}"
			shift;;
		--php-install-memcache=*)
			_php_install_memcache_="${i#*=}"
			shift;;
		--php-install-uploadprogress=*)
			_php_install_uploadprogress_="${i#*=}"
			shift;;

		--php-install-composer=*)
			_php_install_composer_="${i#*=}"
			shift;;
		--php-install-magerun=*)
			_php_install_n98magerun_="${i#*=}"
			shift;;
		--php-install-wpcli=*)
			_php_install_wpcli_="${i#*=}"
			shift;;
		--php-install-drush=*)
			_php_install_drush_="${i#*=}"
			shift;;
		--php-install-drush-version=*)
			_php_install_drush_version_="${i#*=}"
			shift;;


		--apache-port=*)
			_apache_port_="${i#*=}"
			shift;;
		--apache-ssl-port=*)
			_apache_ssl_port_="${i#*=}"
			shift;;
		--apache-localhost-aliases=*)
			_apache_localhost_aliases_="${i#*=}"
			shift;;
		--apache-localhost-forcessl=*)
			_apache_localhost_forcessl_="${i#*=}"
			shift;;
		--apache-tools-secure=*)
			_apache_tools_secure_="${i#*=}"
			shift;;
		--apache-tools-username=*)
			_apache_tools_username_="${i#*=}"
			shift;;
		--apache-tools-pass=*)
			_apache_tools_pass_="${i#*=}"
			shift;;


		--phpmyadmin-server-ip=*)
			_phpmyadmin_server_ip_="${i#*=}"
			shift;;
		--phpmyadmin-server-port=*)
			_phpmyadmin_server_port_="${i#*=}"
			shift;;
		--phpmyadmin-server-user=*)
			_phpmyadmin_server_user_="${i#*=}"
			shift;;
		--phpmyadmin-server-password=*)
			_phpmyadmin_server_password_="${i#*=}"
			shift;;
		--phpmyadmin-auth-type=*)
			_phpmyadmin_auth_type_="${i#*=}"
			shift;;
			
		--redis-usage=*)
			_redis_usage_="${i#*=}"
			shift;;
		--redis-port=*)
			_redis_port_="${i#*=}"
			shift;;
		--redis-max-memory=*)
			_redis_max_memory_="${i#*=}"
			shift;;
			

		--redmin-server-ip=*)
			_redmin_server_ip_="${i#*=}"
			shift;;


		--redis-commander-server-port=*)
			_redis_commander_server_port_="${i#*=}"
			shift;;
		--redis-commander-server-host=*)
			_redis_commander_server_host_="${i#*=}"
			shift;;
		--redis-commander-port=*)
			_redis_commander_port_="${i#*=}"
			shift;;
		--redis-commander-listen=*)
			_redis_commander_listen_="${i#*=}"
			shift;;
		--redis-commander-url=*)
			_redis_commander_url_="${i#*=}"
			shift;;

		--memcached-port=*)
			_memcached_port_="${i#*=}"
			shift;;
		--memcached-max-memory=*)
			_memcached_max_memory_="${i#*=}"
			shift;;

		--varnish-listen-port=*)
			_varnish_listen_port_="${i#*=}"
			shift;;
		--varnish-admin-listen=*)
			_varnish_admin_listen_="${i#*=}"
			shift;;
		--varnish-admin-port=*)
			_varnish_admin_port_="${i#*=}"
			shift;;
		--varnish-backend-ip=*)
			_varnish_backend_ip_="${i#*=}"
			shift;;
		--varnish-backend-port=*)
			_varnish_backend_port_="${i#*=}"
			shift;;
		--varnish-storage-size=*)
			_varnish_storage_size_="${i#*=}"
			shift;;
    		
    	--solr-version=*)
			_solr_version_="${i#*=}"
			shift;;
		--solr-instance=*)
			_solr_instance_="${i#*=}"
			shift;;
		--solr-instance-url=*)
			_solr_instance_url_="${i#*=}"
			shift;;
		--tomcat-port=*)
			_tomcat_port_="${i#*=}"
			shift;;
		--tomcat-admin-login=*)
			_tomcat_admin_login_="${i#*=}"
			shift;;
		--tomcat-admin-password=*)
			_tomcat_admin_password_="${i#*=}"
			shift;;

		--pound-force-ssl=*)
			_pound_force_ssl_="${i#*=}"
			shift;;
		--pound-force-ssl-domain=*)
			_pound_force_ssl_domain_="${i#*=}"
			shift;;
		--pound-http-port=*)
			_pound_http_port_="${i#*=}"
			shift;;
		--pound-https-port=*)
			_pound_https_port_="${i#*=}"
			shift;;
		--pound-backend-ip=*)
			_pound_backend_ip_="${i#*=}"
			shift;;
		--pound-backend-port=*)
			_pound_backend_port_="${i#*=}"
			shift;;
   		
    	--help)
    		echo -e "$usage"
    		exit 0;
    		shift;;
    		
    	*)
    	 echo "$1 unknown argument" ;;
	esac 
done

##########################################################################################
# Some controls on argument before processing anything
##########################################################################################

# ----------------------------------------------------------------------------------------
# -> controls for percona server vars
# ----------------------------------------------------------------------------------------
if [[ $_install_mysql_server_ = 'yes' ]]; then
	if [[ $_mysql_root_password_ = '' ]] ; then
    	echo "error : the argument '--mysql-root-password' is required" 
        _error=1
	fi
	if [[ $_mysql_allow_remote_ = '' ]]; then
        _mysql_allow_remote_='yes'
	fi
	if [[ ! $_mysql_allow_remote_ = 'no' ]] && [[ ! $_mysql_allow_remote_ = 'yes' ]]; then
        echo "error : the argument '--allow-remote-access' need to be yes/no statement" 
        _error=1
	fi
	if [[ $_mysql_allow_remote_root_ = '' ]]; then 
		_mysql_allow_remote_root_='yes' 
	fi
	if [[ ! $_mysql_allow_remote_root_ = 'no' ]] && [[ ! $_mysql_allow_remote_root_ = 'yes' ]]; then
        echo "error : the argument '--mysql-allow-remote-root' need to be yes/no statement" 
        _error=1
	fi
	if [[ $_mysql_createdb_ = 'yes' ]]; then
		if [[ $_mysql_dbname_ = '' ]] || [[ $_mysql_dbuser_ = '' ]] || [[ $_mysql_dbpass_ = '' ]]; then
			echo "error : if a database is define for the project, you must define dbname, user and password" 
			_error=1
		fi
	fi
	
	# Define as unique caracter the parameter for remote root login because mysql_secure_installation require a y/n statement
	if [[ $_mysql_allow_remote_root_ = 'no' ]]; then
		DISALLOW_REMOTE_ACCESS_BY_ROOT='y'
	fi
	if [[ $_mysql_allow_remote_root_ = 'yes' ]]; then
		DISALLOW_REMOTE_ACCESS_BY_ROOT='n'
	fi
fi 

# ----------------------------------------------------------------------------------------
# -> controls for apache server vars
# ----------------------------------------------------------------------------------------
if [[ $_install_apache_ = 'yes' ]]; then
	# Set default value for apache install
	if [[ $_apache_port_ = '' ]]; then 
		_apache_port_='80' 
	fi
	# If apache port is 80 and varnish to, on the same server, we change apache for 8080
	if [[ $_install_varnish_ = 'yes' ]] && [[ $_varnish_listen_port_ = '80' ]] && [[ $_apache_port_ = '80' ]]; then 
		_apache_port_='8080'
		echo "-> The port for apache was changed to 8080 to avoid varnish conflict"
	fi
	# set default value for ssl listened port
	if [[ $_apache_ssl_port_ = '' ]]; then 
		_apache_ssl_port_='443' 
	fi
	# set default value to no to force https when http
	if [[ $_apache_localhost_forcessl_ = '' ]]; then 
		_apache_localhost_forcessl_='no' 
	fi
	# check if user correctly define a yes/no value
	if [[ ! $_apache_localhost_forcessl_ = 'no' ]] && [[ ! $_apache_localhost_forcessl_ = 'yes' ]]; then
        echo "error : the argument '--apache-localhost-forcessl' need to be yes/no statement" 
        _error=1
	fi
	# set default value to no to don't secure the '/tools/' path by .htpasswd
	if [[ $_apache_tools_secure_ = '' ]]; then 
		_apache_tools_secure_='no' 
	fi
	# check if user correctly define a yes/no value
	if [[ ! $_apache_tools_secure_ = 'no' ]] && [[ ! $_apache_tools_secure_ = 'yes' ]]; then
        echo "error : the argument '--apache-tools-secure' need to be yes/no statement" 
        _error=1
	fi
	# If we have to secure the '/tools/' path, we check if username and password are provided
	if [[ $_apache_tools_secure_ = 'yes' ]]; then
        if [[ $_apache_tools_username_ = '' ]] || [[ $_apache_tools_pass_ = '' ]]; then
			echo "error : if you want to secure tools path, you must define --apache--tools-username and --apache-tools-password arguments" 
			_error=1
		fi
	fi
fi

# ----------------------------------------------------------------------------------------
# -> controls for php server vars
# ----------------------------------------------------------------------------------------
if [[ $_install_php_ = 'yes' ]]; then
	# Set default value for apache install
	_php_version__default_value='php56'
	if [[ ! $_php_version_ = 'php54' ]] && [[ ! $_php_version_ = 'php55' ]] && [[ ! $_php_version_ = 'php56' ]]; then 
		_apache_tools_secure_=$_php_version__default_value 
		echo "warn : the argument defined for php version is not valid, the version was reset to default value : $_php_version__default_value" 
	fi
	if [[ $_php_version_ = '' ]]; then 
		_php_version_=$_php_version__default_value 
	fi	
	
	re='^[0-9]+$'
	# If arguments are provided, check if integer type is repected
	if [[ ! $_php_opcache_memory_ = '' ]] && [[ ! $_php_opcache_memory_ =~ $re ]]; then
        echo "error : --php-opcache-memory argument value need to be an integer (ex : 128 for 128 Mb)"
        _error=1
	fi
	if [[ ! $_php_opcache_max_accelerated_files_ = '' ]] && [[ ! $_php_opcache_max_accelerated_files_ =~ $re ]]; then
        echo "error : --php-opcache-max-accelerated-files argument value need to be an integer"
        _error=1
	fi
	if [[ $_php_install_xdebug_ = '' ]]; then 
		_php_install_xdebug_='no' 
	fi
	if [[ $_php_install_drush_ = 'yes' ]] && [[ $_php_install_drush_version_ = '' ]]; then 
		_php_install_drush_version_='6.5.0' 
	fi
fi

# ----------------------------------------------------------------------------------------
# -> controls for phpmyadmin vars
# ----------------------------------------------------------------------------------------
if [[ $_install_phpmyadmin_ = 'yes' ]]; then
	
	# Check if required arguments are provided
	if [[ $_phpmyadmin_server_user_ = '' ]] || [[ $_phpmyadmin_server_password_ = '' ]]; then
        echo "error : --phpmyadmin-server-user and --phpmyadmin-server-password arguments are required"
        _error=1
	fi	
	
	# Set default value for server ip	
	if [[ $_phpmyadmin_server_ip_ = '' ]]; then 
		_phpmyadmin_server_ip_='127.0.0.1' 
	fi	
	
	re='^[0-9]+$'
	# If arguments are provided, check if integer type is repected
	if [[ ! $_phpmyadmin_server_port_ = '' ]] && [[ ! $_phpmyadmin_server_port_ =~ $re ]]; then
        echo "error : --php-opcache-memory argument value need to be an integer (ex : 128 for 128 Mb)"
        _error=1
	fi
	
	# Define default value for mysql port if not provided
	if [[ $_phpmyadmin_server_port_ = '' ]]; then
		_phpmyadmin_server_port_=3306
	fi
fi

# ----------------------------------------------------------------------------------------
# -> controls for solr vars
# ----------------------------------------------------------------------------------------
if [[ $_install_solr_ = 'yes' ]]; then

	# Set default value solr version	
	if [[ $_solr_version_ = '' ]]; then 
		_solr_version_='4.10.3' 
		echo "notice : --solr-version was not defined, default value is used : $_solr_version_"
	fi
	
	# Set default value solr instance name
	if [[ $_solr_instance_ = '' ]]; then
        _solr_instance_='default'
        echo "notice : --solr-instance was not defined, default value is used : 'default'"
	fi	
	
	# Set default value solr instance name
	re='^[0-9]+$'
	if [[ $_tomcat_port_ = '' ]]; then
        echo "notice : --tomcat-port is was not defined, default value will be use"
    elif [[ ! $_tomcat_port_ =~ $re ]]; then
        echo "error : --tomcat-port argument value need to be an integer (ex : 8080)"
        _error=1
	fi
	
	if [[ $_tomcat_admin_login_ = '' ]] || [[ $_tomcat_admin_password_ = '' ]]; then
        echo "error : --tomcat-admin-login and --tomcat-admin-password arguments are required"
        _error=1
	fi	
fi

# ----------------------------------------------------------------------------------------
# -> controls for redis vars
# ----------------------------------------------------------------------------------------
if [[ $_install_redis_ = 'yes' ]]; then

	# Check if required arguments are provided
	if [[ $_redis_usage_ = '' ]] || [[ $_redis_port_ = '' ]]; then
        echo "error : --redis-usage and --redis-port arguments are required"
        _error=1
	fi
	
	if [[ ! $_redis_usage_ = 'session' ]] && [[ ! $_redis_usage_ = 'cache' ]]; then
        echo "error : --redis-usage accepted values are only 'session' or 'cache'"
        _error=1
	fi

	# Check if port and memory are correct numbers
	re='^[0-9]+$'
	if [[ ! $_redis_port_ =~ $re ]]; then
        echo "error : --redis-port argument value need to be an integer (ex : 6380)"
        _error=1
	fi
	
	if [[ ! $_redis_max_memory_ = '' ]] && [[ ! $_redis_max_memory_ =~ $re ]]; then
        echo "error : --redis-max-memory argument value need to be an integer (ex : 128 for 128 Mb)"
        _error=1
	fi	
fi

# ----------------------------------------------------------------------------------------
# -> controls for memcached vars
# ----------------------------------------------------------------------------------------
if [[ $_install_memcached_ = 'yes' ]]; then

	# Check if required arguments are provided
	if [[ $_memcached_max_memory_ = '' ]] || [[ $_memcached_port_ = '' ]]; then
        echo "error : --memcached-port and --memcached-max-memory arguments are required"
        _error=1
	fi

	# Check if port and memory are correct numbers
	re='^[0-9]+$'
	if [[ ! $_memcached_port_ = '' ]] && [[ ! $_memcached_port_ =~ $re ]]; then
        echo "error : --memcached-port argument value need to be an integer (ex : 6380)"
        _error=1
	fi
	
	if [[ ! $_memcached_max_memory_ = '' ]] && [[ ! $_memcached_max_memory_ =~ $re ]]; then
        echo "error : --memcached-max-memory argument value need to be an integer (ex : 128 for 128 Mb)"
        _error=1
	fi	
fi

# ----------------------------------------------------------------------------------------
# -> controls for pound vars
# ----------------------------------------------------------------------------------------
if [[ $_install_pound_ = 'yes' ]]; then
	
	# Set default value for server ip	
	if [[ $_pound_force_ssl_ = 'yes' ]] && [[ $_pound_force_ssl_domain_ = '' ]]; then 
		echo "error : --pound-force-ssl-domain argument is required when --pound-force-ssl=yes"
        _error=1
	fi	
	
	re='^[0-9]+$'
	# If arguments are provided, check if integer type is repected
	if [[ $_pound_force_ssl_ = 'yes' ]] && [[ ! $_pound_http_port_ = '' ]] && [[ ! $_pound_http_port_ =~ $re ]]; then
        echo "error : --pound-http-port argument value need to be an integer (ex : 80)"
        _error=1
	fi

	if [[ ! $_pound_https_port_ = '' ]] && [[ ! $_pound_https_port_ =~ $re ]]; then
        echo "error : --pound-https-port argument value need to be an integer (ex : 443)"
        _error=1
	fi
	
	# Define default value for mysql port if not provided
	if [[ $_pound_backend_ip_ = '' ]]; then
		_pound_backend_ip_='127.0.0.1'
	fi
	if [[ $_pound_backend_port_ = '' ]]; then
		_pound_backend_port_='8080'
	fi
fi

# ----------------------------------------------------------------------------------------
if [[ $_error = 1 ]]; then exit 1; fi

##########################################################################################
# Now we have good argument, let's go to install few helpfull packages
##########################################################################################
export DEBIAN_FRONTEND=noninteractive
cd /tmp

_conf_folder_=$(find /vagrant/ -name conf)
if [[ "" = $_conf_folder_ ]]; then
    _conf_folder_=$_conf_folder_ 
    sudo mkdir -p $_conf_folder_
fi
_vagrant_folder_=$(find /vagrant/ -name .vagrant)

if [[ ! -f /etc/apt/sources.list.d/dotdeb.list ]]; then
	sudo sed -i "s,jessie main,jessie main contrib non-free," /etc/apt/sources.list
	
	echo "-> Installation of dotdeb default repository"
	sudo sh -c 'echo "deb http://packages.dotdeb.org jessie all" > /etc/apt/sources.list.d/dotdeb.list'
	sudo sh -c 'echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.list'	
	wget http://www.dotdeb.org/dotdeb.gpg
	sudo apt-key add dotdeb.gpg
fi

echo "-> Apt Update and upgrade of the system"
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y git bzip2 gzip iptraf lsb-release curl pwgen sysv-rc-conf htop iotop
sudo apt-get install -y debconf-utils 

##########################################################################################
# Generate SSL certificates if not exist for https support if required
##########################################################################################
if [[ ! -f $_vagrant_folder_/ssl/localhost.key ]] || [[ ! -f $_vagrant_folder_/ssl/localhost.crt ]] || [[ ! -f $_vagrant_folder_/ssl/localhost.pem ]]; then
	if [[ ! -d $_vagrant_folder_/ssl ]]; then
		echo "-> Create ssl directory in project folder to share the key between VMs"
		mkdir $_vagrant_folder_/ssl
	fi
	echo "-> Create the key file for ssl certificate"
	openssl genrsa -out $_vagrant_folder_/ssl/localhost.key 2048
	echo "-> Create the certificate with 10 years expiration time"
	openssl req -new -x509 -key $_vagrant_folder_/ssl/localhost.key -out $_vagrant_folder_/ssl/localhost.crt -days 3650 -subj /CN=localhost
	openssl x509 -in $_vagrant_folder_/ssl/localhost.crt -out $_vagrant_folder_/ssl/localhost.pem
	openssl rsa -in $_vagrant_folder_/ssl/localhost.key >> $_vagrant_folder_/ssl/localhost.pem
fi

echo "--> Copy ssl certificates previously generated to system"
sudo cp $_vagrant_folder_/ssl/localhost.key /etc/ssl/private/
sudo cp $_vagrant_folder_/ssl/localhost.crt /etc/ssl/certs/
sudo cp $_vagrant_folder_/ssl/localhost.pem /etc/ssl/certs/

echo "-> ------------------------------------------------------------------"
echo "-> End of install of commons"

##########################################################################################
# Install of PerconaDB 5.6 
##########################################################################################
if [[ $_install_mysql_server_ = 'yes' ]] || [[ $_install_mysql_client_ = 'yes' ]] || [[ $_install_phpmyadmin_ = 'yes' ]]; then

	echo "--> Installation of percona repository"
	#sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
	sudo sh -c 'wget -O - http://www.percona.com/redir/downloads/RPM-GPG-KEY-percona | gpg --import'
	sudo sh -c 'gpg --armor --export 1C4CBDCDCD2EFD2A | apt-key add -'
	sudo sh -c 'echo "deb http://repo.percona.com/apt wheezy main" > /etc/apt/sources.list.d/percona.list'
	sudo sh -c 'echo "deb-src http://repo.percona.com/apt wheezy main" >> /etc/apt/sources.list.d/percona.list'
	sudo apt-get update
	
	echo "--> Installation of percona-server-client-56"
	sudo apt-get install -y percona-server-client-5.6

	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of percona-client"
fi

if [[ $_install_mysql_server_ = 'yes' ]]; then

	echo "--> Set '$_mysql_root_password_' as root password for mysql"
	sudo sh -c "echo \"percona-server-server-5.6 percona-server-server/root_password password $_mysql_root_password_\" | debconf-set-selections"
	sudo sh -c "echo \"percona-server-server-5.6 percona-server-server/root_password_again password $_mysql_root_password_\" | debconf-set-selections"
	sudo apt-get install -y percona-server-server-5.6
	echo "--> Execution of mysql_secure_installation"
	echo -e "$_mysql_root_password_\nn\ny\n$DISALLOW_REMOTE_ACCESS_BY_ROOT\ny\ny" > tmp.txt
	sudo mysql_secure_installation < tmp.txt

	if [[ $_mysql_allow_remote_ = 'yes' ]]; then
		echo "--> Configure mysql to accept connection from any ip"
		sudo sh -c "echo '[mysqld]\nbind-address=0.0.0.0' > /etc/mysql/conf.d/local.cnf"

		mysql -u root -p$_mysql_root_password_ -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$_mysql_root_password_' WITH GRANT OPTION;"
		mysql -u root -p$_mysql_root_password_ -e "FLUSH PRIVILEGES;"
	fi

	if [[ -f  $_conf_folder_/mysql/local.cnf ]]; then
		echo "--> Copy existing mysql configuration from our project"
		sudo cp  $_conf_folder_/mysql/local.cnf /etc/mysql/conf.d/
	elif [[ -f /etc/mysql/conf.d/local.cnf ]]; then
		sudo mkdir -p  $_conf_folder_/mysql/
		sudo cp /etc/mysql/conf.d/local.cnf  $_conf_folder_/mysql/local.cnf.sample
	fi

	if [[ $_mysql_createdb_ = 'yes' ]]; then
		mysql -u root -p$_mysql_root_password_ -e "CREATE DATABASE IF NOT EXISTS $_mysql_dbname_"
		mysql -u root -p$_mysql_root_password_ -e "GRANT ALL PRIVILEGES ON $_mysql_dbname_.* TO '$_mysql_dbuser_'@'%' IDENTIFIED BY '$_mysql_dbpass_'"
		mysql -u root -p$_mysql_root_password_ -e "FLUSH PRIVILEGES"

		if [[ -f /vagrant/sql/localdb.sql ]]; then
			echo "--> Import existing database to our project"
			mysql -u root -p$_mysql_root_password_ ${_mysql_dbname_} < /vagrant/sql/localdb.sql
		fi

	fi

	sudo service mysql restart
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of percona-server"
fi

##########################################################################################
# Let's install and configure Apache
##########################################################################################
if [[ $_install_apache_ = 'yes' ]]; then
	echo "-> Make the directory 'default' for the default vhost and tools directory to handle some tools"
	sudo mkdir -p /var/www/default/tools
	
	echo "-> Install apache2"
	sudo apt-get install -y apache2 libapache2-mod-fastcgi 

	echo "-> Enable apache mod_actions"
	sudo a2enmod actions

	echo "-> Enable apache mod_rewrite"
	sudo a2enmod rewrite

	echo "-> Enable apache mod_deflate"
	sudo a2enmod deflate

	echo "-> Enable apache mod_headers"
	sudo a2enmod headers

	echo "-> Enable apache mod_ssl"
	sudo a2enmod ssl

	echo "-> Configure ServerName to avoid the classic warning message at restart"
	sudo sh -c 'echo "ServerName $(cat /etc/hostname)" > /etc/apache2/conf-available/servername.conf'
	sudo a2enconf servername
	echo "--> Remove default configuration about sites"
	sudo mkdir _bak
	sudo mv /etc/apache2/sites-available/* _bak/
	sudo mv _bak /etc/apache2/sites-available/
	sudo rm -Rf /etc/apache2/sites-enabled/*

	# ------------------------------------------------------------------------------------
	# -> vhosts 'default' configuration
	
	# First check if a project specific configuration file exist
	if [[ -f  $_conf_folder_/apache/default.vhost ]]; then
		sudo cp  $_conf_folder_/apache/default.vhost /etc/apache2/sites-available/default.conf
	else
		# Else, install a default configuration
		echo "--> Create the default configuration for apache (will respond to http://127.0.0.1:{port}/ or http://{hostname}:{port}/ "
		echo "--> Tools like phpmyadmin or info.php will be only accessible throw this vhost"
		file=$(cat <<EOF
<VirtualHost *:_apache_port_>
	DocumentRoot /var/www/default

	<Directory /var/www/default>
		Options -Indexes +FollowSymLinks +MultiViews
		AllowOverride All
		#if Apache 2.4
		<IfModule mod_authz_core.c>
			Require all granted
		</IfModule>
	</Directory>

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined

	IncludeOptional conf-enabled/*.conf.vhost-default
</VirtualHost>

EOF
)
		sudo echo "$file" > ./default
		sudo sed -i "s,_apache_port_,$_apache_port_," ./default
		sudo mv ./default /etc/apache2/sites-available/default.conf

		sudo mkdir -p  $_conf_folder_/apache
		sudo cp /etc/apache2/sites-available/default.conf  $_conf_folder_/apache/default.vhost.sample
	fi

	echo "--> Enable default vhost"
	sudo a2ensite default

	# ------------------------------------------------------------------------------------
	# -> vhosts 'locahost' configuration
	
	# First check if a project specific configuration file exist
	if [[ -f  $_conf_folder_/apache/localhost.vhost ]]; then
		echo "--> Copy existing apache configuration from our project"
		sudo cp  $_conf_folder_/apache/localhost.vhost ./localhost
	else
		# Else, install a default configuration
		echo "--> Create the apache configuration for our project"
		file=$(cat <<EOF
<VirtualHost *:_apache_port_>
	DocumentRoot /var/www/htdocs
	ServerAlias localhost $_apache_localhost_aliases_    
	<Directory /var/www/htdocs>
		Options -Indexes +FollowSymLinks +MultiViews
		AllowOverride all
		Order allow,deny
		allow from all
		#if Apache 2.4
		<IfModule mod_authz_core.c>
			Require all granted
		</IfModule>
	</Directory>

	# Force to use ssl by redirect all http trafic to https
	# RewriteEngine On
	# RewriteCond %{HTTPS} !=on
	# RewriteRule ^/?(.*) https://%{SERVER_NAME}/\$1 [R,L]

	ErrorLog \${APACHE_LOG_DIR}/localhost-error.log
	CustomLog \${APACHE_LOG_DIR}/localhost-access.log combined
</VirtualHost>
<IfModule mod_ssl.c>
	<VirtualHost _default_:_apache_ssl_port_>
		ServerAlias localhost $_apache_localhost_aliases_
		DocumentRoot /var/www/htdocs
		<Directory /var/www/htdocs>
				Options -Indexes +FollowSymLinks +MultiViews
				AllowOverride all
				Order allow,deny
				allow from all
				#if Apache 2.4
				<IfModule mod_authz_core.c>
					Require all granted
				</IfModule>
		</Directory>

		ErrorLog \${APACHE_LOG_DIR}/localhost-error.log
		CustomLog \${APACHE_LOG_DIR}/localhost-access.log combined

		#   SSL Engine Switch:
		SSLEngine on
		SSLCertificateFile    /etc/ssl/certs/localhost.crt
		SSLCertificateKeyFile /etc/ssl/private/localhost.key

		<FilesMatch "\.(cgi|shtml|phtml|php)$">
				SSLOptions +StdEnvVars
		</FilesMatch>
		<Directory /usr/lib/cgi-bin>
				SSLOptions +StdEnvVars
		</Directory>

		#   SSL Protocol Adjustments:
		BrowserMatch "MSIE [[2-6]]" \
				nokeepalive ssl-unclean-shutdown \
				downgrade-1.0 force-response-1.0
		# MSIE 7 and newer should be able to use keepalive
		BrowserMatch "MSIE [[17-9]]" ssl-unclean-shutdown
	</VirtualHost>
</IfModule>

EOF
)
		sudo echo "$file" > ./localhost
		sudo mkdir -p  $_conf_folder_/apache
		sudo cp ./localhost $_conf_folder_/apache/localhost.vhost.sample
	fi
	
	# Replace the tag for apache listened port by the correct value
	sudo sed -i "s,_apache_ssl_port_,$_apache_ssl_port_," ./localhost
	sudo sed -i "s,_apache_port_,$_apache_port_," ./localhost
	
	sudo sed -i "s,443,$_apache_ssl_port_," /etc/apache2/ports.conf
	sudo sed -i "s,80,$_apache_port_," /etc/apache2/ports.conf
	
	# Configure the forced usage of ssl if required
	if [[ $_apache_localhost_forcessl_ = "yes" ]]; then
		echo "--> Enable configuration to force usage of https for our project"
		sudo sed -i "s,# Rewrite,Rewrite," ./localhost
	fi
	
	sudo mv ./localhost /etc/apache2/sites-available/localhost.conf
	sudo a2ensite localhost
	
	# ------------------------------------------------------------------------------------
	# ->  Add an .htpasswd file to secure /tools alias if required 
	
	if [[ $_apache_tools_secure_ = "yes" ]]; then
		echo "--> Secure the /tools alias by an .htpasswd file"
		echo -e '<Directory /var/www/default/tools>
		AuthUserFile /var/www/default/tools/.htpasswd
		AuthName "Accès Restreint"
		AuthType Basic
		require valid-user
		</Directory>' > ./default-tools-secure.conf.vhost-default
		sudo mv ./default-tools-secure.conf.vhost-default /etc/apache2/conf-enabled/
		htpasswd -cb .htpasswd $_apache_tools_username_ $_apache_tools_pass_
		sudo mv .htpasswd /var/www/default/tools/
	fi

	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of apache"
fi

##########################################################################################
# Let's configure PHP
##########################################################################################
if [[ $_install_php_ = 'yes' ]]; then

	echo "-> Install PHP5 and some associated libs"
	sudo apt-get install -y php5-fpm php-pear php5-dev php5-imagick php5-gd php5-mcrypt php5-curl php5-mysql
	
	#
	# Configure opcode if arguments are specified
	# Magento 1.9 had 8273 PHP files and 1151 PHTML files out of the box, and default max_accelerated_files is 2000, so that's not enough
	#	
	cp  /etc/php5/mods-available/opcache.ini ./opcache.ini
	if [[ ! $_php_opcache_memory_ = '' ]]; then
		echo "-> Configure zend opcode $_php_opcache_memory_M of cache"
		echo "opcache.memory_consumption=$_php_opcache_memory_" >> ./opcache.ini
	fi
	if [[ ! $_php_opcache_max_accelerated_files_ = '' ]]; then
		echo "-> Configure zend opcode to $_php_opcache_max_accelerated_files_ files as max_accelerated_files"
		echo "opcache.max_accelerated_files=$_php_opcache_max_accelerated_files_" >> ./opcache.ini
	fi
	sudo mv ./opcache.ini /etc/php5/mods-available/opcache.ini
	
	#
	# Add an interface for opcode stats (OpCacheGui is only compatible for php5.5+
	#
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
	
	#
	# If apache was installed, we configure it for php
	#
	if [[ $_install_apache_ = 'yes' ]]; then
		file=$(cat <<EOF
<IfModule mod_fastcgi.c>
	AddType application/x-httpd-fastphp5 .php
	Action application/x-httpd-fastphp5 /php5-fcgi
	Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
	FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -socket /var/run/php5-fpm.sock -pass-header Authorization
	<Directory /usr/lib/cgi-bin>
  		Require all granted
	</Directory>
</IfModule>

EOF
		)
		sudo echo "$file" > php5-fpm
		sudo mv php5-fpm /etc/apache2/conf-available/php5-fpm.conf
		sudo a2enconf php5-fpm
		sudo service apache2 restart
	fi

	#
	# Create the phpinfo file under 'tools' path
	#
	echo "-> Create the phpinfo file under 'tools' path"
	sudo sh -c 'echo "<?php phpinfo(); ?>" >> /var/www/default/tools/info.php'
	
	echo "-> copy of the index of the server to grant access to tools"
	sudo cp $(dirname $(sudo find / -name 'bootstrap.sh'))/index.html /var/www/default/
	
	sudo service php5-fpm restart
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of php"
fi

##########################################################################################
# Install of xdebug for php
##########################################################################################
if [[ $_install_php_ = 'yes' ]] && [[ $_php_install_xdebug_ = 'yes' ]]; then
	
	echo "--> Install xdebug"
	sudo pecl install xdebug
	
	file=$(cat <<EOF
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.profiler_enable_trigger = 1

xdebug.profiler_output_dir=/tmp
xdebug.profiler_output_name=cachegrind.out.%p-%H-%R

EOF
	)
	sudo echo "$file" > xdebug.ini
	sudo mv xdebug.ini /etc/php5/mods-available/

	echo "--> Configure xdebug.ini to point on the xdebug.so at the full path"
	sudo sed -i "s,xdebug.so,$(sudo find / -name 'xdebug.so')," /etc/php5/mods-available/xdebug.ini

	echo "--> Enable xdebug"
	sudo php5enmod xdebug

	echo "--> Install webgrind into /tools/webgrind path (will show graph user triggered session only)"
	git clone https://github.com/jokkedk/webgrind.git
	sudo mv webgrind /var/www/default/tools/
	sudo apt-get install -y python graphviz
	sudo ln -s /usr/bin/dot /usr/local/bin/dot
	
	echo "-> Enable webgrind entry to index.html"
	sudo sed -i "s/<\!--__webgrind__/ /" /var/www/default/index.html
	sudo sed -i "s/__webgrind__-->//" /var/www/default/index.html
	
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of xdebug"
fi

##########################################################################################
# Install of memcache for php
##########################################################################################
if [[ $_install_php_ = 'yes' ]] && [[ $_php_install_memcache_ = 'yes' ]]; then
	
	echo "--> Install memcache"
	sudo pecl install memcache
	sudo sh -c "echo 'extension=memcache.so' > /etc/php5/mods-available/memcache.ini"

	echo "--> Configure memcache.ini to point on the memcache.so at the full path"
	sudo sed -i "s,memcache.so,$(sudo find / -name 'memcache.so')," /etc/php5/mods-available/memcache.ini

	echo "--> Enable memcache"
	sudo php5enmod memcache
	
	mkdir memcached
	cd memcached/
	wget http://phpmemcacheadmin.googlecode.com/files/phpMemcachedAdmin-1.2.2-r262.tar.gz
	tar xfvz phpMemcachedAdmin-1.2.2-r262.tar.gz 
	rm phpMemcachedAdmin-1.2.2-r262.tar.gz 
	cd ..
	sudo mv memcached /var/www/default/tools/

	if [[ -f $_conf_folder_/memcached/Memcache.php ]]; then
		sudo cp $_conf_folder_/memcached/Memcache.php /var/www/default/tools/memcached/Config/
	else
		sudo mkdir -p $_conf_folder_/memcached
		sudo cp /var/www/default/tools/memcached/Config/Memcache.php $_conf_folder_/memcached/Memcache.php.sample
	fi

	echo "-> Enable mailcatcher entry to index.html"
	sudo sed -i "s/<\!--__memcached__/ /" /var/www/default/index.html
	sudo sed -i "s/__memcached__-->//" /var/www/default/index.html

	sudo service php5-fpm restart
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of memcache for php"
fi

##########################################################################################
# Install of redis for php
##########################################################################################
if [[ $_install_php_ = 'yes' ]] && [[ $_php_install_redis_ = 'yes' ]]; then
	
	echo "--> Install redis"
	sudo pecl install redis
	sudo sh -c "echo 'extension=redis.so' > /etc/php5/mods-available/redis.ini"

	echo "--> Configure redis.ini to point on the redis.so at the full path"
	sudo sed -i "s,redis.so,$(sudo find / -name 'redis.so')," /etc/php5/mods-available/redis.ini

	echo "--> Enable redis"
	sudo php5enmod redis
	
	sudo service php5-fpm restart
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of redis for php"
fi

##########################################################################################
# Install of uploadprogress for php
##########################################################################################
if [[ $_install_php_ = 'yes' ]] && [[ $_php_install_uploadprogress_ = 'yes' ]]; then
	
	echo "--> Install uploadprogress"
	sudo pecl install uploadprogress
	sudo sh -c "echo 'extension=uploadprogress.so' > /etc/php5/mods-available/uploadprogress.ini"

	echo "--> Configure redis.ini to point on the redis.so at the full path"
	sudo sed -i "s,uploadprogress.so,$(sudo find / -name 'uploadprogress.so')," /etc/php5/mods-available/uploadprogress.ini

	echo "--> Enable redis"
	sudo php5enmod uploadprogress
	
	sudo service php5-fpm restart
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of uploadprogress for php"
fi

##########################################################################################
# Install of phars cli-tools
##########################################################################################
if [[ $_php_install_composer_ = 'yes' ]]; then
	echo "--> Install composer"
	sudo sh -c "curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin/"
fi

if [[ $_php_install_wpcli_ = 'yes' ]]; then
	echo "--> Install wp-cli"
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	sudo mv wp-cli.phar /usr/local/bin/wpcli
fi

if [[ $_php_install_n98magerun_ = 'yes' ]]; then
	echo "--> Install n98 magerun"
	curl -o n98-magerun.phar https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar
	chmod +x ./n98-magerun.phar
	sudo cp ./n98-magerun.phar /usr/local/bin/magerun
	sudo rm ./n98-magerun.phar
fi

if [[ $_php_install_drush_ = 'yes' ]]; then
	echo "--> Install of drush"
	sudo git clone https://github.com/drush-ops/drush.git /opt/drush -b ${_php_install_drush_version_}
	sudo chown root:staff /opt/drush -R
	sudo ln -s /opt/drush/drush /usr/local/bin/drush

	wget http://download.pear.php.net/package/Console_Table-1.1.3.tgz
	tar xfvz Console_Table-1.1.3.tgz
	sudo mv Console_Table-1.1.3 /opt/drush/lib/
	rm Console_Table-1.1.3.tgz
fi

##########################################################################################
# Install of mailcatcher to handle mail transit
##########################################################################################
if [[ $_install_mailcatcher_ = 'yes' ]]; then
	
	echo "--> Install of sqllite and ruby for mailcatcher"
	sudo apt-get install -y libsqlite3-dev ruby ruby-dev

	echo "--> Install of mailcatcher, this service handle mail transit"
	sudo gem install mailcatcher

	if [[ $_install_php_ = 'yes' ]]; then 
		sudo sh -c "echo '[mail function]\nsendmail_path=/usr/local/bin/catchmail' > /etc/php5/mods-available/mailcatcher.ini"
		sudo php5enmod mailcatcher
		sudo service php5-fpm restart
	fi
	
	echo "--> Launch mailcatcher at startup"
	sudo sed -i "s,\"exit 0\",\"exit X\"," /etc/rc.local
	sudo sed -i "s,exit 0,/usr/local/bin/mailcatcher --ip=0.0.0.0 -f > /dev/null 2\>\&1 \&\n\nexit 0," /etc/rc.local
	sudo sed -i "s,\"exit X\",\"exit 0\"," /etc/rc.local
	/etc/rc.local
	
	echo "-> Enable mailcatcher entry to index.html"
	sudo sed -i "s/<\!--__mailcatcher__/ /" /var/www/default/index.html
	sudo sed -i "s/__mailcatcher__-->//" /var/www/default/index.html
	sudo sed -i "s,__mailcatcher_url__,http://$(cat /etc/hostname):1080," /var/www/default/index.html
	
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of mailcatcher"
fi

##########################################################################################
# Installation of Google PageSpeed for Apache
##########################################################################################
if [[ $_install_pagespeed_ = 'yes' ]] && [[ $_install_apache_ = 'yes' ]]; then

	echo "--> Install of Google PageSpeed module for apache"
	wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
	sudo dpkg -i mod-pagespeed-*.deb
	sudo apt-get -f install

	file=$(cat <<EOF
<IfModule pagespeed_module>
	<Location /tools/pagespeed_admin>
		Order allow,deny
		Allow from All
		SetHandler pagespeed_admin
	</Location>
	<Location /tools/pagespeed_global_admin>
		Order allow,deny
		Allow from All
		SetHandler pagespeed_global_admin
	</Location>
</IfModule>

EOF
	)
	sudo echo "$file" > pagespeed.conf.vhost-default 
	sudo mv pagespeed.conf.vhost-default /etc/apache2/conf-enabled/
	
	echo "-> Enable pagespeed entry to index.html"
	sudo sed -i "s/<\!--__pagespeed__/ /" /var/www/default/index.html
	sudo sed -i "s/__pagespeed__-->//" /var/www/default/index.html
	
	sudo service apache2 restart
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of pagespeed for apache"
fi

##########################################################################################
# Install of PHPMyAdmin
##########################################################################################
if [[ $_install_phpmyadmin_ = 'yes' ]] && [[ $_install_php_ = 'yes' ]]; then
	echo "--> Start setup of phpmyadmin"
	echo "--> Setup debconf variables for silent install"

	#
	# Define if phpmyadmin has to configure apache or not
	#
	if [[ $_install_apache_ = 'yes' ]]; then
		sudo sh -c "echo \"phpmyadmin  phpmyadmin/reconfigure-webserver    multiselect apache2\" | debconf-set-selections"
	else
		sudo sh -c "echo \"phpmyadmin  phpmyadmin/reconfigure-webserver    multiselect none\" | debconf-set-selections"
	fi

	#
	# Required information for phpmyadmin to login on mysql server and configure his required elements
	#
	sudo sh -c "echo \"phpmyadmin	phpmyadmin/mysql/admin-user			string		$_phpmyadmin_server_user_\" 		| debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin	phpmyadmin/mysql/admin-pass			password	$_phpmyadmin_server_password_\" 	| debconf-set-selections"

	if [[ ! $_phpmyadmin_server_ip_ = '127.0.0.1' ]]; then
		sudo sh -c "echo \"phpmyadmin	phpmyadmin/mysql/method				select	tcp/ip\" 						| debconf-set-selections"
		sudo sh -c "echo \"phpmyadmin	phpmyadmin/remote/newhost			string	$_phpmyadmin_server_ip_\" 		| debconf-set-selections"
		sudo sh -c "echo \"phpmyadmin	phpmyadmin/remote/host				select	$_phpmyadmin_server_ip_\" 		| debconf-set-selections"
	fi
	PMA_PASS=$(pwgen -1 -n 20)
	sudo sh -c "echo \"phpmyadmin	phpmyadmin/remote/port				string		$_phpmyadmin_server_port_\" 		| debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin	phpmyadmin/db/app-user 				string 		pma-user\" | debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin	phpmyadmin/mysql/app-pass			password 	$PMA_PASS\" | debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin 	phpmyadmin/app-password-confirm 	password	$PMA_PASS\" | debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin  	phpmyadmin/password-confirm			password 	$PMA_PASS\" | debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin  	phpmyadmin/setup-password   		password 	$PMA_PASS\" | debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin	phpmyadmin/db/dbname				string		phpmyadmin\" | debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin	phpmyadmin/dbconfig-install			boolean		true\" 		| debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin	phpmyadmin/dbconfig-reinstall		boolean		false\" 	| debconf-set-selections"
	sudo sh -c "echo \"phpmyadmin	phpmyadmin/dbconfig-upgrade			boolean		true\" 		| debconf-set-selections"


	echo "--> Install phpmyadmin dependencies"
	sudo apt-get install -y dbconfig-common debconf perl ttf-dejavu-core ucf
	
	echo "--> Download phpmyadmin.deb to install it with ignoring apache2 dependency"
	sudo apt-get download phpmyadmin
	sudo dpkg --ignore-depends=libapache2-mod-php5,libapache2-mod-php5filter --install phpmyadmin*
	sudo apt-get -f -y install

	# Configure apache to access phpmyadmin by tools path
	if [[ $_install_apache_ = 'yes' ]]; then
		echo "-> Update phpmyadmin alias to be accesible by /tools/phpmyadmin only from the default vhost"
		sudo sed -i 's,Alias /phpmyadmin /usr/share/phpmyadmin,# Alias /phpmyadmin /usr/share/phpmyadmin,' /etc/apache2/conf-available/phpmyadmin.conf
		sudo sh -c "echo \"Alias /tools/phpmyadmin /usr/share/phpmyadmin\" > /etc/apache2/conf-enabled/phpmyadmin.conf.vhost-default"
		sudo service apache2 restart
	fi

	if [[ $_phpmyadmin_auth_type_ = "config" ]]; then
		sudo sed -i "s,'cookie';,'config';\n    \$cfg['Servers'][\$i]['user'] = '${_phpmyadmin_server_user_}';\n    \$cfg['Servers'][\$i]['password'] = '${_phpmyadmin_server_password_}';\n    \$cfg['AllowThirdPartyFraming'] = true;\n," /etc/phpmyadmin/config.inc.php
	fi
	
	echo "-> Enable phpmyadmin entry to index.html"
	sudo sed -i "s/<\!--__phpmyadmin__/ /" /var/www/default/index.html
	sudo sed -i "s/__phpmyadmin__-->//" /var/www/default/index.html
	
	sudo apt-get install -y php5-mysqlnd
	
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of phpmyadmin"	
fi

##########################################################################################
# Install of Apache Solr using tomcat
##########################################################################################
if [[ $_install_solr_ = 'yes' ]]; then

	sudo apt-get install -y openjdk-7-jre tomcat7 tomcat7-admin
	SOLR_VERSION=$_solr_version_
	if [ ! -f solr-${SOLR_VERSION}.tgz ]; then
		wget http://apache.websitebeheerjd.nl/lucene/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
	fi
	tar xzvf solr-${SOLR_VERSION}.tgz
	sudo mv solr-${SOLR_VERSION} /usr/share/solr
	sudo cp -Rf /usr/share/solr/example /usr/share/solr/solr-${_solr_instance_}
	sudo cp -r /usr/share/solr/example/lib/ext/* /usr/share/tomcat7/lib/
	sudo cp -r /usr/share/solr/example/resources/log4j.properties /usr/share/tomcat7/lib/

	sudo sed -i "s,solr.log=logs/,solr.log=/usr/share/solr," /usr/share/tomcat7/lib/log4j.properties

	file=$(cat <<EOF
<Context docBase="/usr/share/solr/solr-$_solr_instance_/webapps/solr.war" debug="0" crossContext="true">
  <Environment name="solr/home" type="java.lang.String" value="/usr/share/solr/solr-$_solr_instance_/multicore" override="true" />
</Context>

EOF
	)
	sudo echo "$file" > solr-${_solr_instance_}.xml
	sudo mv solr-${_solr_instance_}.xml /etc/tomcat7/Catalina/localhost/

	file=$(cat <<EOF
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
  <role rolename="manager-gui"/>
  <user username="$_tomcat_admin_login_" password="$_tomcat_admin_password_" roles="manager-gui"/>
</tomcat-users>

EOF
	)
	sudo echo "$file" > tomcat-users.xml
	sudo mv /etc/tomcat7/tomcat-users.xml /etc/tomcat7/tomcat-users.xml.bak
	sudo mv tomcat-users.xml /etc/tomcat7/

	sudo chown -R tomcat7 /usr/share/solr/solr-${_solr_instance_}/multicore
	
	if [[ ! $_tomcat_port_ = '' ]]; then
		sudo sed -i "s,8080,$_tomcat_port_," /etc/tomcat7/server.xml
	fi
	
	sudo service tomcat7 restart
	
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of apache solr on tomcat"

fi

##########################################################################################
# Install of Redis instance for sessions or cache
##########################################################################################
if [[ $_install_redis_ = 'yes' ]] ; then
	echo "--> Installation of redis-server"
	sudo apt-get install -y redis-server

	#
	# This part of the script handle multiple instances installation, you can execute the script multiple times with
	# different arguments to get multiple instances of redis
	#
	echo "--> Copy redis default instance to dedicated instance for session /etc/init.d/redis-server-${_redis_port_}-${_redis_usage_}"
	sudo cp /etc/init.d/redis-server /etc/init.d/redis-server-${_redis_port_}-${_redis_usage_}
	sudo sed -i "s,Provides:\t\tredis-server,Provides:\t\tredis-server-${_redis_port_}-${_redis_usage_}," /etc/init.d/redis-server-${_redis_port_}-${_redis_usage_}
	sudo sed -i "s,DAEMON_ARGS=/etc/redis/redis.conf,DAEMON_ARGS=/etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf," /etc/init.d/redis-server-${_redis_port_}-${_redis_usage_}
	sudo sed -i "s,redis-server.pid,redis-server-${_redis_port_}-${_redis_usage_}.pid," /etc/init.d/redis-server-${_redis_port_}-${_redis_usage_}
	
	echo "--> Add redis-server-session to startup"
	sudo update-rc.d redis-server-${_redis_port_}-${_redis_usage_} defaults

	echo "--> Fine tuning of redis-${_redis_port_}-${_redis_usage_} instance"
	sudo cp /etc/redis/redis.conf /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
	
	sudo sed -i "s,port 6379,port ${_redis_port_}," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
	sudo sed -i "s,redis-server.pid,redis-server-${_redis_port_}-${_redis_usage_}.pid," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
	sudo sed -i "s,# unixsocket /tmp/redis.sock,unixsocket /tmp/redis-${_redis_port_}-${_redis_usage_}.sock," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
	sudo sed -i "s,# unixsocketperm 777,unixsocketperm 777," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
	sudo sed -i "s,timeout 0,timeout 4," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
	sudo sed -i "s,tcp-keepalive 0,tcp-keepalive 10," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
	sudo sed -i "s,redis-server.log,redis-server-${_redis_port_}-${_redis_usage_}.log," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
	sudo sed -i "s,# maxclients 10000,maxclients 10000," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf

	if [[ $_redis_usage_ = 'session' ]] ; then
		# We save data in a specific file
		sudo sed -i "s,dump.rdb,dump-${_redis_port_}-${_redis_usage_}.rdb," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
	elif [[ $_redis_usage_ = 'cache' ]] ; then
		# We disable saving data on disk functionnality for better performances
		sudo sed -i "s,save 900 1,# save 900 1," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
		sudo sed -i "s,save 300 10,# save 300 10," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
		sudo sed -i "s,save 60 10000,# save 60 10000," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
		sudo sed -i "s,rdbcompression yes,rdbcompression no," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf	
		sudo sed -i "s,dbfilename dump.rdb,# dbfilename dump.rdb," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
		
		if [[ ! $_redis_max_memory_ = '' ]]; then
			sudo sed -i "s,# maxmemory <bytes>,maxmemory ${_redis_max_memory_}Mb," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
			sudo sed -i "s,# maxmemory-policy volatile-lru,maxmemory-policy volatile-lru," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf
			sudo sed -i "s,# maxmemory-samples 3,maxmemory-samples 3," /etc/redis/redis-${_redis_port_}-${_redis_usage_}.conf	
		fi 
	fi
	echo "--> Disable default instance of redis at startup"
	sudo update-rc.d redis-server disable
	sudo service redis-server stop 
	
	sudo service redis-server-${_redis_port_}-${_redis_usage_} start
	
	#
	# We define few thing recommanded by redis to avoid latencies
	#
	echo "--> Set recommanded system vars to avoid latencies"
	sudo sh -c "echo 1 > /proc/sys/vm/overcommit_memory"
	sudo sh -c "echo never > /sys/kernel/mm/transparent_hugepage/enabled"
	sudo sed -i "s,\"exit 0\",\"exit X\"," /etc/rc.local
	sudo sed -i "s,exit 0,echo never > /sys/kernel/mm/transparent_hugepage/enabled\n\nexit 0," /etc/rc.local
	sudo sed -i "s,\"exit X\",\"exit 0\"," /etc/rc.local
	sudo sh -c "echo 512 > /proc/sys/net/core/somaxconn"
	
	sudo /etc/rc.local
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of redis-${_redis_port_}-${_redis_usage_}"
fi

##########################################################################################
# Install of redis commander 
##########################################################################################
if [[ $_install_redis_commander_ = 'yes' ]] ; then
	sudo apt-get install curl
	curl -sL https://deb.nodesource.com/setup | sudo bash -
	sudo apt-get install -y nodejs
	sudo npm install -g redis-commander

	sudo sed -i "s,\"exit 0\",\"exit X\"," /etc/rc.local

	if [[ $_install_redis_ = 'yes' ]] ; then
		sudo sed -i "s,exit 0,redis-commander --redis-host=127.0.0.1 --redis-port=${_redis_port_} >/dev/null 2>\&1 \&\n\nexit 0," /etc/rc.local
	else
		sudo sed -i "s,exit 0,redis-commander >/dev/null 2>\&1 \&\n\nexit 0," /etc/rc.local
	fi

	
	sudo sed -i "s,\"exit X\",\"exit 0\"," /etc/rc.local
	sudo /etc/rc.local

	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of redis-commander"
fi


##########################################################################################
# Install of memcached server instance
##########################################################################################
if [[ $_install_memcached_ = 'yes' ]] ; then
	echo "--> Installation of memcached server"
	sudo apt-get install -y memcached libmemcached-tools

	echo "--> Stop launched default instance of memcached"
	sudo service memcached stop

	echo "--> Get script to transform memcached as a multiple instances mode"
	git clone https://gist.github.com/5957231.git
	sudo cp 5957231/etc\:init.d\:memcache /etc/init.d/memcached
	sudo cp 5957231/usr\:share\:memcached\:scripts\:start-memcached /usr/share/memcached/scripts/start-memcached 
	sudo cp 5957231/etc\:memcache_instance.conf /etc/memcached_${_memcached_port_}.conf

	echo "--> Configure the instance ${_memcached_port_}"
	sudo sed -i "s,-m 64,-m ${_memcached_max_memory_}," /etc/memcached_${_memcached_port_}.conf
	sudo sed -i "s,# -p 11211,-p $_memcached_port_," /etc/memcached_${_memcached_port_}.conf
	sudo sed -i "s,-s /var/run/memcached/memcached.sock,# -s /var/run/memcached/memcached.sock," /etc/memcached_${_memcached_port_}.conf
	sudo sed -i "s,-a, # -a," /etc/memcached_${_memcached_port_}.conf
	sudo sed -i "s,-f,# -f," /etc/memcached_${_memcached_port_}.conf
	sudo sed -i "s,-n,# -n," /etc/memcached_${_memcached_port_}.conf
	
	sudo service memcached start
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of memcached-${_memcached_port_}"
fi

##########################################################################################
# Install of ffmpeg-full
##########################################################################################
if [[ $_install_ffmpeg_ = 'yes' ]] ; then

	echo "-> Install of ffmpeg-full"
	sudo sh -c "echo \"deb http://www.deb-multimedia.org wheezy main non-free\" > /etc/apt/sources.list.d/ffmpeg.list"
	sudo sh -c "echo \"deb-src http://www.deb-multimedia.org wheezy main non-free\" >> /etc/apt/sources.list.d/ffmpeg.list"

	sudo apt-get update
	sudo apt-get install -y --force-yes deb-multimedia-keyring
	sudo apt-get install -y --force-yes libfaad-dev faad faac libfaac0 libfaac-dev libmp3lame-dev x264 libx264-dev libxvidcore-dev build-essential checkinstall yasm libgsm1-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libdc1394-22-dev libx11-dev libxext-dev libxfixes-dev pkg-config

	sudo git clone http://git.videolan.org/git/x264.git -b stable
	cd x264/
	sudo ./configure --enable-static --enable-shared
	sudo make && sudo make install
	sudo ldconfig
	cd .. 
	git clone https://github.com/FFmpeg/FFmpeg -b n2.5.2 ffmpeg
	cd ffmpeg
	sudo ./configure --enable-gpl --enable-nonfree --enable-libfaac --enable-libgsm --enable-libmp3lame --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-zlib --enable-postproc --enable-swscale --enable-pthreads --enable-x11grab --enable-libdc1394 --enable-version3 --enable-libopencore-amrnb --enable-libopencore-amrwb 
	sudo make clean
	sudo checkinstall -D --install=no --pkgname=ffmpeg-full --autodoinst=yes -y
	sudo make
	sudo make install
	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of ffmpeg"
fi

##########################################################################################
# Install of varnish
##########################################################################################
if [[ $_install_varnish_ = 'yes' ]] ; then

	echo "-> Install of varnish"
	sudo apt-get install -y apt-transport-https
	sudo sh -c "curl https://repo.varnish-cache.org/debian/GPG-key.txt | apt-key add -"
	sudo sh -c 'echo "deb https://repo.varnish-cache.org/debian/ wheezy varnish-3.0" > /etc/apt/sources.list.d/varnish-cache.list'
	sudo apt-get update
	sudo apt-get install -y varnish

	echo "-> Default configuration of varnish"
	sudo sed -i "s,a :6081,a :$_varnish_listen_port_," /etc/default/varnish
	sudo sed -i "s,-T localhost:6082,-T $_varnish_admin_listen_:$_varnish_admin_port_," /etc/default/varnish
	sudo sed -i "s,256m,$_varnish_storage_size_," /etc/default/varnish
	sudo sed -i "s,127.0.0.1,$_varnish_backend_ip_," /etc/varnish/default.vcl
	sudo sed -i "s,8080,$_varnish_backend_port_," /etc/varnish/default.vcl


	echo "-> Copy configuration from project if exist"
	if [[ -f  $_conf_folder_/varnish/varnish.default ]]; then
		echo "--> Copy existing varnish configuration from our project"
		sudo cp  $_conf_folder_/varnish/varnish.default /etc/default/varnish
	else 
		sudo mkdir -p  $_conf_folder_/varnish
		sudo cp /etc/default/varnish  $_conf_folder_/varnish/varnish.default.sample
	fi

	if [[ -f  $_conf_folder_/varnish/secret ]]; then
		echo "--> Copy existing varnish configuration from our project"
		sudo cp  $_conf_folder_/varnish/secret /etc/varnish/secret
	else 
		sudo mkdir -p  $_conf_folder_/varnish
		sudo cp /etc/varnish/secret  $_conf_folder_/varnish/secret
	fi

	if [[ -f  $_conf_folder_/varnish/default.vcl ]]; then
		echo "--> Copy existing varnish configuration from our project"
		sudo cp  $_conf_folder_/varnish/default.vcl /etc/varnish/
	else 
		sudo mkdir -p  $_conf_folder_/varnish
		sudo cp /etc/varnish/default.vcl  $_conf_folder_/varnish/default.vcl.sample
	fi

	sudo service varnish restart

	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of varnish"
fi

##########################################################################################
# Install of pound to handle ssl with varnish
##########################################################################################
if [[ $_install_pound_ = 'yes' ]] ; then
	echo "-> Install of pound to handle ssl reverse"
	sudo apt-get install -y pound

	sudo sed -i "s,startup=0,startup=1," /etc/default/pound 
	file=$(cat <<EOF
User            "www-data"
Group           "www-data"

## Logging: (goes to syslog by default)
##      0       no logging
##      1       normal
##      2       extended
##      3       Apache-style (common log format)
LogLevel        1

## check backend every X secs:
Alive           30

# poundctl control socket
Control "/var/run/pound/poundctl.socket"

### ListenHTTP ###

ListenHTTPS
	HeadRemove "X-Forwarded-Proto"
    AddHeader "X-Forwarded-Proto: https"
    Address 0.0.0.0
    Port    $_pound_https_port_
    Cert "/etc/ssl/certs/localhost.pem"
    Service
    	BackEnd
        	Address $_pound_backend_ip_
            Port    $_pound_backend_port_
        End
  	End
End

EOF
	)

	sudo echo "$file" > pound.cfg

	if [[ $_pound_force_ssl_ = 'yes' ]]; then
		_pound_http_="ListenHTTP\n\tAddress  0.0.0.0\n\tPort $_pound_http_port_\n\tService\n\t\tHeadRequire \"Host: $_pound_force_ssl_domain_\"\n\t\tRedirect 301 \"https://$_pound_force_ssl_domain_\"\n\tEnd\nEnd"
		sudo sed -i "s,### ListenHTTP ###,$_pound_http_," pound.cfg
	fi
	
	sudo cp pound.cfg /etc/pound/

	sudo service pound stop
	sudo service pound start

	echo "-> ------------------------------------------------------------------"
	echo "-> End of install of pound"

fi

if [[ ! $_redis_commander_url_ = '' ]]; then
    echo "-> Enable redis_commander entry to index.html"
    sudo sed -i "s/<\!--__redis_commander__/ /" /var/www/default/index.html
    sudo sed -i "s/__redis_commander__-->//" /var/www/default/index.html
    sudo sed -i "s,__redis_commander_url__,$_redis_commander_url_," /var/www/default/index.html
fi

if [[ ! $_solr_instance_url_ = '' ]] ; then
    echo "-> Enable solr entry to index.html"
    sudo sed -i "s/<\!--__solr_instance__/ /" /var/www/default/index.html
    sudo sed -i "s/__solr_instance__-->//" /var/www/default/index.html
    sudo sed -i "s,__solr_instance_url__,$_solr_instance_url_," /var/www/default/index.html
fi

exit 0
