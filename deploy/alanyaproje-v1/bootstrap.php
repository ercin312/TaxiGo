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
    header('Access-Control-Allow-Headers: Authorization, Content-Type, Accept');
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
        $stmt = $pdo->prepare(
            'UPDATE users SET
                firebase_uid = COALESCE(?, firebase_uid),
                name = COALESCE(?, name),
                email = COALESCE(?, email),
                phone = COALESCE(?, phone),
                avatar = COALESCE(?, avatar),
                fcm_token = COALESCE(?, fcm_token),
                updated_at = ?
             WHERE id = ?'
        );
        $stmt->execute(array(
            isset($data['firebase_uid']) ? $data['firebase_uid'] : null,
            !empty($data['name']) ? $data['name'] : null,
            !empty($data['email']) ? $data['email'] : null,
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
