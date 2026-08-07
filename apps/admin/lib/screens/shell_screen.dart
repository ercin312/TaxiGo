import 'package:flutter/material.dart';

import '../admin_theme.dart';
import '../api/admin_api.dart';
import 'dashboard_page.dart';
import 'drivers_page.dart';
import 'rides_page.dart';
import 'users_page.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.api,
    required this.onLogout,
  });

  final AdminApi api;
  final Future<void> Function() onLogout;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(api: widget.api),
      DriversPage(api: widget.api),
      UsersPage(api: widget.api),
      RidesPage(api: widget.api),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: AdminTheme.rail,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            extended: true,
            minExtendedWidth: 200,
            selectedIconTheme: const IconThemeData(color: AdminTheme.accent),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(
              color: AdminTheme.accent,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/taxigo_logo.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TaxiGo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    widget.api.adminName ?? 'Admin',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  if (widget.api.isSuperAdmin)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Süper Admin',
                        style: TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextButton.icon(
                    onPressed: () async => widget.onLogout(),
                    icon: const Icon(Icons.logout, color: Colors.white70),
                    label: const Text(
                      'Çıkış',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Özet'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_taxi_outlined),
                selectedIcon: Icon(Icons.local_taxi),
                label: Text('Sürücüler'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Kullanıcılar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.route_outlined),
                selectedIcon: Icon(Icons.route),
                label: Text('Yolculuklar'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: pages[_index]),
        ],
      ),
    );
  }
}
