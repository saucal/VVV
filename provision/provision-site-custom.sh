#!/bin/bash

__vv__check_args() {
	while [ ! -z "$1" ]; do
		case "$1" in
			-p|--path)
				path=$2
				shift 2
				;;
			-d|--domain)
				domain=$2
				shift 2
				;;
			-t|--title)
				wp_title=$2
				shift 2
				;;
			-l|--locale)
				wp_db_lang=$2
				shift 2
				;;
			-db|--db_name)
				db_name=$2
				shift 2
				;;
			--test_content)
				test_content=$2
				shift 2
				;;
			--multisite)
				multisite=y
				ms_type=$2
				shift 2
				;;
			--admin_user)
				admin_user=$2
				shift 2
				;;
			--admin_pass)
				admin_password=$2
				shift 2
				;;
			--admin_mail)
				admin_email=$2
				shift 2
				;;
		esac
	done
	site="${path##*/}"
	if [ -z "$wp_db_lang" ]; then
		wp_db_lang="en_US"
	fi
	if [ -z "$db_name" ]; then
		db_name="$site"
	fi
	if [ -z "$wp_title" ]; then
		wp_title="$site"
	fi
	if [ -z "$test_content" ]; then
		test_content="n"
	fi
	if [ -z "$multisite" ]; then
		multisite="n"
		ms_type="subdirectory"
	fi
	if [ -z "$admin_user" ]; then
		admin_user="admin"
	fi
	if [ -z "$admin_password" ]; then
		admin_password="test1234"
	fi
	if [ -z "$admin_email" ]; then
		admin_email="test@saucal.com"
	fi
	wp_db_prefix="wp_"
}

__vv__main() {
	__vv__check_args "$@"

	cd $path

	if [ -f "wp-config.php" ]; then
		echo -e "\e[36mWon't install WP because wp-config already exist\e[39m"
		exit 0
	fi

	echo -e "\e[36mDownloading WP\e[39m"
	wp core download --locale="$wp_db_lang" --allow-root

	echo -e "\e[36mCreating DB\e[39m"
	mysql -u root -proot --skip-column-names -e "CREATE DATABASE IF NOT EXISTS \`$db_name\`;\n GRANT ALL PRIVILEGES ON \`$db_name\`.* TO 'wp'@'localhost' IDENTIFIED BY 'wp';" 

	echo -e "\e[36mCreating wp-config\e[39m"
	wp core config --dbname="$db_name" --dbuser=wp --dbpass=wp --dbhost="localhost" --dbprefix="$wp_db_prefix" --locale="$wp_db_lang" --allow-root

	install_text='install'
	if [[ "$multisite" = "n" ]]; then
		echo -e "\e[36mInstalling WP\e[39m"
	else
		echo -e "\e[36mInstalling WP as multisite\e[39m"
		install_text='multisite-install'
	fi
	wp core $install_text --url="$domain" --title="$wp_title" --admin_user="$admin_user" --admin_password="$admin_password" --admin_email="$admin_email" --allow-root

	if [[ "$test_content" = "y" ]]; then
		echo -e "\e[36mInstalling Test Content\e[39m"
		#curl -s https://raw.githubusercontent.com/manovotny/wptest/master/wptest.xml > import.xml 
		curl -s https://raw.githubusercontent.com/jasondewitt/wptest/fiximages/wptest.xml > import.xml 
		wp plugin install wordpress-importer --allow-root 
		wp plugin activate wordpress-importer --allow-root 
		wp import import.xml --authors=skip --allow-root 
		rm import.xml
	fi
	
	echo -e "\e[36mCreating vvv-hosts file\e[39m"
	echo "$domain" > "$path/vvv-hosts"

	echo -e "\e[36mCreating nginx config file\e[39m"
	nginx_domain_text="$domain"
	if [[ $multisite = 'y' ]] && [[ $ms_type = 'subdomain' ]]; then
		nginx_domain_text="$domain *.$domain"
	fi
	xip_domain=" ~^${site// /-}\\\.\\\d+\\\.\\\d+\\\.\\\d+\\\.\\\d+\\\.xip\\\.io$"
	nginx_domain_text="$nginx_domain_text""$xip_domain"

	sed -e "s/testserver\.com/$nginx_domain_text/" \
		-e "s|/srv/www/wordpress-local|$path|" /srv/config/nginx-config/sites/local-nginx-example.conf-sample > /srv/config/nginx-config/sites/"$site".conf

	echo -e "\e[36mDisabling provisioner\e[39m"
	mv vvv-provision.yml vvv-provision.yml.old
}

__vv__main "$@"

exit 0