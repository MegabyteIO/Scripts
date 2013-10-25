#!/bin/sh

source ~/.bash_profile
CLI_BACKEND_PATH='cms'
CLI_DATABASE_HOST='localhost'
read -p 'Enter WordPress homepage URL: ' CLI_WEBSITE
rm -rf /home/nginx/domains/$CLI_WEBSITE/public/*
mkdir -v /home/nginx/domains/$CLI_WEBSITE/public/$CLI_BACKEND_PATH
CLI_DATABASE_NAME=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
CLI_DATABASE_USER=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
CLI_PREFIX_RANDOM=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c4 | tr -d '-')_
CLI_DATABASE_PASSWORD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c64 | tr -d '-')
echo "Creating database with random variables used for database name, username, and password. Your root MySQL password is required."
mysql -uroot -p --verbose -e "CREATE DATABASE $CLI_DATABASE_NAME; GRANT ALL PRIVILEGES ON $CLI_DATABASE_NAME.* TO '$CLI_DATABASE_USER'@'$CLI_DATABASE_HOST' IDENTIFIED BY '$CLI_DATABASE_PASSWORD'; FLUSH PRIVILEGES"
read -p 'Enter WordPress administrator user ID: ' CLI_ADMIN_USER_NAME
read -s -p 'Enter WordPress administrator user password: ' CLI_ADMIN_PASSWORD
read -rp $'\nEnter WordPress administrator e-mail address:' CLI_SITE_ADMIN_EMAIL
cd /home/nginx/domains/$CLI_WEBSITE/public/$CLI_BACKEND_PATH
wp core download
wp core config --dbname="$CLI_DATABASE_NAME" --dbuser="$CLI_DATABASE_USER" --dbpass="$CLI_DATABASE_PASSWORD" --dbprefix="$CLI_PREFIX_RANDOM"
head --lines=-5 /home/nginx/domains/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/wp-config.php > /home/nginx/domains/$CLI_WEBSITE/public/wp-config.php
#echo "require_once( 'wp-config-options.php' )" >> /home/nginx/domains/$CLI_WEBSITE/public/wp-config.php
echo "if ( !defined('ABSPATH') )" >> /home/nginx/domains/$CLI_WEBSITE/public/wp-config.php
echo "    define('ABSPATH', dirname(__FILE__) . '/$CLI_BACKEND_PATH/');" >> /home/nginx/domains/$CLI_WEBSITE/public/wp-config.php
echo "require_once( ABSPATH . 'wp-settings.php');" >> /home/nginx/domains/$CLI_WEBSITE/public/wp-config.php
# rm -f /home/nginx/domains/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/wp-config.php
# cp /home/nginx/domains/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/index.php /home/nginx/domains/$CLI_WEBSITE/public/index.php
sed '$d' < /home/nginx/domains/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/index.php > /home/nginx/domains/$CLI_WEBSITE/public/index.php
echo "require('./$CLI_BACKEND_PATH/wp-blog-header.php');" >> /home/nginx/domains/$CLI_WEBSITE/public/index.php
read -p 'Enter title of website: ' CLI_WP_SITE_NAME
wp core install --url="$CLI_WEBSITE" --title="$CLI_WP_SITE_NAME" --admin_name="$CLI_ADMIN_USER_NAME" --admin_email="$CLI_SITE_ADMIN_EMAIL" --admin_password="$CLI_ADMIN_PASSWORD"
chown nginx:nginx /home/nginx/domains/$CLI_WEBSITE/public/$CLI_BACKEND_PATH
chown -R nginx:nginx /home/nginx/domains/$CLI_WEBSITE/public/$CLI_BACKEND_PATH
cd /home/nginx/domains/$CLI_WEBSITE/public/$CLI_BACKEND_PATH
# add batcache
# add apc backend cache
wp plugin install wordpress-seo --activate
wp plugin install advanced-custom-fields --activate
wp plugin install mp6 --activate
wp plugin install wp-front-end-editor --activate
wp option update avatar_default 'mystery'
wp option update avatar_rating 'G'
wp option update category_base '/%category%/'
wp option update comments_notify 0
wp option update comments_max_links 1
wp option update comments_per_page 10
wp option update date_format 'j. F Y, H:i'
wp option update default_ping_status 'open'
wp option update default_post_edit_rows 30
wp option update gmt_offset -4
wp option update tag_base '/tag/'
wp option update permalink_structure '/%postname%/'
wp option update rss_language 'en'
wp option update use_smilies 0
#rm -f /usr/local/nginx/conf/conf.d/$CLI_WEBSITE.conf