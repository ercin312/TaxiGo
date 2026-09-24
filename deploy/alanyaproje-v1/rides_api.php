<?php
/**
 * Driver presence + ride matching for two-phone live tests.
 * Included from index.php inside the main try block.
 */

if ($method === 'GET' && $path === '/driver/profile') {
    $user = tg_require_user();
    $pdo = tg_db();
    $stmt = $pdo->prepare('SELECT * FROM drivers WHERE user_id = ?');
    $stmt->execute(array($user['id']));
    $d = $stmt->fetch();
    if (!$d) {
        $pdo->prepare(
            'INSERT INTO drivers (user_id, is_online, latitude, longitude, heading, updated_at) VALUES (?, 0, ?, ?, 0, ?)'
        )->execute(array($user['id'], 42.4304, 19.2594, tg_now()));
        $d = array('is_online' => 0, 'latitude' => 42.4304, 'longitude' => 19.2594, 'heading' => 0);
    }
    tg_json(array(
        'id' => (int) $user['id'],
        'user_id' => (int) $user['id'],
        'approval_status' => 'approved',
        'is_online' => ((int) $d['is_online']) === 1,
        'current_latitude' => isset($d['latitude']) ? (float) $d['latitude'] : 42.4304,
        'current_longitude' => isset($d['longitude']) ? (float) $d['longitude'] : 19.2594,
        'heading' => isset($d['heading']) ? (float) $d['heading'] : 0,
        'rating_average' => 4.9,
        'rating_count' => 128,
        'total_rides' => 0,
        'vehicle' => array(
            'make' => 'Toyota',
            'model' => 'Corolla',
            'plate_number' => 'ME TG ' . substr((string) $user['id'], -3),
            'color' => 'Yellow',
            'year' => 2022,
        ),
    ));
}

if ($method === 'POST' && $path === '/driver/online') {
    $user = tg_require_user();
    $lat = isset($body['latitude']) ? (float) $body['latitude'] : 42.4304;
    $lng = isset($body['longitude']) ? (float) $body['longitude'] : 19.2594;
    $pdo = tg_db();
    $pdo->prepare(
        'INSERT INTO drivers (user_id, is_online, latitude, longitude, heading, updated_at)
         VALUES (?, 1, ?, ?, 0, ?)
         ON CONFLICT(user_id) DO UPDATE SET is_online = 1, latitude = excluded.latitude,
           longitude = excluded.longitude, updated_at = excluded.updated_at'
    )->execute(array($user['id'], $lat, $lng, tg_now()));
    tg_json(array('message' => 'Driver is online.', 'is_online' => true));
}

if ($method === 'POST' && $path === '/driver/offline') {
    $user = tg_require_user();
    $pdo = tg_db();
    $pdo->prepare(
        'INSERT INTO drivers (user_id, is_online, updated_at) VALUES (?, 0, ?)
         ON CONFLICT(user_id) DO UPDATE SET is_online = 0, updated_at = excluded.updated_at'
    )->execute(array($user['id'], tg_now()));
    tg_json(array('message' => 'Driver is offline.', 'is_online' => false));
}

if ($method === 'POST' && $path === '/driver/location') {
    $user = tg_require_user();
    $lat = isset($body['latitude']) ? (float) $body['latitude'] : null;
    $lng = isset($body['longitude']) ? (float) $body['longitude'] : null;
    $heading = isset($body['heading']) ? (float) $body['heading'] : 0;
    if ($lat === null || $lng === null) {
        tg_json(array('message' => 'latitude/longitude required'), 422);
    }
    $pdo = tg_db();
    $pdo->prepare(
        'INSERT INTO drivers (user_id, is_online, latitude, longitude, heading, updated_at)
         VALUES (?, 1, ?, ?, ?, ?)
         ON CONFLICT(user_id) DO UPDATE SET latitude = excluded.latitude,
           longitude = excluded.longitude, heading = excluded.heading, updated_at = excluded.updated_at'
    )->execute(array($user['id'], $lat, $lng, $heading, tg_now()));
    tg_json(array('ok' => true));
}

