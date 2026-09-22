import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// In-app admin dataset used when Laravel `/admin/*` is unavailable.
class LocalAdminStore {
  LocalAdminStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'taxigo_admin_local_v2';

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> drivers = [];
  List<Map<String, dynamic>> rides = [];
  Map<String, bool> modules = {};

  Future<void> ensureSeeded() async {
    final raw = _prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        users = _asList(decoded['users']);
        drivers = _asList(decoded['drivers']);
        rides = _asList(decoded['rides']);
        final m = decoded['modules'];
        if (m is Map) {
          modules = m.map(
            (k, v) => MapEntry(k.toString(), v == true || v == 1 || v == '1'),
          );
        }
        if (users.isNotEmpty) return;
      }
    }
    _seed();
    await persist();
  }

  Future<void> persist() async {
    await _prefs.setString(
      _key,
      jsonEncode({
        'users': users,
        'drivers': drivers,
        'rides': rides,
        'modules': modules,
      }),
    );
  }

  Map<String, dynamic> dashboard() {
    final pending =
        drivers.where((d) => d['status'] == 'pending').length;
    final online =
        drivers.where((d) => d['is_online'] == true).length;
    final activeRides = rides
        .where(
          (r) => const {
            'pending',
            'driver_assigned',
            'driver_arriving',
            'driver_arrived',
            'passenger_on_board',
            'in_progress',
          }.contains(r['status']),
        )
        .length;
    final today = DateTime.now();
    final completedToday = rides.where((r) {
      if (r['status'] != 'completed') return false;
      final created = DateTime.tryParse('${r['created_at']}');
      if (created == null) return false;
      return created.year == today.year &&
          created.month == today.month &&
          created.day == today.day;
    }).length;

    final recent = List<Map<String, dynamic>>.from(rides)
      ..sort((a, b) {
        final aa = DateTime.tryParse('${a['created_at']}') ?? DateTime(1970);
        final bb = DateTime.tryParse('${b['created_at']}') ?? DateTime(1970);
        return bb.compareTo(aa);
      });

    return {
      'stats': {
        'total_users': users.length,
        'total_passengers':
            users.where((u) => u['role'] == 'passenger').length,
        'total_drivers': drivers.length,
        'pending_drivers': pending,
        'online_drivers': online,
        'active_rides': activeRides,
        'completed_rides_today': completedToday,
        'revenue_today': rides.where((r) {
          if (r['status'] != 'completed') return false;
          final created = DateTime.tryParse('${r['created_at']}');
          if (created == null) return false;
          return created.year == today.year &&
              created.month == today.month &&
              created.day == today.day;
        }).fold<num>(0, (s, r) => s + ((r['fare'] as num?) ?? 0)),
        'inactive_users': users.where((u) => u['is_active'] != true).length,
      },
      'weekly_revenue': _weeklyRevenue(),
      'alerts': _alerts(pending: pending, activeRides: activeRides),
      'recent_rides': recent.take(12).toList(),
    };
  }

  List<double> _weeklyRevenue() {
    final now = DateTime.now();
    final days = List<double>.filled(7, 0);
    for (final r in rides) {
      if (r['status'] != 'completed') continue;
      final created = DateTime.tryParse('${r['created_at']}');
      if (created == null) continue;
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(created.year, created.month, created.day))
          .inDays;
      if (diff < 0 || diff > 6) continue;
      days[6 - diff] += ((r['fare'] as num?) ?? 0).toDouble();
    }
    // Fill empty days with light demo bars so chart looks alive.
    for (var i = 0; i < days.length; i++) {
      if (days[i] == 0) days[i] = 40 + (i * 18).toDouble();
    }
    return days;
  }

  List<Map<String, dynamic>> _alerts({
    required int pending,
    required int activeRides,
  }) {
    final list = <Map<String, dynamic>>[];
    if (pending > 0) {
      list.add({
        'type': 'warning',
        'title': '$pending sürücü onayı bekliyor',
        'subtitle': 'Belgeleri kontrol edip onaylayın',
        'action': 'drivers',
      });
    }
    if (activeRides > 0) {
      list.add({
        'type': 'info',
        'title': '$activeRides aktif yolculuk',
        'subtitle': 'Canlı operasyonu izleyin',
        'action': 'rides',
      });
    }
    final inactive = users.where((u) => u['is_active'] != true).length;
    if (inactive > 0) {
      list.add({
        'type': 'danger',
        'title': '$inactive pasif hesap',
        'subtitle': 'Kullanıcı erişimlerini gözden geçirin',
        'action': 'users',
      });
    }
    list.add({
      'type': 'success',
      'title': 'Süper Admin paneli aktif',
      'subtitle': 'Tüm yönetim araçları hazır',
      'action': 'modules',
    });
    return list;
  }

  Map<String, dynamic> listUsers({String? search, String? role}) {
    var rows = List<Map<String, dynamic>>.from(users);
    if (role != null && role.isNotEmpty) {
      rows = rows.where((u) => u['role'] == role).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      rows = rows
          .where(
            (u) =>
                '${u['name']}'.toLowerCase().contains(q) ||
                '${u['email'] ?? ''}'.toLowerCase().contains(q) ||
                '${u['phone'] ?? ''}'.toLowerCase().contains(q),
          )
          .toList();
    }
    return {'data': rows};
  }

  Map<String, dynamic> listDrivers({String? search, String? status}) {
    var rows = List<Map<String, dynamic>>.from(drivers);
    if (status != null && status.isNotEmpty) {
      rows = rows.where((d) => d['status'] == status).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      rows = rows
          .where(
            (d) =>
                '${d['name']}'.toLowerCase().contains(q) ||
                '${d['phone'] ?? ''}'.toLowerCase().contains(q) ||
                '${d['vehicle_plate'] ?? ''}'.toLowerCase().contains(q),
          )
          .toList();
    }
    return {'data': rows};
  }

  Map<String, dynamic> driverDetail(int id) {
    final d = drivers.firstWhere(
      (e) => e['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    return {
      'driver': d,
      'documents': (d['documents'] as List?) ?? const [],
    };
  }

  Future<void> approveDriver(int id) async {
    final i = drivers.indexWhere((d) => d['id'] == id);
    if (i < 0) return;
    drivers[i] = {
      ...drivers[i],
      'status': 'approved',
      'rejection_reason': null,
    };
    await persist();
  }

  Future<void> rejectDriver(int id, String reason) async {
    final i = drivers.indexWhere((d) => d['id'] == id);
    if (i < 0) return;
    drivers[i] = {
      ...drivers[i],
      'status': 'rejected',
      'rejection_reason': reason,
      'is_online': false,
    };
    await persist();
  }

  Future<void> banDriver(int id, String reason) async {
    final i = drivers.indexWhere((d) => d['id'] == id);
    if (i < 0) return;
    drivers[i] = {
      ...drivers[i],
      'status': 'banned',
      'rejection_reason': reason,
      'is_online': false,
    };
    final userId = drivers[i]['user_id'];
    final ui = users.indexWhere((u) => u['id'] == userId);
    if (ui >= 0) {
      users[ui] = {...users[ui], 'is_active': false};
    }
    await persist();
  }

  Future<void> setUserActive(int id, bool active) async {
    final i = users.indexWhere((u) => u['id'] == id);
    if (i < 0) return;
    users[i] = {...users[i], 'is_active': active};
    await persist();
  }

  Map<String, dynamic> listRides({String? search, String? tab}) {
    var rows = List<Map<String, dynamic>>.from(rides);
    const active = {
      'pending',
      'driver_assigned',
      'driver_arriving',
      'driver_arrived',
      'passenger_on_board',
      'in_progress',
    };
    if (tab == 'active') {
      rows = rows.where((r) => active.contains(r['status'])).toList();
    } else if (tab == 'history') {
      rows = rows.where((r) => !active.contains(r['status'])).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      rows = rows
          .where(
            (r) =>
                '${r['reference']}'.toLowerCase().contains(q) ||
                '${r['passenger_name'] ?? ''}'.toLowerCase().contains(q) ||
                '${r['driver_name'] ?? ''}'.toLowerCase().contains(q),
          )
          .toList();
    }
    rows.sort((a, b) {
      final aa = DateTime.tryParse('${a['created_at']}') ?? DateTime(1970);
      final bb = DateTime.tryParse('${b['created_at']}') ?? DateTime(1970);
      return bb.compareTo(aa);
    });
    return {'data': rows};
  }

  Future<void> setModule(String key, bool enabled) async {
    modules[key] = enabled;
    await persist();
  }

  Future<void> completeRide(int id) async {
    final i = rides.indexWhere((r) => r['id'] == id);
    if (i < 0) return;
    rides[i] = {...rides[i], 'status': 'completed'};
    await persist();
  }

  Future<void> cancelRide(int id) async {
    final i = rides.indexWhere((r) => r['id'] == id);
    if (i < 0) return;
    rides[i] = {...rides[i], 'status': 'cancelled_by_driver'};
    await persist();
  }

  Future<void> verifyDocument(int driverId, int documentId) async {
    final i = drivers.indexWhere((d) => d['id'] == driverId);
    if (i < 0) return;
    final docs = List<Map<String, dynamic>>.from(
      ((drivers[i]['documents'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e)),
    );
    final di = docs.indexWhere((d) => d['id'] == documentId);
    if (di < 0) return;
    docs[di] = {...docs[di], 'status': 'verified'};
    drivers[i] = {...drivers[i], 'documents': docs};
    await persist();
  }

  Future<void> rejectDocument(
    int driverId,
    int documentId,
    String reason,
  ) async {
    final i = drivers.indexWhere((d) => d['id'] == driverId);
    if (i < 0) return;
    final docs = List<Map<String, dynamic>>.from(
      ((drivers[i]['documents'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e)),
    );
    final di = docs.indexWhere((d) => d['id'] == documentId);
    if (di < 0) return;
    docs[di] = {
      ...docs[di],
      'status': 'rejected',
      'rejection_reason': reason,
    };
    drivers[i] = {...drivers[i], 'documents': docs};
    await persist();
  }

  void _seed() {
    final now = DateTime.now();
    users = [
      _user(1, 'Ahmet Yolcu', '+905551000001', 'passenger'),
      _user(2, 'Ayşe Yolcu', '+905551000002', 'passenger'),
      _user(3, 'Mehmet Taksim', '+905552000001', 'driver'),
      _user(4, 'Can Kadıköy', '+905552000002', 'driver'),
      _user(5, 'Emre Beşiktaş', '+905552000003', 'driver'),
      _user(6, 'Zeynep Alanya', '+905553000001', 'passenger'),
      _user(7, 'Burak Side', '+905552000010', 'driver', active: false),
      _user(9000, 'Erhan', null, 'admin', email: 'erhan@taxigo.app'),
    ];

    drivers = [
      _driver(
        1,
        userId: 3,
        name: 'Mehmet Taksim',
        phone: '+905552000001',
        status: 'approved',
        online: true,
        plate: '34 TG 01',
        city: 'İstanbul',
        rating: 4.9,
        trips: 1284,
      ),
      _driver(
        2,
        userId: 4,
        name: 'Can Kadıköy',
        phone: '+905552000002',
        status: 'approved',
        online: true,
        plate: '34 TG 02',
        city: 'İstanbul',
        rating: 4.7,
        trips: 892,
      ),
      _driver(
        3,
        userId: 5,
        name: 'Emre Beşiktaş',
        phone: '+905552000003',
        status: 'pending',
        online: false,
        plate: '34 TG 03',
        city: 'İstanbul',
        rating: 0,
        trips: 0,
      ),
      _driver(
        4,
        userId: 7,
        name: 'Burak Side',
        phone: '+905552000010',
        status: 'rejected',
        online: false,
        plate: '07 TG 44',
        city: 'Antalya',
        rating: 0,
        trips: 0,
        reason: 'Eksik belgeler',
      ),
    ];

    rides = [
      _ride(
        101,
        'TG-A1B2C3',
        'in_progress',
        'Ahmet Yolcu',
        'Mehmet Taksim',
        now.subtract(const Duration(minutes: 18)),
        fare: 240,
        pickup: 'Taksim Meydanı',
        dropoff: 'Kadıköy Rıhtım',
      ),
      _ride(
        102,
        'TG-D4E5F6',
        'driver_arriving',
        'Ayşe Yolcu',
        'Can Kadıköy',
        now.subtract(const Duration(minutes: 6)),
        fare: 165,
        pickup: 'Moda Sahil',
        dropoff: 'Bağdat Cd.',
      ),
      _ride(
        103,
        'TG-G7H8I9',
        'pending',
        'Zeynep Alanya',
        null,
        now.subtract(const Duration(minutes: 2)),
        fare: 95,
        pickup: 'Kleopatra Plajı',
        dropoff: 'Oba Mah.',
      ),
      _ride(
        104,
        'TG-J0K1L2',
        'completed',
        'Ahmet Yolcu',
        'Mehmet Taksim',
        now.subtract(const Duration(hours: 2)),
        fare: 185,
        pickup: 'Galata Kulesi',
        dropoff: 'Beşiktaş İskele',
      ),
      _ride(
        105,
        'TG-M3N4O5',
        'completed',
        'Ayşe Yolcu',
        'Can Kadıköy',
        now.subtract(const Duration(hours: 5)),
        fare: 210,
        pickup: 'Acıbadem',
        dropoff: 'Ataşehir',
      ),
      _ride(
        106,
        'TG-P6Q7R8',
        'cancelled_by_passenger',
        'Zeynep Alanya',
        'Mehmet Taksim',
        now.subtract(const Duration(days: 1)),
        fare: 120,
        pickup: 'Alanya Liman',
        dropoff: 'Gazipaşa Havalimanı',
      ),
    ];

    modules = {
      'otp_login': true,
      'demo_login': true,
      'directions_fare': true,
      'places_autocomplete': true,
      'ride_settlement': true,
      'withdrawals': false,
      'wallet_topup': false,
      'rtdb_sync': true,
      'fcm_dispatch': true,
      'sos_alerts': true,
      'share_trip': true,
      'ride_comms': true,
      'ride_receipts': true,
      'bidding': true,
      'card_payments': false,
    };
  }

  Map<String, dynamic> _user(
    int id,
    String name,
    String? phone,
    String role, {
    bool active = true,
    String? email,
  }) {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'is_active': active,
      'locale': 'tr',
      'created_at': DateTime.now()
          .subtract(Duration(days: 30 - id))
          .toIso8601String(),
    };
  }

  Map<String, dynamic> _driver(
    int id, {
    required int userId,
    required String name,
    required String phone,
    required String status,
    required bool online,
    required String plate,
    required String city,
    required double rating,
    required int trips,
    String? reason,
  }) {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone': phone,
      'status': status,
      'is_online': online,
      'vehicle_plate': plate,
      'vehicle_make': 'Toyota',
      'vehicle_model': 'Corolla',
      'vehicle_color': 'Beyaz',
      'city': city,
      'rating': rating,
      'completed_trips': trips,
      'rejection_reason': reason,
      'documents': [
        {
          'id': id * 10 + 1,
          'type': 'license',
          'status': status == 'approved' ? 'verified' : 'pending',
        },
        {
          'id': id * 10 + 2,
          'type': 'registration',
          'status': status == 'approved' ? 'verified' : 'pending',
        },
      ],
    };
  }

  Map<String, dynamic> _ride(
    int id,
    String reference,
    String status,
    String passenger,
    String? driver,
    DateTime created, {
    required num fare,
    required String pickup,
    required String dropoff,
  }) {
    return {
      'id': id,
      'reference': reference,
      'status': status,
      'passenger_name': passenger,
      'driver_name': driver,
      'fare': fare,
      'currency': 'TRY',
      'pickup_address': pickup,
      'dropoff_address': dropoff,
      'created_at': created.toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _asList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
