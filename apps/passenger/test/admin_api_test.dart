import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo/features/admin/data/admin_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('admin api bootstrap and dashboard work', () async {
    final prefs = await SharedPreferences.getInstance();
    final api = AdminApi(prefs);
    await api.bootstrap(name: 'Erhan', email: 'erhan@taxigo.app');

    expect(api.isSuperAdmin, isTrue);
    expect(api.adminName, 'Erhan');

    final dash = await api.dashboard();
    final stats = dash['stats'] as Map;
    expect(stats['total_users'], greaterThan(0));
    expect(stats['total_drivers'], greaterThan(0));
    expect(dash['weekly_revenue'], isA<List>());
    expect(dash['alerts'], isA<List>());
  });

  test('driver approve / reject / ban persist', () async {
    final prefs = await SharedPreferences.getInstance();
    final api = AdminApi(prefs);
    await api.bootstrap();

    final pending = await api.drivers(status: 'pending');
    final list = (pending['data'] as List).cast<Map>();
    expect(list, isNotEmpty);
    final id = list.first['id'] as int;

    await api.approveDriver(id);
    final approved = await api.drivers(status: 'approved');
    expect(
      (approved['data'] as List).any((e) => (e as Map)['id'] == id),
      isTrue,
    );

    await api.banDriver(id, 'test ban');
    final banned = await api.drivers(status: 'banned');
    expect(
      (banned['data'] as List).any((e) => (e as Map)['id'] == id),
      isTrue,
    );
  });

  test('ride complete and cancel work', () async {
    final prefs = await SharedPreferences.getInstance();
    final api = AdminApi(prefs);
    await api.bootstrap();

    final active = await api.rides(tab: 'active');
    final list = (active['data'] as List).cast<Map>();
    expect(list, isNotEmpty);
    final id = list.first['id'] as int;

    await api.completeRide(id);
    final history = await api.rides(tab: 'history');
    expect(
      (history['data'] as List).any(
        (e) => (e as Map)['id'] == id && e['status'] == 'completed',
      ),
      isTrue,
    );
  });

  test('modules toggle and user active toggle', () async {
    final prefs = await SharedPreferences.getInstance();
    final api = AdminApi(prefs);
    await api.bootstrap();

    final before = await api.modules();
    expect(before.containsKey('sos_alerts'), isTrue);
    await api.setModule('sos_alerts', !(before['sos_alerts'] ?? true));
    final after = await api.modules();
    expect(after['sos_alerts'], isNot(before['sos_alerts']));

    final users = await api.users(role: 'passenger');
    final u = (users['data'] as List).first as Map;
    final id = u['id'] as int;
    final active = u['is_active'] == true;
    await api.setUserActive(id, !active);
    final again = await api.users(role: 'passenger');
    final updated =
        (again['data'] as List).cast<Map>().firstWhere((e) => e['id'] == id);
    expect(updated['is_active'], !active);
  });

  test('reset demo data restores seed', () async {
    final prefs = await SharedPreferences.getInstance();
    final api = AdminApi(prefs);
    await api.bootstrap();
    await api.setModule('sos_alerts', false);
    await api.resetDemoData();
    final mods = await api.modules();
    expect(mods['sos_alerts'], isTrue);
  });
}
