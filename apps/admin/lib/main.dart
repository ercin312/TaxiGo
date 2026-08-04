import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'admin_theme.dart';
import 'api/admin_api.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: Size(1360, 860),
    minimumSize: Size(1024, 700),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'TaxiGo Admin',
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final prefs = await SharedPreferences.getInstance();
  final api = AdminApi(prefs);
  runApp(TaxigoAdminApp(api: api));
}

class TaxigoAdminApp extends StatelessWidget {
  const TaxigoAdminApp({super.key, required this.api});

  final AdminApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaxiGo Admin',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.light,
      home: AuthGate(api: api),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.api});

  final AdminApi api;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final ok = await widget.api.restoreSession();
    if (!mounted) return;
    setState(() {
      _authed = ok;
      _loading = false;
    });
  }

  void _onLoggedIn() => setState(() => _authed = true);

  Future<void> _onLogout() async {
    await widget.api.logout();
    if (!mounted) return;
    setState(() => _authed = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_authed) {
      return LoginScreen(api: widget.api, onSuccess: _onLoggedIn);
    }
    return ShellScreen(api: widget.api, onLogout: _onLogout);
  }
}
