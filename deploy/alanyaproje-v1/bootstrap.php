<?php

function tg_config()
{
    static $cfg = null;
    if ($cfg === null) {
        $cfg = require __DIR__ . '/config.php';
    }
    return $cfg;
}

function tg_json($data, $status = 200)
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: ' . tg_config()['cors_origin']);
    header('Access-Control-Allow-Headers: Authorization, Content-Type, Accept, X-TaxiGo-Ops-Key');
    header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function tg_read_json()
{
    $raw = file_get_contents('php://input');
    if ($raw === false || $raw === '') {
        return array();
    }
    $data = json_decode($raw, true);
    return is_array($data) ? $data : array();
}

function tg_bearer_token()
{
    $header = '';
    if (!empty($_SERVER['HTTP_AUTHORIZATION'])) {
        $header = $_SERVER['HTTP_AUTHORIZATION'];
    } elseif (!empty($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $header = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    }
    if (stripos($header, 'Bearer ') === 0) {
        return trim(substr($header, 7));
    }
    return null;
}

function tg_db()
{
    static $pdo = null;
    if ($pdo !== null) {
        return $pdo;
    }

    $dir = __DIR__ . '/data';
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
    $path = $dir . '/taxigo.sqlite';
    $pdo = new PDO('sqlite:' . $path);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    tg_migrate($pdo);
    return $pdo;
}

function tg_migrate(PDO $pdo)
{
    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firebase_uid TEXT UNIQUE,
            name TEXT NOT NULL,
            email TEXT UNIQUE,
            phone TEXT UNIQUE,
            role TEXT NOT NULL DEFAULT "passenger",
            locale TEXT NOT NULL DEFAULT "tr",
            avatar TEXT,
            is_active INTEGER NOT NULL DEFAULT 1,
            fcm_token TEXT,
            created_at TEXT,
            updated_at TEXT
        )'
    );
    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS tokens (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            token TEXT NOT NULL UNIQUE,
            expires_at TEXT,
            created_at TEXT,
            FOREIGN KEY(user_id) REFERENCES users(id)
        )'
    );
    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS otps (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            phone TEXT NOT NULL,
            code TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT "passenger",
            expires_at TEXT NOT NULL,
            created_at TEXT
        )'
    );
    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS devices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT,
            fcm_token TEXT,
            platform TEXT,
            phone TEXT,
            created_at TEXT
        )'
    );
    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS sos_alerts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            ride_id INTEGER,
            reference TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            message TEXT,
            created_at TEXT,
            FOREIGN KEY(user_id) REFERENCES users(id)
        )'
    );
    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS drivers (
            user_id INTEGER PRIMARY KEY,
            is_online INTEGER NOT NULL DEFAULT 0,
            latitude REAL,
            longitude REAL,
            heading REAL DEFAULT 0,
            updated_at TEXT,
            FOREIGN KEY(user_id) REFERENCES users(id)
        )'
    );
    $pdo->exec(
        'CREATE TABLE IF NOT EXISTS rides (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reference TEXT NOT NULL,
            passenger_id INTEGER NOT NULL,
            driver_id INTEGER,
            status TEXT NOT NULL DEFAULT "pending",
            pickup_latitude REAL NOT NULL,
            pickup_longitude REAL NOT NULL,
            pickup_address TEXT NOT NULL,
            dropoff_latitude REAL NOT NULL,
            dropoff_longitude REAL NOT NULL,
            dropoff_address TEXT NOT NULL,
            estimated_fare REAL,
            offered_fare REAL,
            minimum_fare REAL,
            final_fare REAL,
            is_bidding INTEGER NOT NULL DEFAULT 0,
            vehicle_type TEXT DEFAULT "standard",
            product_mode TEXT DEFAULT "taxi",
            payment_method TEXT DEFAULT "cash",
            passenger_note TEXT,
            scheduled_at TEXT,
            driver_assigned_at TEXT,
            driver_arrived_at TEXT,
            started_at TEXT,
            completed_at TEXT,
            cancelled_at TEXT,
            created_at TEXT,
            updated_at TEXT,
            FOREIGN KEY(passenger_id) REFERENCES users(id),
            FOREIGN KEY(driver_id) REFERENCES users(id)
        )'
    );
    // Existing DBs created before scheduled_at support.
    try {
        $pdo->exec('ALTER TABLE rides ADD COLUMN scheduled_at TEXT');
    } catch (Throwable $e) {
        // Column already exists.
    }
}

