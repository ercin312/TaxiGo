<?php
/**
 * TaxiGo API front controller — https://alanyaproje.com/taxigo/v1/*
 */

require __DIR__ . '/bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    tg_json(array('ok' => true));
}

$uri = isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : '/';
$path = parse_url($uri, PHP_URL_PATH);
$path = preg_replace('#^/taxigo/v1#', '', $path);
$path = '/' . trim($path, '/');
if ($path === '/') {
    $path = '';
}
$method = $_SERVER['REQUEST_METHOD'];
$body = tg_read_json();

try {
    // Health
    if ($method === 'GET' && ($path === '' || $path === '/up')) {
        tg_json(array(
            'app' => 'TaxiGo API',
            'status' => 'ok',
            'base' => 'https://alanyaproje.com/taxigo/v1',
        ));
    }

    // Auth — Firebase / Apple / Google
    if ($method === 'POST' && $path === '/auth/firebase-verify') {
        $idToken = isset($body['id_token']) ? $body['id_token'] : '';
        if ($idToken === '') {
            tg_json(array('message' => 'id_token is required.'), 422);
        }
        $firebase = tg_verify_firebase_id_token($idToken);
        if (!$firebase || empty($firebase['firebase_uid'])) {
            tg_json(array('message' => 'Invalid Firebase ID token.'), 401);
        }
        if (!empty($body['name'])) {
            $firebase['name'] = $body['name'];
        }
        if (!empty($body['email'])) {
            $firebase['email'] = $body['email'];
        }
        if (!empty($body['fcm_token'])) {
            $firebase['fcm_token'] = $body['fcm_token'];
        }
        if (!empty($body['locale'])) {
            $firebase['locale'] = $body['locale'];
        }
        $role = (!empty($body['role']) && $body['role'] === 'driver') ? 'driver' : 'passenger';
        $user = tg_find_or_create_user($firebase, $role);
        if (!(int) $user['is_active']) {
            tg_json(array('message' => 'Account is deactivated.'), 403);
        }
        tg_json(tg_issue_session($user, 'firebase'));
    }

    // Auth — OTP request
    if ($method === 'POST' && $path === '/auth/otp/request') {
        $phone = isset($body['phone']) ? trim($body['phone']) : '';
        $role = (!empty($body['role']) && $body['role'] === 'driver') ? 'driver' : 'passenger';
        if (strlen($phone) < 8) {
            tg_json(array('message' => 'Valid phone required.'), 422);
        }

        // Fixed App Review demo accounts
        $reviewCodes = array(
            '+905550000001' => '123456',
            '+905550000002' => '123456',
            '905550000001' => '123456',
            '905550000002' => '123456',
        );
        $normalized = preg_replace('/\s+/', '', $phone);
        $code = isset($reviewCodes[$normalized])
            ? $reviewCodes[$normalized]
            : str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $expires = gmdate('c', time() + (int) tg_config()['otp_ttl_seconds']);
        $pdo = tg_db();
        $pdo->prepare('DELETE FROM otps WHERE phone = ?')->execute(array($phone));
        $pdo->prepare(
            'INSERT INTO otps (phone, code, role, expires_at, created_at) VALUES (?, ?, ?, ?, ?)'
        )->execute(array($phone, $code, $role, $expires, tg_now()));

        tg_json(array(
            'phone' => $phone,
            'channel' => 'app',
            'expires_in' => (int) tg_config()['otp_ttl_seconds'],
            'debug_code' => $code,
        ));
    }

    // Auth — OTP verify
    if ($method === 'POST' && $path === '/auth/otp/verify') {
        $phone = isset($body['phone']) ? trim($body['phone']) : '';
        $code = isset($body['code']) ? trim($body['code']) : '';
        $role = (!empty($body['role']) && $body['role'] === 'driver') ? 'driver' : 'passenger';
        $name = !empty($body['name']) ? trim($body['name']) : null;

        $normalized = preg_replace('/\s+/', '', $phone);
        $reviewOk = in_array($normalized, array('+905550000001', '+905550000002', '905550000001', '905550000002'), true)
            && $code === '123456';

        $pdo = tg_db();
        $otp = null;
        if (!$reviewOk) {
            $stmt = $pdo->prepare(
                'SELECT * FROM otps WHERE phone = ? AND code = ? ORDER BY id DESC LIMIT 1'
            );
            $stmt->execute(array($phone, $code));
            $otp = $stmt->fetch();
            if (!$otp || $otp['expires_at'] < tg_now()) {
                tg_json(array('message' => 'Invalid or expired code.'), 401);
            }
            $pdo->prepare('DELETE FROM otps WHERE phone = ?')->execute(array($phone));
            if (!empty($otp['role'])) {
                $role = $otp['role'];
            }
        } else {
            // Force role from review phone
            if ($normalized === '+905550000002' || $normalized === '905550000002') {
                $role = 'driver';
            } else {
                $role = 'passenger';
            }
            if ($name === null || $name === '') {
                $name = $role === 'driver' ? 'App Review Driver' : 'App Review Passenger';
            }
        }

        $user = tg_find_or_create_user(array(
            'phone' => $phone,
            'name' => $name ? $name : ('Traveler ' . substr($phone, -4)),
            'fcm_token' => isset($body['fcm_token']) ? $body['fcm_token'] : null,
            'locale' => isset($body['locale']) ? $body['locale'] : 'en',
        ), $role);
        tg_json(tg_issue_session($user, 'otp'));
    }

    // Auth — logout
    if ($method === 'POST' && $path === '/auth/logout') {
        $token = tg_bearer_token();
        if ($token) {
            tg_db()->prepare('DELETE FROM tokens WHERE token = ?')->execute(array($token));
        }
        tg_json(array('message' => 'Logged out successfully.'));
    }

    // Device register
    if ($method === 'POST' && $path === '/devices/register') {
        $pdo = tg_db();
        $pdo->prepare(
            'INSERT INTO devices (device_id, fcm_token, platform, phone, created_at) VALUES (?, ?, ?, ?, ?)'
        )->execute(array(
            isset($body['device_id']) ? $body['device_id'] : null,
            isset($body['fcm_token']) ? $body['fcm_token'] : null,
            isset($body['platform']) ? $body['platform'] : null,
            isset($body['phone']) ? $body['phone'] : null,
            tg_now(),
        ));
        tg_json(array('ok' => true));
    }

    // Current user
    if ($method === 'GET' && $path === '/user') {
        $user = tg_require_user();
        tg_json(tg_user_payload($user));
    }

    // Update profile
    if (($method === 'PUT' || $method === 'PATCH' || $method === 'POST') &&
        ($path === '/user' || $path === '/user/profile')) {
        $user = tg_require_user();
        $name = isset($body['name']) ? trim($body['name']) : null;
        $email = isset($body['email']) ? trim($body['email']) : null;
        $pdo = tg_db();
        $pdo->prepare(
            'UPDATE users SET
                name = COALESCE(?, name),
                email = COALESCE(?, email),
                updated_at = ?
             WHERE id = ?'
        )->execute(array(
            $name !== '' ? $name : null,
            $email !== '' ? $email : null,
            tg_now(),
            $user['id'],
        ));
        $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
        $stmt->execute(array($user['id']));
        tg_json(tg_user_payload($stmt->fetch()));
    }

    // Feature modules (public) — map shape matches Laravel ModuleConfigController
    if ($method === 'GET' && $path === '/modules') {
        tg_json(array(
            'modules' => array(
                'otp_login' => true,
                'demo_login' => false,
                'card_payments' => false,
                'sos_alerts' => true,
                'share_trip' => true,
                'ride_comms' => true,
                'ride_receipts' => true,
                'bidding' => true,
                'wallet_topup' => false,
                'withdrawals' => false,
                'fcm_dispatch' => false,
                'rtdb_sync' => false,
            ),
        ));
    }

    if (($method === 'PUT' || $method === 'PATCH' || $method === 'POST') && $path === '/user/locale') {
        $user = tg_require_user();
        $locale = isset($body['locale']) ? trim($body['locale']) : 'tr';
        tg_db()->prepare('UPDATE users SET locale = ?, updated_at = ? WHERE id = ?')
            ->execute(array($locale, tg_now(), $user['id']));
        $stmt = tg_db()->prepare('SELECT * FROM users WHERE id = ?');
        $stmt->execute(array($user['id']));
        tg_json(tg_user_payload($stmt->fetch()));
    }

    // SOS emergency alert — before rides_api so path never falls through as 404
    if ($method === 'POST' && ($path === '/safety/sos' || $path === '/safety/sos/')) {
        $user = tg_require_user();
        $lat = isset($body['latitude']) ? (float) $body['latitude'] : null;
        $lng = isset($body['longitude']) ? (float) $body['longitude'] : null;
        if ($lat === null || $lng === null || $lat < -90 || $lat > 90 || $lng < -180 || $lng > 180) {
            tg_json(array('message' => 'Valid latitude and longitude are required.'), 422);
        }
        $rideId = isset($body['ride_id']) ? (int) $body['ride_id'] : null;
        $message = isset($body['message']) ? trim((string) $body['message']) : 'Emergency SOS triggered by user.';
        if ($message === '') {
            $message = 'Emergency SOS triggered by user.';
        }
        $reference = 'SOS-' . strtoupper(substr(bin2hex(random_bytes(4)), 0, 8));
        $pdo = tg_db();
        $pdo->prepare(
            'INSERT INTO sos_alerts (user_id, ride_id, reference, latitude, longitude, message, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        )->execute(array(
            (int) $user['id'],
            $rideId > 0 ? $rideId : null,
            $reference,
            $lat,
            $lng,
            $message,
            tg_now(),
        ));
        $id = (int) $pdo->lastInsertId();
        $notified = tg_notify_sos(
            $user,
            $id,
            $reference,
            $lat,
            $lng,
            $rideId > 0 ? $rideId : null,
            $message
        );
        @file_put_contents(
            __DIR__ . '/data/sos.log',
            tg_now() . " {$reference} user={$user['id']} lat={$lat} lng={$lng} ride="
                . ($rideId ?: '-')
                . ' notified=' . json_encode($notified) . "\n",
            FILE_APPEND
        );
        tg_json(array(
            'message' => 'SOS alert sent successfully.',
            'complaint_id' => $id,
            'reference' => $reference,
            'notified' => $notified,
        ), 201);
    }

    // Ops: SOS notify channels (FCM / email / webhook)
    if ($method === 'GET' && $path === '/ops/sos-notify') {
        tg_require_ops_key();
        $s = tg_sos_notify_settings();
        // Mask server key in GET
        if (!empty($s['sos_fcm_server_key'])) {
            $k = $s['sos_fcm_server_key'];
            $s['sos_fcm_server_key'] = strlen($k) <= 8
                ? '********'
                : substr($k, 0, 4) . str_repeat('*', max(4, strlen($k) - 8)) . substr($k, -4);
            $s['sos_fcm_server_key_set'] = true;
        } else {
            $s['sos_fcm_server_key_set'] = false;
        }
        tg_json(array('settings' => $s));
    }
    if (($method === 'PUT' || $method === 'POST') && $path === '/ops/sos-notify') {
        tg_require_ops_key();
        $saved = tg_save_sos_notify_settings($body);
        if ($saved === null) {
            tg_json(array('message' => 'Failed to save SOS notify settings.'), 500);
        }
        tg_json(array('message' => 'SOS notify settings saved.', 'settings' => $saved));
    }
    if ($method === 'GET' && $path === '/ops/sos-alerts') {
        tg_require_ops_key();
        $pdo = tg_db();
        $rows = $pdo->query(
            'SELECT id, user_id, ride_id, reference, latitude, longitude, message, created_at
             FROM sos_alerts ORDER BY id DESC LIMIT 50'
        )->fetchAll();
        tg_json(array('data' => $rows));
    }

    require __DIR__ . '/rides_api.php';

    if ($method === 'POST' && $path === '/complaints') {
        $user = tg_require_user();
        tg_json(array(
            'id' => 502,
            'user_id' => (int) $user['id'],
            'subject' => isset($body['subject']) ? $body['subject'] : 'Support',
            'description' => isset($body['description']) ? $body['description'] : '',
            'status' => 'open',
            'created_at' => tg_now(),
        ), 201);
    }
    if ($method === 'GET' && $path === '/wallet') {
        $user = tg_require_user();
        tg_json(array(
            'id' => (int) $user['id'],
            'balance' => 250.0,
            'currency' => 'TRY',
        ));
    }
    if ($method === 'POST' && $path === '/rides/eta') {
        tg_require_user();
        tg_json(array(
            'distance_km' => 5.2,
            'estimated_duration_minutes' => 14,
            'base_fare' => 40,
            'distance_fare' => 52,
            'time_fare' => 20,
            'total_fare' => 112,
            'currency' => 'TRY',
        ));
    }
    if ($method === 'POST' && $path === '/maps/directions') {
        tg_json(array(
            'polyline' => '',
            'distance_km' => 5.2,
            'duration_minutes' => 14,
        ));
    }
    if ($method === 'GET' && strpos($path, '/maps/') === 0) {
        tg_json(array('results' => array()));
    }

    tg_json(array('message' => 'Not found', 'path' => $path), 404);
} catch (Exception $e) {
    tg_json(array(
        'message' => 'Server error',
        'error' => $e->getMessage(),
    ), 500);
}
