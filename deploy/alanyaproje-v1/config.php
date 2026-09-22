<?php
/**
 * TaxiGo lightweight API for shared hosting (PHP 7.4+).
 * Base URL: https://alanyaproje.com/taxigo/v1
 *
 * Secrets: set TAXIGO_FIREBASE_API_KEY in the environment, or copy
 * config.local.example.php → config.local.php (gitignored) on the server.
 */

$cfg = array(
    'firebase_api_key' => getenv('TAXIGO_FIREBASE_API_KEY') ?: '',
    'firebase_project_id' => getenv('TAXIGO_FIREBASE_PROJECT_ID') ?: 'taxigo-e7b4b',
    'token_ttl_days' => 60,
    'otp_ttl_seconds' => 300,
    'cors_origin' => '*',
    // SOS ops notify (override in config.local.php)
    'sos_notify_admins' => true,
    'sos_fcm_server_key' => getenv('TAXIGO_FCM_SERVER_KEY') ?: '',
    'sos_fcm_tokens' => array(),
    'sos_admin_emails' => array(),
    'sos_admin_email' => getenv('TAXIGO_SOS_ADMIN_EMAIL') ?: '',
    'sos_mail_from' => getenv('TAXIGO_SOS_MAIL_FROM') ?: 'noreply@alanyaproje.com',
    'sos_webhook_url' => getenv('TAXIGO_SOS_WEBHOOK_URL') ?: '',
    'ops_api_key' => getenv('TAXIGO_OPS_API_KEY') ?: 'taxigo-ops-sos',
);

$local = __DIR__ . '/config.local.php';
if (is_file($local)) {
    $override = require $local;
    if (is_array($override)) {
        $cfg = array_merge($cfg, $override);
    }
}

return $cfg;