function tg_ride_row_to_api(array $ride, PDO $pdo = null)
{
    $pdo = $pdo ?: tg_db();
    $out = array(
        'id' => (int) $ride['id'],
        'reference' => $ride['reference'],
        'passenger_id' => (int) $ride['passenger_id'],
        'driver_id' => $ride['driver_id'] !== null ? (int) $ride['driver_id'] : null,
        'status' => $ride['status'],
        'pickup_latitude' => (float) $ride['pickup_latitude'],
        'pickup_longitude' => (float) $ride['pickup_longitude'],
        'pickup_address' => $ride['pickup_address'],
        'dropoff_latitude' => (float) $ride['dropoff_latitude'],
        'dropoff_longitude' => (float) $ride['dropoff_longitude'],
        'dropoff_address' => $ride['dropoff_address'],
        'estimated_fare' => $ride['estimated_fare'] !== null ? (float) $ride['estimated_fare'] : null,
        'offered_fare' => $ride['offered_fare'] !== null ? (float) $ride['offered_fare'] : null,
        'minimum_fare' => $ride['minimum_fare'] !== null ? (float) $ride['minimum_fare'] : null,
        'final_fare' => $ride['final_fare'] !== null ? (float) $ride['final_fare'] : null,
        'is_bidding' => ((int) $ride['is_bidding']) === 1,
        'vehicle_type' => $ride['vehicle_type'] ? $ride['vehicle_type'] : 'standard',
        'product_mode' => $ride['product_mode'] ? $ride['product_mode'] : 'taxi',
        'payment_method' => $ride['payment_method'] ? $ride['payment_method'] : 'cash',
        'passenger_note' => $ride['passenger_note'],
        'scheduled_at' => isset($ride['scheduled_at']) ? $ride['scheduled_at'] : null,
        'driver_assigned_at' => $ride['driver_assigned_at'],
        'driver_arrived_at' => $ride['driver_arrived_at'],
        'started_at' => $ride['started_at'],
        'completed_at' => $ride['completed_at'],
        'cancelled_at' => $ride['cancelled_at'],
        'created_at' => $ride['created_at'],
        'updated_at' => $ride['updated_at'],
    );
    if (!empty($ride['driver_id'])) {
        $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
        $stmt->execute(array($ride['driver_id']));
        $du = $stmt->fetch();
        if ($du) {
            $out['driver_name'] = $du['name'];
            $out['driver'] = array(
                'id' => (int) $du['id'],
                'user' => array('id' => (int) $du['id'], 'name' => $du['name'], 'phone' => $du['phone']),
                'vehicle' => array(
                    'plate_number' => 'ME TG ' . substr((string) $du['id'], -3),
                    'make' => 'Toyota',
                    'model' => 'Corolla',
                ),
            );
        }
    }
    return $out;
}

function tg_now()
{
    return gmdate('c');
}

function tg_user_payload(array $user)
{
    return array(
        'id' => (int) $user['id'],
        'name' => $user['name'],
        'email' => $user['email'],
        'phone' => $user['phone'],
        'firebase_uid' => $user['firebase_uid'],
        'role' => $user['role'],
        'locale' => $user['locale'] ? $user['locale'] : 'tr',
        'avatar' => $user['avatar'],
        'is_active' => ((int) $user['is_active']) === 1,
        'fcm_token' => $user['fcm_token'],
        'driver' => null,
        'wallet' => array(
            'id' => (int) $user['id'],
            'balance' => 0,
            'currency' => 'TRY',
        ),
    );
}

function tg_issue_session(array $user, $authMode = 'firebase')
{
    $pdo = tg_db();
    $token = bin2hex(random_bytes(32));
    $ttl = (int) tg_config()['token_ttl_days'];
    $expires = gmdate('c', time() + ($ttl * 86400));
    $stmt = $pdo->prepare(
        'INSERT INTO tokens (user_id, token, expires_at, created_at) VALUES (?, ?, ?, ?)'
    );
    $stmt->execute(array($user['id'], $token, $expires, tg_now()));

    return array(
        'token' => $token,
        'token_type' => 'Bearer',
        'user' => tg_user_payload($user),
        'auth_mode' => $authMode,
        'firebase_custom_token' => null,
    );
}

