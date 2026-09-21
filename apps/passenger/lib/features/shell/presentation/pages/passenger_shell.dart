import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../widgets/floating_pill_nav.dart';

class PassengerShell extends StatelessWidget {
  const PassengerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  PassengerTab get _tab => switch (navigationShell.currentIndex) {
        1 => PassengerTab.trips,
        2 => PassengerTab.account,
        _ => PassengerTab.home,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingPillNav(
              current: _tab,
              homeLabel: l10n.navHome,
              tripsLabel: l10n.navHistory,
              accountLabel: l10n.navAccount,
              onSelect: (tab) {
                final index = switch (tab) {
                  PassengerTab.home => 0,
                  PassengerTab.trips => 1,
                  PassengerTab.account => 2,
                };
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