if ($method === 'POST' && $path === '/rides') {
    $user = tg_require_user();
    $pickupLat = isset($body['pickup_latitude']) ? (float) $body['pickup_latitude'] : null;
    $pickupLng = isset($body['pickup_longitude']) ? (float) $body['pickup_longitude'] : null;
    $dropLat = isset($body['dropoff_latitude']) ? (float) $body['dropoff_latitude'] : null;
    $dropLng = isset($body['dropoff_longitude']) ? (float) $body['dropoff_longitude'] : null;
    $pickupAddr = isset($body['pickup_address']) ? trim($body['pickup_address']) : '';
    $dropAddr = isset($body['dropoff_address']) ? trim($body['dropoff_address']) : '';
    if ($pickupLat === null || $pickupLng === null || $dropLat === null || $dropLng === null) {
        tg_json(array('message' => 'Pickup and dropoff coordinates required.'), 422);
    }
    $fare = isset($body['offered_fare']) ? (float) $body['offered_fare'] : 5.0;
    if ($fare < 1) {
        $fare = 5.0;
    }
    $matchMode = isset($body['match_mode']) ? $body['match_mode'] : 'instant';
    $isBidding = (!empty($body['is_bidding']) || $matchMode === 'bidding') ? 1 : 0;
    $scheduledAt = null;
    if (!empty($body['scheduled_at'])) {
        $ts = strtotime((string) $body['scheduled_at']);
        if ($ts === false || $ts <= time()) {
            tg_json(array('message' => 'scheduled_at must be a future datetime.'), 422);
        }
        $scheduledAt = gmdate('c', $ts);
        $isBidding = 0; // scheduled rides are not bidding
    }
    $ref = 'TG-' . strtoupper(substr(bin2hex(random_bytes(4)), 0, 8));
    $now = tg_now();
    $pdo = tg_db();
    $pdo->prepare(
        'INSERT INTO rides (
            reference, passenger_id, status, pickup_latitude, pickup_longitude, pickup_address,
            dropoff_latitude, dropoff_longitude, dropoff_address, estimated_fare, offered_fare,
            minimum_fare, is_bidding, vehicle_type, product_mode, payment_method, passenger_note,
            scheduled_at, created_at, updated_at
         ) VALUES (?, ?, \'pending\', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    )->execute(array(
        $ref,
        (int) $user['id'],
        $pickupLat,
        $pickupLng,
        $pickupAddr !== '' ? $pickupAddr : 'Pickup',
        $dropLat,
        $dropLng,
        $dropAddr !== '' ? $dropAddr : 'Dropoff',
        $fare,
        $fare,
        min(5.0, $fare),
        $isBidding,
        isset($body['vehicle_type']) ? $body['vehicle_type'] : 'standard',
        isset($body['product_mode']) ? $body['product_mode'] : 'taxi',
        isset($body['payment_method']) ? $body['payment_method'] : 'cash',
        isset($body['passenger_note']) ? $body['passenger_note'] : null,
        $scheduledAt,
        $now,
        $now,
    ));
    $id = (int) $pdo->lastInsertId();
    $assigned = false;
    // Instant assign only for non-scheduled, non-bidding rides.
    if (!$isBidding && $scheduledAt === null) {
        $drivers = $pdo->query('SELECT user_id, latitude, longitude FROM drivers WHERE is_online = 1')->fetchAll();
        $best = null;
        $bestDist = 1e9;
        foreach ($drivers as $dr) {
            if ($dr['latitude'] === null || $dr['longitude'] === null) {
                continue;
            }
            $dlat = (float) $dr['latitude'] - $pickupLat;
            $dlng = (float) $dr['longitude'] - $pickupLng;
            $dist = ($dlat * $dlat) + ($dlng * $dlng);
            if ($dist < $bestDist) {
                $bestDist = $dist;
                $best = $dr;
            }
        }
        if ($best) {
            $pdo->prepare(
                'UPDATE rides SET driver_id = ?, status = \'driver_arriving\', driver_assigned_at = ?, updated_at = ? WHERE id = ?'
            )->execute(array($best['user_id'], $now, $now, $id));
            $assigned = true;
        }
    }
    $stmt = $pdo->prepare('SELECT * FROM rides WHERE id = ?');
    $stmt->execute(array($id));
    tg_json(array(
        'message' => $scheduledAt ? 'Ride scheduled.' : 'Ride created.',
        'ride' => tg_ride_row_to_api($stmt->fetch(), $pdo),
        'instant_assigned' => $assigned,
    ), 201);
}