function tg_current_user()
{
    $token = tg_bearer_token();
    if (!$token) {
        return null;
    }
    $pdo = tg_db();
    $stmt = $pdo->prepare(
        'SELECT u.* FROM tokens t
         INNER JOIN users u ON u.id = t.user_id
         WHERE t.token = ? AND (t.expires_at IS NULL OR t.expires_at > ?)
         LIMIT 1'
    );
    $stmt->execute(array($token, tg_now()));
    $user = $stmt->fetch();
    return $user ? $user : null;
}

function tg_require_user()
{
    $user = tg_current_user();
    if (!$user) {
        tg_json(array('message' => 'Unauthenticated.'), 401);
    }
    if (!(int) $user['is_active']) {
        tg_json(array('message' => 'Account is deactivated.'), 403);
    }
    return $user;
}

function tg_verify_firebase_id_token($idToken)
{
    $key = tg_config()['firebase_api_key'];
    if (!$key) {
        return null;
    }
    $url = 'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=' . urlencode($key);
    $payload = json_encode(array('idToken' => $idToken));

    $ch = curl_init($url);
    curl_setopt_array($ch, array(
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => array('Content-Type: application/json'),
        CURLOPT_POSTFIELDS => $payload,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 15,
    ));
    $body = curl_exec($ch);
    $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($code < 200 || $code >= 300 || !$body) {
        return null;
    }
    $json = json_decode($body, true);
    if (empty($json['users'][0])) {
        return null;
    }
    $u = $json['users'][0];
    return array(
        'firebase_uid' => isset($u['localId']) ? $u['localId'] : null,
        'email' => isset($u['email']) ? $u['email'] : null,
        'phone' => isset($u['phoneNumber']) ? $u['phoneNumber'] : null,
        'name' => isset($u['displayName']) ? $u['displayName'] : null,
        'avatar' => isset($u['photoUrl']) ? $u['photoUrl'] : null,
    );
}

function tg_find_or_create_user(array $data, $role = 'passenger')
{
    $pdo = tg_db();
    $user = null;

    if (!empty($data['firebase_uid'])) {
        $stmt = $pdo->prepare('SELECT * FROM users WHERE firebase_uid = ? LIMIT 1');
        $stmt->execute(array($data['firebase_uid']));
        $user = $stmt->fetch();
    }
    if (!$user && !empty($data['email'])) {
        $stmt = $pdo->prepare('SELECT * FROM users WHERE email = ? LIMIT 1');
        $stmt->execute(array($data['email']));
        $user = $stmt->fetch();
    }
    if (!$user && !empty($data['phone'])) {
        $stmt = $pdo->prepare('SELECT * FROM users WHERE phone = ? LIMIT 1');
        $stmt->execute(array($data['phone']));
        $user = $stmt->fetch();
    }

    $now = tg_now();
    if ($user) {
        $incomingName = !empty($data['name']) ? trim((string) $data['name']) : null;
        $incomingEmail = !empty($data['email']) ? trim((string) $data['email']) : null;
        $existingName = isset($user['name']) ? trim((string) $user['name']) : '';
        $placeholders = array('Apple Traveler', 'Google Traveler', 'Traveler', '');
        // Prefer a real name over empty / placeholder when Apple/Google finally sends one.
        if ($incomingName !== null &&
            ($existingName === '' || in_array($existingName, $placeholders, true))) {
            $nameSql = '?';
            $nameVal = $incomingName;
        } else {
            $nameSql = 'COALESCE(?, name)';
            $nameVal = $incomingName;
        }

        $stmt = $pdo->prepare(
            "UPDATE users SET
                firebase_uid = COALESCE(?, firebase_uid),
                name = {$nameSql},
                email = COALESCE(?, email),
                phone = COALESCE(?, phone),
                avatar = COALESCE(?, avatar),
                fcm_token = COALESCE(?, fcm_token),
                updated_at = ?
             WHERE id = ?"
        );
        $stmt->execute(array(
            isset($data['firebase_uid']) ? $data['firebase_uid'] : null,
            $nameVal,
            $incomingEmail,
            !empty($data['phone']) ? $data['phone'] : null,
            !empty($data['avatar']) ? $data['avatar'] : null,
            !empty($data['fcm_token']) ? $data['fcm_token'] : null,
            $now,
            $user['id'],
        ));
        $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
        $stmt->execute(array($user['id']));
        return $stmt->fetch();
    }

    $name = !empty($data['name']) ? $data['name'] : 'Apple Traveler';
    $stmt = $pdo->prepare(
        'INSERT INTO users (firebase_uid, name, email, phone, role, locale, avatar, is_active, fcm_token, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)'
    );
    $stmt->execute(array(
        isset($data['firebase_uid']) ? $data['firebase_uid'] : null,
        $name,
        isset($data['email']) ? $data['email'] : null,
        isset($data['phone']) ? $data['phone'] : null,
        $role ? $role : 'passenger',
        !empty($data['locale']) ? $data['locale'] : 'tr',
        isset($data['avatar']) ? $data['avatar'] : null,
        isset($data['fcm_token']) ? $data['fcm_token'] : null,
        $now,
        $now,
    ));
    $id = (int) $pdo->lastInsertId();
    $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ?');
    $stmt->execute(array($id));
    return $stmt->fetch();
}

