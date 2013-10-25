define( 'WP_MEMORY_LIMIT', '256M' );
define( 'WP_MAX_MEMORY_LIMIT', '256M' );

// Experiment with this for security purposes:
define( 'DISALLOW_FILE_MODS', TRUE );
// Disallow unfiltered_html for all users, even admins and super admins
define( 'DISALLOW_UNFILTERED_HTML', TRUE );
// Set to live for production server and dev to for developement
define( 'CURRENT_SERVER', 'dev' );

switch(CURRENT_SERVER){

case 'dev':
        
        // DEVELOPEMENT SET UP
        define('WP_CACHE', FALSE );
        define('WP_DEBUG', TRUE );
        define( 'DISALLOW_FILE_EDIT', TRUE );
        // Save database queries for analysis
        define( 'SAVEQUERIES', TRUE );
        // Include for viewing into the footer of your theme with the following snippet
        /*
        <?php
        if ( current_user_can( 'administrator' ) ) {
                global $wpdb;
                echo "<pre>";
                print_r( $wpdb->queries );
                echo "</pre>";
        }
        ?>
        */
        error_reporting(E_ALL | E_WARNING |  E_ERROR);
        // display errors
        @ini_set('log_errors','Off');
        @ini_set('display_errors','On');
        define('WP_DEBUG_LOG', TRUE);
        define('WP_DEBUG_DISPLAY', TRUE);

case 'live':

        // PRODUCTION SET UP
        define('WP_CACHE', true);
        define('WP_DEBUG', false);
        define( 'DISALLOW_FILE_EDIT', TRUE );
        define( 'SAVEQUERIES', FALSE );
        error_reporting(E_WARNING | E_ERROR);
        // log errors in a file (content/debug.log), don't show them to end-users.
        @ini_set('log_errors','On');
        @ini_set('display_errors','Off');
        define('WP_DEBUG_LOG', TRUE );
        define('WP_DEBUG_DISPLAY', FALSE );

        break;
}

/*
// Proxy Settings
define( 'WP_PROXY_HOST', '10.28.123.4' );
define( 'WP_PROXY_PORT', '8080' );
define( 'WP_PROXY_USERNAME', 'username123' );
define( 'WP_PROXY_PASSWORD', 'password123' );
define( 'WP_PROXY_BYPASS_HOSTS', 'localhost' );
*/

/*
// FTP Data
define( 'FTP_HOST', '' );
define( 'FTP_USER', 'username123' );
define( 'FTP_PASS', 'password123' );
define( 'FTP_SSL', FALSE );
*/
// Defines the site URL to minimize database transactions
define('WP_SITEURL', 'http://' . $_SERVER['SERVER_NAME'] );
// Defines home URL to minimize database transactions
define('WP_HOME', 'http://' . $_SERVER['SERVER_NAME'] );
// Custom content directory
define( 'WP_CONTENT_DIR',  dirname( __FILE__ ) . '/content' );
define( 'WP_CONTENT_URL',  'http://' . $_SERVER['SERVER_NAME'] . '/content' );
// Custom plugin directory
define( 'WP_PLUGIN_DIR',   dirname( __FILE__ ) . '/addons' );
define( 'WP_PLUGIN_URL',   'http://' . $_SERVER['SERVER_NAME'] . '/addons' );
// For compatibility with older scripts
define( 'PLUGINDIR',  WP_PLUGIN_DIR );
// Custom mu plugin directory
define( 'WPMU_PLUGIN_DIR', dirname( __FILE__ ) . '/includes' );
define( 'WPMU_PLUGIN_URL', 'http://' . $_SERVER['SERVER_NAME'] . '/includes' );
// Language directory
// define('WP_LANG_DIR', dirname(__FILE__) . '/languages');
// Upload directory relative to WP install directory (why is it like this? IDK)
// define( 'UPLOADS', '/media' );

// Skip content directory when upgrading to a new WordPress version.
define( 'CORE_UPGRADE_SKIP_NEW_BUNDLED', TRUE );

// Set revision total count and the number of seconds per autosave
define( 'WP_POST_REVISIONS', 5 );
define( 'AUTOSAVE_INTERVAL', 180 );

// Empty trash every X days
define( 'EMPTY_TRASH_DAYS', 14 );

// Compression for JS and styles - supposedly these slow down your website. Regardless, we use pagespeed so let's turn these off
define( 'CONCATENATE_SCRIPTS', FALSE );
define( 'COMPRESS_SCRIPTS',    FALSE );

// Allow uploads of filtered file types to users with administrator role
define( 'ALLOW_UNFILTERED_UPLOADS', TRUE );

// Allow Multisite
define( 'WP_ALLOW_MULTISITE', FALSE );

// Network setup
define( 'MULTISITE',            FALSE );
/*
define( 'SUBDOMAIN_INSTALL',    FALSE );
$base = '/wpbeta/';
define( 'DOMAIN_CURRENT_SITE',  'localhost' );
define( 'PATH_CURRENT_SITE',    '/wpbeta/' );
define( 'SITE_ID_CURRENT_SITE', 1 );
define( 'BLOG_ID_CURRENT_SITE', 1 );
*/

/*
// One cookie for all sites in network, easy to logged in in each site
define( 'ADMIN_COOKIE_PATH', '/' );
define( 'COOKIE_DOMAIN', '' );
define( 'COOKIEPATH', '' );
define( 'SITECOOKIEPATH', '' );
/**/

/*
// Important for use Multisite Without a Domain Mapping Plugin
define( 'COOKIE_DOMAIN', FALSE );
*/