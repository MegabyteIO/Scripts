#!/bin/sh

# Get MySQL host from envoirnment variables
CLI_DATABASE_HOST=$DATABASE_SERVER
# Default for CentminMod - change if using custom directory schema
WEBSITE_INSTALL_DIRECTORY='home/nginx/domains'
# Default location for PoorIO - edit at own risk
POOR_IO_HOME='usr/local/src'

# Get website URL and backend path
read -p 'Enter WordPress homepage URL (IMPORTANT: Enter the URL in the following format - yourwebsite.com): ' CLI_WEBSITE
read -p 'Enter a backend path for improved security (e.g. http://yourwebsite.com/BACKEND-PATH/wp-admin): ' CLI_BACKEND_PATH

# Remove default error pages and create backend path directory
rm -rf /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/*
mkdir -v /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH

# Generate random MySQL credentials and create the database
CLI_DATABASE_NAME=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
CLI_DATABASE_USER=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c8 | tr -d '-')
CLI_PREFIX_RANDOM=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c4 | tr -d '-')
CLI_DATABASE_PASSWORD=$(< /dev/urandom tr -dc A-Z-a-z-0-9 | head -c64 | tr -d '-')
echo "Creating database with random variables used for database name, username, and password. Your root MySQL password is required. Please enter your MySQL root password:"
mysql -uroot -p --verbose -e "CREATE DATABASE $CLI_DATABASE_NAME; GRANT ALL PRIVILEGES ON $CLI_DATABASE_NAME.* TO '$CLI_DATABASE_USER'@'$CLI_DATABASE_HOST' IDENTIFIED BY '$CLI_DATABASE_PASSWORD'; FLUSH PRIVILEGES"

# Set up wp-config.php
cp /$POOR_IO_HOME/PoorIO/files/wp-config-options.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_NAME_HANDLE/$CLI_DATABASE_NAME/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_USER_HANDLE/$CLI_DATABASE_USER/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/DB_PASSWORD_HANDLE/$CLI_DATABASE_PASSWORD/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
perl -pi -e 's/TABLE_PREFIX_HANDLE/$CLI_PREFIX_RANDOM/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s wp-config.php
perl -pi -e 's/BACKEND_PATH_HANDLE/$CLI_BACKEND_PATH/g' /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/wp-config.php

# Download WordPress core files
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
cp -Rf /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/wordpress/* /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/$CLI_BACKEND_PATH/
rm -Rf wordpress
rm -f latest.tar.gz

# Create customized structure
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public
mkdir content
mkdir addons
mkdir includes

# Download drop-in caching plugins from Git
cd /$POOR_IO_HOME/PoorIO
rm -Rf gitclones
mkdir gitclones
cd gitclones
git clone https://github.com/Automattic/batcache.git
git clone https://github.com/eremedia/APC.git

# Add plugins
cd /$POOR_IO_HOME/PoorIO
rm -Rf zipclones
mkdir zipclones
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/addons
git clone https://github.com/Yoast/wordpress-seo.git wordpress-seo
wget http://downloads.wordpress.org/plugin/mp6.zip
unzip mp6.zip
rm -f mp6.zip
wget http://downloads.wordpress.org/plugin/google-authenticator.0.44.zip
unzip google-authenticator.0.44.zip
rm -f google-authenticator.0.44.zip
wget http://downloads.wordpress.org/plugin/pods.2.3.18.zip
unzip pods.2.3.18.zip
rm -f pods.2.3.18.zip
wget http://downloads.wordpress.org/plugin/my-shortcodes.2.06.zip
unzip my-shortcodes.2.06.zip
rm -f my-shortcodes.2.06.zip
wget http://downloads.wordpress.org/plugin/seo-automatic-links.zip
unzip seo-automatic-links.zip
rm -f seo-automatic-links.zip
wget http://downloads.wordpress.org/plugin/broken-link-checker.1.9.1.zip
unzip broken-link-checker.1.9.1.zip
rm -f broken-link-checker.1.9.1.zip
wget http://downloads.wordpress.org/plugin/advanced-custom-fields.zip
unzip advanced-custom-fields.zip
rm -f advanced-custom-fields.zip
wget http://downloads.wordpress.org/plugin/safe-redirect-manager.1.7.zip
unzip safe-redirect-manager.1.7.zip
rm -f safe-redirect-manager.1.7.zip
wget http://downloads.wordpress.org/plugin/google-sitemap-generator.3.3.zip
unzip google-sitemap-generator.3.3.zip
rm -f google-sitemap-generator.3.3.zip
git clone https://github.com/devinsays/options-framework-plugin.git options-framework

# Add must-use plugins
cp /$POOR_IO_HOME/PoorIO/files/php-widget.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/includes/php-widget.php

# Move caching plugin files to appropriate directories
cp /$POOR_IO_HOME/PoorIO/gitclones/batcache/advanced-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/advanced-cache.php
cp /$POOR_IO_HOME/PoorIO/gitclones/batcache/batcache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/addons/batcache.php
cp /$POOR_IO_HOME/PoorIO/gitclones/APC/object-cache.php /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/object-cache.php

# Add latest version of Roots IO (see http://roots.io/)
cd /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public/content/themes
git clone https://github.com/roots/roots.git

# Set nginx as owner
chown -Rf nginx:nginx /$WEBSITE_INSTALL_DIRECTORY/$CLI_WEBSITE/public

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
#wp option update permalink_structure '/%post_id%/%postname%' # Best as per http://www.labnol.org/internet/wordpress-permalinks-structure/12633/
#wp option update rss_language 'en'
#wp option update use_smilies 0
#rm -f /usr/local/nginx/conf/conf.d/$CLI_WEBSITE.conf
