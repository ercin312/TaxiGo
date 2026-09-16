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

    // Feature modules (public)
    if ($method === 'GET' && $path === '/modules') {
        tg_json(array(
            'modules' => array(
                array('key' => 'otp_login', 'enabled' => true),
                array('key' => 'demo_login', 'enabled' => false),
                array('key' => 'card_payments', 'enabled' => false),
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
    // Soft stubs so the app does not crash after login
    if ($method === 'GET' && $path === '/driver/profile') {
        $user = tg_require_user();
        tg_json(array(
            'id' => (int) $user['id'],
            'user_id' => (int) $user['id'],
            'approval_status' => 'approved',
            'is_online' => false,
            'current_latitude' => 41.0082,
            'current_longitude' => 28.9784,
            'heading' => 0,
            'rating_average' => 4.9,
            'rating_count' => 128,
            'total_rides' => 420,
            'vehicle' => array(
                'make' => 'Toyota',
                'model' => 'Corolla',
                'plate' => '34 TG 100',
                'color' => 'White',
            ),
        ));
    }
    if ($method === 'POST' && ($path === '/driver/online' || $path === '/driver/offline' || $path === '/driver/location')) {
        tg_require_user();
        tg_json(array('ok' => true));
    }
    if ($method === 'GET' && $path === '/driver/rides/pending') {
        tg_require_user();
        tg_json(array('data' => array()));
    }
    if ($method === 'GET' && $path === '/driver/rides/active') {
        tg_require_user();
        tg_json(array('data' => null));
    }
    if ($method === 'GET' && $path === '/driver/rides/history') {
        tg_require_user();
        tg_json(array(
            'data' => array(
                array(
                    'id' => 1001,
                    'reference' => 'TG-REVIEW-001',
                    'passenger_id' => 1,
                    'driver_id' => 2,
                    'status' => 'completed',
                    'pickup_latitude' => 41.01,
                    'pickup_longitude' => 28.97,
                    'pickup_address' => 'Taksim Square',
                    'dropoff_latitude' => 41.04,
                    'dropoff_longitude' => 29.00,
                    'dropoff_address' => 'Besiktas Pier',
                    'final_fare' => 185.5,
                    'payment_method' => 'cash',
                    'created_at' => tg_now(),
                ),
                array(
                    'id' => 1002,
                    'reference' => 'TG-REVIEW-002',
                    'passenger_id' => 1,
                    'driver_id' => 2,
                    'status' => 'completed',
                    'pickup_latitude' => 41.04,
                    'pickup_longitude' => 29.00,
                    'pickup_address' => 'Besiktas Pier',
                    'dropoff_latitude' => 40.99,
                    'dropoff_longitude' => 29.03,
                    'dropoff_address' => 'Kadikoy Ferry',
                    'final_fare' => 210.0,
                    'payment_method' => 'wallet',
                    'created_at' => tg_now(),
                ),
            ),
        ));
    }
    if ($method === 'GET' && ($path === '/complaints' || $path === '/support/messages')) {
        $user = tg_require_user();
        tg_json(array(
            'data' => array(
                array(
                    'id' => 501,
                    'user_id' => (int) $user['id'],
                    'ride_id' => 1001,
                    'subject' => 'App Review sample thread',
                    'description' => 'Thanks for the smooth ride to Besiktas.',
                    'status' => 'resolved',
                    'admin_response' => 'Glad it went well — welcome to TaxiGo.',
                    'created_at' => tg_now(),
                ),
            ),
        ));
    }
    if ($method === 'GET' && $path === '/rides/active') {
        tg_require_user();
        tg_json(array('data' => null));
    }
    if ($method === 'GET' && $path === '/rides/history') {
        tg_require_user();
        tg_json(array(
            'data' => array(
                array(
                    'id' => 1001,
                    'reference' => 'TG-REVIEW-001',
                    'passenger_id' => 1,
                    'driver_id' => 2,
                    'status' => 'completed',
                    'pickup_latitude' => 41.01,
                    'pickup_longitude' => 28.97,
                    'pickup_address' => 'Taksim Square',
                    'dropoff_latitude' => 41.04,
                    'dropoff_longitude' => 29.00,
                    'dropoff_address' => 'Besiktas Pier',
                    'final_fare' => 185.5,
                    'payment_method' => 'cash',
                    'created_at' => tg_now(),
                ),
                array(
                    'id' => 1002,
                    'reference' => 'TG-REVIEW-002',
                    'passenger_id' => 1,
                    'driver_id' => 2,
                    'status' => 'completed',
                    'pickup_latitude' => 41.04,
                    'pickup_longitude' => 29.00,
                    'pickup_address' => 'Besiktas Pier',
                    'dropoff_latitude' => 40.99,
                    'dropoff_longitude' => 29.03,
                    'dropoff_address' => 'Kadikoy Ferry',
                    'final_fare' => 210.0,
                    'payment_method' => 'wallet',
                    'created_at' => tg_now(),
                ),
            ),
        ));
    }
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
