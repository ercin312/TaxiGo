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
);

$local = __DIR__ . '/config.local.php';
if (is_file($local)) {
    $override = require $local;
    if (is_array($override)) {
        $cfg = array_merge($cfg, $override);
    }
}

return $cfg;
