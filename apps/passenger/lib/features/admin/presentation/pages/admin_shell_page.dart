import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../data/admin_api.dart';
import '../../theme/admin_colors.dart';
import 'admin_dashboard_tab.dart';
import 'admin_drivers_tab.dart';
import 'admin_modules_tab.dart';
import 'admin_rides_tab.dart';
import 'admin_users_tab.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage>
    with SingleTickerProviderStateMixin {
  late final AdminApi _api;
  late final AnimationController _pulse;
  int _index = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _api = AdminApi(passengerGetIt<SharedPreferences>());
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _bootstrap();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final user = context.read<AuthBloc>().state.user;
    await _api.bootstrap(name: user?.name, email: user?.email);
    if (!mounted) return;
    setState(() => _ready = true);
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış yapılsın mı?'),
        content: const Text('Süper Admin oturumu kapatılacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Çıkış'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    if (mounted) context.go('/login');
  }

  void _goTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      AdminDashboardTab(api: _api, onOpenTab: _goTab),
      AdminDriversTab(api: _api),
      AdminUsersTab(api: _api),
      AdminRidesTab(api: _api),
      AdminModulesTab(api: _api),
    ];

    return Theme(
      data: AdminColors.theme(context),
      child: Scaffold(
        backgroundColor: AdminColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _AdminHeroHeader(
                name: _api.adminName ?? 'Erhan',
                email: _api.adminEmail ?? 'erhan@taxigo.app',
                pulse: _pulse,
                onLogout: _logout,
              ),
              Expanded(
                child: !_ready
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AdminColors.accentDeep,
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: KeyedSubtree(
                          key: ValueKey(_index),
                          child: pages[_index],
                        ),
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.space_dashboard_outlined),
              selectedIcon: Icon(Icons.space_dashboard_rounded),
              label: 'Özet',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_taxi_outlined),
              selectedIcon: Icon(Icons.local_taxi_rounded),
              label: 'Sürücü',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined),
              selectedIcon: Icon(Icons.groups_rounded),
              label: 'Kullanıcı',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded),
              label: 'Yolculuk',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune_rounded),
              label: 'Modül',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeroHeader extends StatelessWidget {
  const _AdminHeroHeader({
    required this.name,
    required this.email,
    required this.pulse,
    required this.onLogout,
  });

  final String name;
  final String email;
  final AnimationController pulse;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
      decoration: BoxDecoration(
        gradient: AdminColors.heroGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AdminColors.ink.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: AdminColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.shield_moon_rounded,
              color: AdminColors.ink,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'TaxiGo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AdminColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AdminColors.accent.withValues(alpha: 0.45),
                        ),
                      ),
                      child: const Text(
                        'SÜPER ADMIN',
                        style: TextStyle(
                          color: AdminColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$name · $email',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FadeTransition(
                      opacity: Tween(begin: 0.45, end: 1.0).animate(pulse),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AdminColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Sistem çevrimiçi',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogout,
            tooltip: 'Çıkış',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
            ),
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
