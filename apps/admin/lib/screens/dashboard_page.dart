import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../admin_theme.dart';
import '../api/admin_api.dart';
import '../widgets/stat_tile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.api});

  final AdminApi api;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

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

  @override
  Widget build(BuildContext context) {
    final stats = (_data?['stats'] as Map?)?.cast<String, dynamic>() ?? {};
    final recent = (_data?['recent_rides'] as List?) ?? const [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Özet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!)))
          else ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatTile(label: 'Kullanıcı', value: '${stats['total_users'] ?? 0}'),
                StatTile(label: 'Yolcu', value: '${stats['total_passengers'] ?? 0}'),
                StatTile(label: 'Sürücü', value: '${stats['total_drivers'] ?? 0}'),
                StatTile(
                  label: 'Bekleyen onay',
                  value: '${stats['pending_drivers'] ?? 0}',
                  highlight: (stats['pending_drivers'] as num?)?.toInt() != 0,
                ),
                StatTile(label: 'Çevrimiçi', value: '${stats['online_drivers'] ?? 0}'),
                StatTile(label: 'Aktif yolculuk', value: '${stats['active_rides'] ?? 0}'),
                StatTile(
                  label: 'Bugün tamamlanan',
                  value: '${stats['completed_rides_today'] ?? 0}',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Son yolculuklar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ListView.separated(
                  itemCount: recent.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = Map<String, dynamic>.from(recent[i] as Map);
                    final created = r['created_at']?.toString();
                    String when = '';
                    if (created != null) {
                      final dt = DateTime.tryParse(created)?.toLocal();
                      if (dt != null) {
                        when = DateFormat('dd.MM HH:mm').format(dt);
                      }
                    }
                    return ListTile(
                      title: Text(r['reference']?.toString() ?? '#${r['id']}'),
                      subtitle: Text(
                        '${r['passenger_name'] ?? '—'} → ${r['driver_name'] ?? 'atanmadı'}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            r['status']?.toString() ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AdminTheme.ink,
                            ),
                          ),
                          Text(when, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