/**
 * Runtime SOS notify overrides (data/sos_notify.json) merged over config.
 */
function tg_sos_notify_settings()
{
    $cfg = tg_config();
    $settings = array(
        'sos_notify_admins' => !isset($cfg['sos_notify_admins']) || (bool) $cfg['sos_notify_admins'],
        'sos_fcm_server_key' => isset($cfg['sos_fcm_server_key']) ? (string) $cfg['sos_fcm_server_key'] : '',
        'sos_fcm_tokens' => isset($cfg['sos_fcm_tokens']) && is_array($cfg['sos_fcm_tokens'])
            ? array_values($cfg['sos_fcm_tokens'])
            : array(),
        'sos_admin_emails' => isset($cfg['sos_admin_emails']) && is_array($cfg['sos_admin_emails'])
            ? array_values($cfg['sos_admin_emails'])
            : array(),
        'sos_admin_email' => isset($cfg['sos_admin_email']) ? (string) $cfg['sos_admin_email'] : '',
        'sos_mail_from' => isset($cfg['sos_mail_from']) ? (string) $cfg['sos_mail_from'] : 'noreply@alanyaproje.com',
        'sos_webhook_url' => isset($cfg['sos_webhook_url']) ? (string) $cfg['sos_webhook_url'] : '',
    );
    if ($settings['sos_admin_email'] !== '' && empty($settings['sos_admin_emails'])) {
        $settings['sos_admin_emails'] = array($settings['sos_admin_email']);
    }
    $path = __DIR__ . '/data/sos_notify.json';
    if (is_file($path)) {
        $raw = @file_get_contents($path);
        $json = json_decode($raw !== false ? $raw : '', true);
        if (is_array($json)) {
            foreach ($settings as $k => $v) {
                if (!array_key_exists($k, $json)) {
                    continue;
                }
                if (is_array($v) && is_array($json[$k])) {
                    $settings[$k] = array_values($json[$k]);
                } elseif (!is_array($v)) {
                    $settings[$k] = $json[$k];
                }
            }
        }
    }
    if (!empty($cfg['fcm_server_key']) && $settings['sos_fcm_server_key'] === '') {
        $settings['sos_fcm_server_key'] = (string) $cfg['fcm_server_key'];
    }
    return $settings;
}

function tg_save_sos_notify_settings(array $incoming)
{
    $current = tg_sos_notify_settings();
    $allowed = array(
        'sos_notify_admins',
        'sos_fcm_server_key',
        'sos_fcm_tokens',
        'sos_admin_emails',
        'sos_admin_email',
        'sos_mail_from',
        'sos_webhook_url',
    );
    foreach ($allowed as $key) {
        if (!array_key_exists($key, $incoming)) {
            continue;
        }
        if ($key === 'sos_notify_admins') {
            $current[$key] = (bool) $incoming[$key];
        } elseif ($key === 'sos_fcm_tokens' || $key === 'sos_admin_emails') {
            $list = is_array($incoming[$key]) ? $incoming[$key] : array();
            $current[$key] = array_values(array_filter(array_map(function ($v) {
                return trim((string) $v);
            }, $list)));
        } else {
            $current[$key] = trim((string) $incoming[$key]);
        }
    }
    if ($current['sos_admin_email'] !== '' && empty($current['sos_admin_emails'])) {
        $current['sos_admin_emails'] = array($current['sos_admin_email']);
    }
    $dir = __DIR__ . '/data';
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
    $ok = @file_put_contents(
        $dir . '/sos_notify.json',
        json_encode($current, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)
    );
    return $ok !== false ? $current : null;
}

