<?php
/**
 * Plugin Name:       {{PLUGIN_NAME}}
 * Description:       {{PLUGIN_DESCRIPTION}}
 * Version:           {{VERSION}}
 * Requires at least: {{MIN_WP}}
 * Requires PHP:      {{MIN_PHP}}
 * Author:            {{AUTHOR}}
 * License:           GPL-2.0-or-later
 * License URI:       https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain:       {{TEXT_DOMAIN}}
 * Domain Path:       /languages
 */

defined( 'ABSPATH' ) || exit;

define( '{{PREFIX}}_VERSION', '{{VERSION}}' );
define( '{{PREFIX}}_PLUGIN_FILE', __FILE__ );
define( '{{PREFIX}}_PLUGIN_DIR', plugin_dir_path( __FILE__ ) );
define( '{{PREFIX}}_PLUGIN_URL', plugin_dir_url( __FILE__ ) );

// Autoloading: Composer PSR-4 when vendor/ ships with the plugin;
// otherwise replace this block with explicit classmap requires.
if ( file_exists( {{PREFIX}}_PLUGIN_DIR . 'vendor/autoload.php' ) ) {
	require {{PREFIX}}_PLUGIN_DIR . 'vendor/autoload.php';
}

register_activation_hook( __FILE__, '{{prefix}}_activate' );
/**
 * Activation: schema, default options, rewrite rules.
 */
function {{prefix}}_activate() {
	add_option( '{{prefix}}_settings', array() );
	flush_rewrite_rules();
}

register_deactivation_hook( __FILE__, '{{prefix}}_deactivate' );
/**
 * Deactivation: unschedule cron, clear transient state. Never delete data here.
 */
function {{prefix}}_deactivate() {
	wp_clear_scheduled_hook( '{{prefix}}_cron_hook' );
	flush_rewrite_rules();
}

// Full data cleanup lives in uninstall.php, not here.

add_action( 'init', '{{prefix}}_init' );
/**
 * Register CPTs, taxonomies, and blocks on init.
 */
function {{prefix}}_init() {
}
