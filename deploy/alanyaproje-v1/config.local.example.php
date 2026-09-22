<?php
/**
 * Copy to config.local.php on the server (never commit config.local.php).
 * Prefer env vars when the host supports them.
 */
return array(
    'firebase_api_key' => 'REPLACE_WITH_FIREBASE_WEB_API_KEY',
    // 'firebase_project_id' => 'taxigo-e7b4b',

    // --- SOS ops notify ---
    // Firebase Cloud Messaging legacy server key (Console → Project settings → Cloud Messaging)
    'sos_fcm_server_key' => 'REPLACE_WITH_FCM_SERVER_KEY',
    // Extra device tokens that always receive SOS (optional)
    'sos_fcm_tokens' => array(
        // 'fcm-device-token-here',
    ),
    // Email alerts (PHP mail())
    'sos_admin_emails' => array(
        'ops@example.com',
    ),
    'sos_mail_from' => 'noreply@alanyaproje.com',
    // Slack / Discord / custom webhook URL
    'sos_webhook_url' => 'https://hooks.example.com/taxigo-sos',
    'sos_notify_admins' => true,
    'ops_api_key' => 'taxigo-ops-sos',
);
