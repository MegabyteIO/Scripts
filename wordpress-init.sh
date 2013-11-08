#!/bin/sh

# Load WP-CLI settings from bash_profile TRY TO REMOVE WP CLI?
source ~/.bash_profile

# Test possibility of using define( 'DB_HOST', $_ENV{DATABASE_SERVER} );
CLI_DATABASE_HOST='localhost'
# Default for CentminMod - change if using custom directory schema
WEBSITE_INSTALL_DIRECTORY='home/nginx/domains'

# Get website URL and backend path
read -p 'Enter WordPress homepage URL: ' CLI_WEBSITE
read -p 'Enter a backend path for improved security (e.g. http://yourwebsite.com/backend-path/wp-admin) (required): ' CLI_BACKEND_PATH

# Remove default error pages and create backend path directory
rm -rf /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/*
mkdir -v /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH

# Generate random MySQL credentials and create the database
CLI_DATABASE_NAME=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
CLI_DATABASE_USER=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
CLI_PREFIX_RANDOM=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c4 | tr -d '-')
CLI_DATABASE_PASSWORD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c64 | tr -d '-')
echo "Creating database with random variables used for database name, username, and password. Your root MySQL password is required:"
mysql -uroot -p --verbose -e "CREATE DATABASE $CLI_DATABASE_NAME; GRANT ALL PRIVILEGES ON $CLI_DATABASE_NAME.* TO '$CLI_DATABASE_USER'@'$CLI_DATABASE_HOST' IDENTIFIED BY '$CLI_DATABASE_PASSWORD'; FLUSH PRIVILEGES"

# Set up wp-config.php
cp /usr/local/src/PoorIO/files/wp-config-options.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_NAME_HANDLE/$CLI_DATABASE_NAME/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_USER_HANDLE/$CLI_DATABASE_USER/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_PASSWORD_HANDLE/$CLI_DATABASE_PASSWORD/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/TABLE_PREFIX_HANDLE/$CLI_PREFIX_RANDOM/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s wp-config.php
perl -pi -e 's/BACKEND_PATH_HANDLE/ZONEINFO=America/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php

# Create customized structure
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public
mkdir content
mkdir addons
mkdir includes

# Set nginx as owner
chown -Rf nginx:nginx /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public

# add batcache
# add apc backend cache

# Move this stuff to must use plugin
#wp plugin install wordpress-seo --activate
#wp plugin install advanced-custom-fields --activate
#wp plugin install mp6 --activate
#wp plugin install wp-front-end-editor --activate
#wp option update avatar_default 'mystery'
#wp option update avatar_rating 'G'
#wp option update category_base '/%category%/'
#wp option update comments_notify 0
#wp option update comments_max_links 1
#wp option update comments_per_page 10
#wp option update date_format 'j. F Y, H:i'
#wp option update default_ping_status 'open'
#wp option update default_post_edit_rows 30
#wp option update gmt_offset -4
#wp option update tag_base '/tag/'
#wp option update permalink_structure '/%postname%/'
#wp option update rss_language 'en'
#wp option update use_smilies 0
#rm -f /usr/local/nginx/conf/conf.d/$CLI_WEBSITE.conf