function tg_require_ops_key()
{
    $cfg = tg_config();
    $expected = isset($cfg['ops_api_key']) ? trim((string) $cfg['ops_api_key']) : '';
    if ($expected === '') {
        $expected = 'taxigo-ops-sos';
    }
    $got = '';
    if (!empty($_SERVER['HTTP_X_TAXIGO_OPS_KEY'])) {
        $got = trim((string) $_SERVER['HTTP_X_TAXIGO_OPS_KEY']);
    } elseif (!empty($_SERVER['HTTP_AUTHORIZATION']) && stripos($_SERVER['HTTP_AUTHORIZATION'], 'Ops ') === 0) {
        $got = trim(substr($_SERVER['HTTP_AUTHORIZATION'], 4));
    }
    if ($got === '' || !hash_equals($expected, $got)) {
        tg_json(array('message' => 'Unauthorized ops key.'), 401);
    }
}

/**
 * HTTP POST helper (JSON). Returns array with ok/status/body.
 */
function tg_http_post($url, array $payload, array $headers = array(), $timeout = 12)
{
    $body = json_encode($payload, JSON_UNESCAPED_UNICODE);
    $ch = curl_init($url);
    $hdrs = array('Content-Type: application/json', 'Accept: application/json');
    foreach ($headers as $h) {
        $hdrs[] = $h;
    }
    curl_setopt_array($ch, array(
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => $hdrs,
        CURLOPT_POSTFIELDS => $body,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => $timeout,
        CURLOPT_CONNECTTIMEOUT => 8,
    ));
    $raw = curl_exec($ch);
    $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $err = curl_error($ch);
    curl_close($ch);
    return array(
        'ok' => $err === '' && $status >= 200 && $status < 300,
        'status' => $status,
        'body' => $raw,
        'error' => $err,
    );
}

/**
 * Send FCM via Legacy HTTP API (server key) to one device token.
 */
function tg_fcm_send_legacy($serverKey, $token, $title, $body, array $data = array())
{
    if ($serverKey === '' || $token === '') {
        return false;
    }
    $stringData = array();
    foreach ($data as $k => $v) {
        $stringData[(string) $k] = (string) $v;
    }
    $res = tg_http_post(
        'https://fcm.googleapis.com/fcm/send',
        array(
            'to' => $token,
            'priority' => 'high',
            'notification' => array(
                'title' => $title,
                'body' => $body,
                'sound' => 'default',
                'android_channel_id' => 'taxigo_sos',
            ),
            'data' => $stringData,
        ),
        array('Authorization: key=' . $serverKey)
    );
    return !empty($res['ok']);
}

/**
 * Notify ops: admin FCM, email, webhook (+ optional ride driver FCM).
 *
 * @return array{admins:int,driver:bool,webhook:bool,email:bool}
 */
