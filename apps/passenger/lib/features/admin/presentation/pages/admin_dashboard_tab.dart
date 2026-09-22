import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/admin_api.dart';
import '../../theme/admin_colors.dart';
import '../widgets/admin_section_header.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({
    super.key,
    required this.api,
    required this.onOpenTab,
  });

  final AdminApi api;
  final ValueChanged<int> onOpenTab;

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.dashboard();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int? _tabForAction(String? action) {
    return switch (action) {
      'drivers' => 1,
      'users' => 2,
      'rides' => 3,
      'modules' => 4,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = (_data?['stats'] as Map?)?.cast<String, dynamic>() ?? {};
    final recent = (_data?['recent_rides'] as List?) ?? const [];
    final alerts = (_data?['alerts'] as List?) ?? const [];
    final weekly = ((_data?['weekly_revenue'] as List?) ?? const [])
        .map((e) => (e as num).toDouble())
        .toList();
    final currency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return RefreshIndicator(
      color: AdminColors.accentDeep,
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
              child: AdminSectionHeader(
                title: 'Kontrol merkezi',
                subtitle: 'Operasyon, ciro ve canlı uyarılar',
                action: IconButton.filledTonal(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: AdminEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Veri yüklenemedi',
                message: _error,
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.02,
                ),
                delegate: SliverChildListDelegate([
                  AdminStatCard(
                    label: 'Kullanıcı',
                    value: '${stats['total_users'] ?? 0}',
                    icon: Icons.groups_rounded,
                    accent: AdminColors.info,
                    subtitle:
                        '${stats['total_passengers'] ?? 0} yolcu',
                    onTap: () => widget.onOpenTab(2),
                  ),
                  AdminStatCard(
                    label: 'Sürücü',
                    value: '${stats['total_drivers'] ?? 0}',
                    icon: Icons.local_taxi_rounded,
                    accent: AdminColors.accentDeep,
                    subtitle: '${stats['online_drivers'] ?? 0} çevrimiçi',
                    onTap: () => widget.onOpenTab(1),
                  ),
                  AdminStatCard(
                    label: 'Bekleyen onay',
                    value: '${stats['pending_drivers'] ?? 0}',
                    icon: Icons.pending_actions_rounded,
                    accent: AdminColors.warning,
                    onTap: () => widget.onOpenTab(1),
                  ),
                  AdminStatCard(
                    label: 'Aktif yolculuk',
                    value: '${stats['active_rides'] ?? 0}',
                    icon: Icons.route_rounded,
                    accent: AdminColors.success,
                    subtitle:
                        'Bugün ${stats['completed_rides_today'] ?? 0} tamam',
                    onTap: () => widget.onOpenTab(3),
                  ),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: AdminPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bugünkü ciro',
                                  style: TextStyle(
                                    color: AdminColors.muted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currency.format(
                                    (stats['revenue_today'] as num?)
                                            ?.toDouble() ??
                                        0,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AdminColors.heroGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.payments_rounded,
                              color: AdminColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Haftalık performans',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AdminSparkBars(
                        values: weekly.isEmpty
                            ? const [40, 60, 45, 80, 70, 90, 55]
                            : weekly,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (alerts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AdminSectionHeader(title: 'Akıllı uyarılar'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 108,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: alerts.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final a =
                                Map<String, dynamic>.from(alerts[i] as Map);
                            final color = switch ('${a['type']}') {
                              'warning' => AdminColors.warning,
                              'danger' => AdminColors.danger,
                              'success' => AdminColors.success,
                              _ => AdminColors.info,
                            };
                            final tab = _tabForAction(a['action']?.toString());
                            return SizedBox(
                              width: 220,
                              child: AdminPanel(
                                onTap: tab == null
                                    ? null
                                    : () => widget.onOpenTab(tab),
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.bolt_rounded, color: color),
                                    const Spacer(),
                                    Text(
                                      '${a['title']}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${a['subtitle']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AdminColors.muted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: AdminSectionHeader(
                  title: 'Son yolculuklar',
                  action: TextButton(
                    onPressed: () => widget.onOpenTab(3),
                    child: const Text('Tümü'),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
              sliver: SliverList.separated(
                itemCount: recent.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final r = Map<String, dynamic>.from(recent[i] as Map);
                  final created = DateTime.tryParse('${r['created_at']}');
                  final when = created == null
                      ? ''
                      : DateFormat('dd.MM HH:mm').format(created.toLocal());
                  final status = '${r['status']}';
                  return AdminPanel(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: adminStatusColor(status)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.directions_car_filled_rounded,
                            color: adminStatusColor(status),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['reference']?.toString() ?? '#${r['id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${r['passenger_name'] ?? '—'} → ${r['driver_name'] ?? 'atanmadı'}',
                                style: const TextStyle(
                                  color: AdminColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AdminStatusChip(
                              label: adminStatusLabel(status),
                              color: adminStatusColor(status),
                              compact: true,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              when,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AdminColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