if ($method === 'GET' && preg_match('#^/rides/(\d+)$#', $path, $m)) {
    $user = tg_require_user();
    $stmt = tg_db()->prepare('SELECT * FROM rides WHERE id = ?');
    $stmt->execute(array((int) $m[1]));
    $ride = $stmt->fetch();
    if (!$ride) {
        tg_json(array('message' => 'Ride not found.'), 404);
    }
    if ((int) $ride['passenger_id'] !== (int) $user['id'] &&
        (int) $ride['driver_id'] !== (int) $user['id']) {
        tg_json(array('message' => 'Unauthorized.'), 403);
    }
    tg_json(tg_ride_row_to_api($ride));
}

if ($method === 'GET' && $path === '/driver/rides/pending') {
    tg_require_user();
    $pdo = tg_db();
    $now = tg_now();
    // Instant jobs only (not future-scheduled).
    $rows = $pdo->query(
        "SELECT * FROM rides
         WHERE status = 'pending' AND driver_id IS NULL
           AND (scheduled_at IS NULL OR scheduled_at <= '$now')
         ORDER BY id DESC LIMIT 20"
    )->fetchAll();
    $data = array();
    foreach ($rows as $row) {
        $data[] = tg_ride_row_to_api($row, $pdo);
    }
    tg_json(array('data' => $data));
}

if ($method === 'GET' && $path === '/driver/rides/planned') {
    $user = tg_require_user();
    $pdo = tg_db();
    $now = tg_now();
    $uid = (int) $user['id'];
    // Open future jobs + ones already reserved by this driver.
    $stmt = $pdo->prepare(
        "SELECT * FROM rides
         WHERE status NOT IN ('completed','cancelled_by_passenger','cancelled_by_driver','expired')
           AND scheduled_at IS NOT NULL AND scheduled_at > ?
           AND (driver_id IS NULL OR driver_id = ?)
         ORDER BY scheduled_at ASC LIMIT 40"
    );
    $stmt->execute(array($now, $uid));
    $data = array();
    foreach ($stmt->fetchAll() as $row) {
        $data[] = tg_ride_row_to_api($row, $pdo);
    }
    tg_json(array('data' => $data));
}

if ($method === 'GET' && $path === '/driver/rides/active') {
    $user = tg_require_user();
    $pdo = tg_db();
    $stmt = $pdo->prepare(
        'SELECT * FROM rides WHERE driver_id = ? AND status NOT IN (\'completed\',\'cancelled_by_passenger\',\'cancelled_by_driver\',\'expired\')
         ORDER BY id DESC LIMIT 1'
    );
    $stmt->execute(array($user['id']));
    $ride = $stmt->fetch();
    tg_json(array('data' => $ride ? tg_ride_row_to_api($ride, $pdo) : null));
}

if ($method === 'POST' && preg_match('#^/driver/rides/(\d+)/accept$#', $path, $m)) {
    $user = tg_require_user();
    $pdo = tg_db();
    $rideId = (int) $m[1];
    $stmt = $pdo->prepare('SELECT * FROM rides WHERE id = ?');
    $stmt->execute(array($rideId));
    $ride = $stmt->fetch();
    if (!$ride) {
        tg_json(array('message' => 'Ride not found.'), 404);
    }
    if ($ride['status'] !== 'pending' || $ride['driver_id'] !== null) {
        tg_json(array('message' => 'Ride is no longer available.'), 422);
    }
    $now = tg_now();
    $isFutureScheduled = !empty($ride['scheduled_at']) && strtotime($ride['scheduled_at']) > time();
    if ($isFutureScheduled) {
        // Reserve for this driver; trip starts when scheduled_at arrives.
        $pdo->prepare(
            'UPDATE rides SET driver_id = ?, status = \'driver_assigned\', driver_assigned_at = ?, updated_at = ? WHERE id = ? AND status = \'pending\''
        )->execute(array($user['id'], $now, $now, $rideId));
    } else {
        $pdo->prepare(
            'UPDATE rides SET driver_id = ?, status = \'driver_arriving\', driver_assigned_at = ?, updated_at = ? WHERE id = ? AND status = \'pending\''
        )->execute(array($user['id'], $now, $now, $rideId));
    }
    $stmt->execute(array($rideId));
    tg_json(array('message' => 'Ride accepted.', 'ride' => tg_ride_row_to_api($stmt->fetch(), $pdo)));
}

