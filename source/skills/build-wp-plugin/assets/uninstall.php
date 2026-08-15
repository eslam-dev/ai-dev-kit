<?php
/**
 * Uninstall cleanup for {{PLUGIN_NAME}}.
 *
 * Runs only when the plugin is deleted through the WordPress admin.
 */

defined( 'WP_UNINSTALL_PLUGIN' ) || exit;

// Options — repeat for every '{{prefix}}_*' option the plugin registered.
delete_option( '{{prefix}}_settings' );

// Network options on multisite.
delete_site_option( '{{prefix}}_settings' );

// Transients.
delete_transient( '{{prefix}}_cache' );

// Scheduled events.
wp_clear_scheduled_hook( '{{prefix}}_cron_hook' );

// Custom tables — destructive; requires explicit user approval before enabling.
// global $wpdb;
// $wpdb->query( "DROP TABLE IF EXISTS {$wpdb->prefix}{{prefix}}_table" );