function tg_notify_sos(array $user, $alertId, $reference, $lat, $lng, $rideId, $message)
{
    $cfg = tg_sos_notify_settings();
    $title = 'SOS Emergency';
    $body = sprintf(
        '%s · %s (%.5f, %.5f)',
        !empty($user['name']) ? $user['name'] : 'User',
        $reference,
        $lat,
        $lng
    );
    $payload = array(
        'type' => 'sos',
        'reference' => $reference,
        'complaint_id' => (int) $alertId,
        'user_id' => (int) $user['id'],
        'phone' => isset($user['phone']) ? $user['phone'] : null,
        'name' => isset($user['name']) ? $user['name'] : null,
        'latitude' => $lat,
        'longitude' => $lng,
        'message' => $message,
        'ride_id' => $rideId ? (int) $rideId : null,
        'maps' => sprintf('https://maps.google.com/?q=%.6f,%.6f', $lat, $lng),
        'created_at' => tg_now(),
    );

    $adminCount = 0;
    $driverNotified = false;
    $webhookOk = false;
    $emailOk = false;

    $notifyAdmins = !empty($cfg['sos_notify_admins']);
    $serverKey = isset($cfg['sos_fcm_server_key']) ? trim((string) $cfg['sos_fcm_server_key']) : '';

    if ($notifyAdmins && $serverKey !== '') {
        $pdo = tg_db();
        $admins = $pdo->query(
            "SELECT fcm_token FROM users
             WHERE role IN ('admin','super_admin')
               AND fcm_token IS NOT NULL AND TRIM(fcm_token) != ''
               AND is_active = 1"
        )->fetchAll();
        foreach ($admins as $admin) {
            if (tg_fcm_send_legacy($serverKey, $admin['fcm_token'], $title, $body, array(
                'type' => 'sos',
                'complaint_id' => (string) $alertId,
                'reference' => $reference,
                'latitude' => (string) $lat,
                'longitude' => (string) $lng,
            ))) {
                $adminCount++;
            }
        }
        $extra = isset($cfg['sos_fcm_tokens']) && is_array($cfg['sos_fcm_tokens'])
            ? $cfg['sos_fcm_tokens']
            : array();
        foreach ($extra as $tok) {
            $tok = trim((string) $tok);
            if ($tok === '') {
                continue;
            }
            if (tg_fcm_send_legacy($serverKey, $tok, $title, $body, array(
                'type' => 'sos',
                'complaint_id' => (string) $alertId,
                'reference' => $reference,
                'latitude' => (string) $lat,
                'longitude' => (string) $lng,
            ))) {
                $adminCount++;
            }
        }
    }

    if ($rideId && $serverKey !== '') {
        $pdo = tg_db();
        $stmt = $pdo->prepare(
            'SELECT u.fcm_token FROM rides r
             INNER JOIN users u ON u.id = r.driver_id
             WHERE r.id = ? AND u.fcm_token IS NOT NULL AND TRIM(u.fcm_token) != \'\'
             LIMIT 1'
        );
        $stmt->execute(array((int) $rideId));
        $row = $stmt->fetch();
        if ($row && !empty($row['fcm_token'])) {
            $driverNotified = tg_fcm_send_legacy(
                $serverKey,
                $row['fcm_token'],
                $title,
                'Passenger triggered SOS during the trip.',
                array(
                    'type' => 'sos',
                    'ride_id' => (string) $rideId,
                    'reference' => $reference,
                )
            );
        }
    }

    $webhookUrl = isset($cfg['sos_webhook_url']) ? trim((string) $cfg['sos_webhook_url']) : '';
    if ($webhookUrl !== '') {
        $res = tg_http_post($webhookUrl, $payload);
        $webhookOk = !empty($res['ok']);
        if (!$webhookOk) {
            @file_put_contents(
                __DIR__ . '/data/sos.log',
                tg_now() . " webhook_fail status={$res['status']} err={$res['error']}\n",
                FILE_APPEND
            );
        }
    }

    $emails = array();
    if (!empty($cfg['sos_admin_emails']) && is_array($cfg['sos_admin_emails'])) {
        $emails = $cfg['sos_admin_emails'];
    } elseif (!empty($cfg['sos_admin_email'])) {
        $emails = array($cfg['sos_admin_email']);
    }
    $emails = array_values(array_filter(array_map('trim', $emails)));
    if (!empty($emails)) {
        $from = !empty($cfg['sos_mail_from'])
            ? (string) $cfg['sos_mail_from']
            : 'noreply@alanyaproje.com';
        $subject = "[TaxiGo SOS] {$reference}";
        $mailBody = "TaxiGo SOS alert\n\n"
            . "Reference: {$reference}\n"
            . "User: " . (isset($user['name']) ? $user['name'] : '-') . "\n"
            . "Phone: " . (isset($user['phone']) ? $user['phone'] : '-') . "\n"
            . "Lat/Lng: {$lat}, {$lng}\n"
            . "Maps: {$payload['maps']}\n"
            . "Ride: " . ($rideId ? $rideId : '-') . "\n"
            . "Message: {$message}\n"
            . "Time: " . tg_now() . "\n";
        $headers = 'From: ' . $from . "\r\n"
            . "Content-Type: text/plain; charset=UTF-8\r\n"
            . "X-Mailer: TaxiGo-SOS\r\n";
        $sentAny = false;
        foreach ($emails as $to) {
            if ($to === '') {
                continue;
            }
            if (@mail($to, $subject, $mailBody, $headers)) {
                $sentAny = true;
            }
        }
        $emailOk = $sentAny;
    }

    return array(
        'admins' => $adminCount,
        'driver' => $driverNotified,
        'webhook' => $webhookOk,
        'email' => $emailOk,
    );
}