if ($method === 'POST' && preg_match('#^/driver/rides/(\d+)/arrived$#', $path, $m)) {
    $user = tg_require_user();
    $pdo = tg_db();
    $pdo->prepare(
        'UPDATE rides SET status = \'driver_arrived\', driver_arrived_at = ?, updated_at = ? WHERE id = ? AND driver_id = ?'
    )->execute(array(tg_now(), tg_now(), (int) $m[1], $user['id']));
    $stmt = $pdo->prepare('SELECT * FROM rides WHERE id = ?');
    $stmt->execute(array((int) $m[1]));
    tg_json(array('ride' => tg_ride_row_to_api($stmt->fetch(), $pdo)));
}

if ($method === 'POST' && preg_match('#^/driver/rides/(\d+)/start$#', $path, $m)) {
    $user = tg_require_user();
    $pdo = tg_db();
    $pdo->prepare(
        'UPDATE rides SET status = \'in_progress\', started_at = ?, updated_at = ? WHERE id = ? AND driver_id = ?'
    )->execute(array(tg_now(), tg_now(), (int) $m[1], $user['id']));
    $stmt = $pdo->prepare('SELECT * FROM rides WHERE id = ?');
    $stmt->execute(array((int) $m[1]));
    tg_json(array('ride' => tg_ride_row_to_api($stmt->fetch(), $pdo)));
}

if ($method === 'POST' && preg_match('#^/driver/rides/(\d+)/complete$#', $path, $m)) {
    $user = tg_require_user();
    $pdo = tg_db();
    $stmt = $pdo->prepare('SELECT * FROM rides WHERE id = ?');
    $stmt->execute(array((int) $m[1]));
    $ride = $stmt->fetch();
    $fare = $ride ? (float) ($ride['offered_fare'] ?: $ride['estimated_fare'] ?: 5) : 5;
    $pdo->prepare(
        'UPDATE rides SET status = \'completed\', final_fare = ?, completed_at = ?, updated_at = ? WHERE id = ? AND driver_id = ?'
    )->execute(array($fare, tg_now(), tg_now(), (int) $m[1], $user['id']));
    $stmt->execute(array((int) $m[1]));
    tg_json(array('ride' => tg_ride_row_to_api($stmt->fetch(), $pdo)));
}

if ($method === 'GET' && $path === '/driver/rides/history') {
    $user = tg_require_user();
    $pdo = tg_db();
    $stmt = $pdo->prepare(
        'SELECT * FROM rides WHERE driver_id = ? AND status = \'completed\' ORDER BY id DESC LIMIT 30'
    );
    $stmt->execute(array($user['id']));
    $data = array();
    foreach ($stmt->fetchAll() as $row) {
        $data[] = tg_ride_row_to_api($row, $pdo);
    }
    tg_json(array('data' => $data));
}

if ($method === 'GET' && $path === '/rides/active') {
    $user = tg_require_user();
    $pdo = tg_db();
    $now = tg_now();
    $stmt = $pdo->prepare(
        "SELECT * FROM rides
         WHERE passenger_id = ?
           AND status NOT IN ('completed','cancelled_by_passenger','cancelled_by_driver','expired')
           AND (scheduled_at IS NULL OR scheduled_at <= ?)
         ORDER BY id DESC LIMIT 1"
    );
    $stmt->execute(array($user['id'], $now));
    $ride = $stmt->fetch();
    tg_json(array('data' => $ride ? tg_ride_row_to_api($ride, $pdo) : null));
}

if ($method === 'GET' && $path === '/rides/history') {
    $user = tg_require_user();
    $pdo = tg_db();
    $stmt = $pdo->prepare(
        'SELECT * FROM rides WHERE passenger_id = ? ORDER BY id DESC LIMIT 30'
    );
    $stmt->execute(array($user['id']));
    $data = array();
    foreach ($stmt->fetchAll() as $row) {
        $data[] = tg_ride_row_to_api($row, $pdo);
    }
    tg_json(array('data' => $data));
}

if ($method === 'GET' && ($path === '/complaints' || $path === '/support/messages')) {
    tg_require_user();
    tg_json(array('data' => array()));
}
