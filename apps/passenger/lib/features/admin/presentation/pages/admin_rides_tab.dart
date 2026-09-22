import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/admin_api.dart';
import '../../theme/admin_colors.dart';
import '../widgets/admin_section_header.dart';

class AdminRidesTab extends StatefulWidget {
  const AdminRidesTab({super.key, required this.api});

  final AdminApi api;

  @override
  State<AdminRidesTab> createState() => _AdminRidesTabState();
}

class _AdminRidesTabState extends State<AdminRidesTab> {
  final _search = TextEditingController();
  String _tab = 'active';
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;

  static const _active = {
    'pending',
    'driver_assigned',
    'driver_arriving',
    'driver_arrived',
    'passenger_on_board',
    'in_progress',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.api.rides(
        search: _search.text.trim(),
        tab: _tab,
      );
      final list = (data['data'] as List?) ?? const [];
      if (!mounted) return;
      setState(() {
        _rows = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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

  Future<void> _complete(int id) async {
    await widget.api.completeRide(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yolculuk tamamlandı')),
    );
    await _load();
  }

  Future<void> _cancel(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yolculuğu iptal et?'),
        content: const Text('Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('İptal et'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.api.cancelRide(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yolculuk iptal edildi')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
          child: Column(
            children: [
              AdminSectionHeader(
                title: 'Yolculuklar',
                subtitle: '${_rows.length} kayıt',
                action: IconButton.filledTonal(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'active',
                    label: Text('Aktif'),
                    icon: Icon(Icons.bolt_rounded, size: 16),
                  ),
                  ButtonSegment(
                    value: 'history',
                    label: Text('Geçmiş'),
                    icon: Icon(Icons.history_rounded, size: 16),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (s) {
                  setState(() => _tab = s.first);
                  _load();
                },
              ),
              const SizedBox(height: 10),
              AdminSearchField(
                controller: _search,
                hint: 'Referans veya isim…',
                onSubmitted: (_) => _load(),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? AdminEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Yüklenemedi',
                      message: _error,
                    )
                  : _rows.isEmpty
                      ? AdminEmptyState(
                          icon: Icons.map_outlined,
                          title: _tab == 'active'
                              ? 'Aktif yolculuk yok'
                              : 'Geçmiş boş',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                            itemCount: _rows.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final r = _rows[i];
                              final id = r['id'] as int;
                              final status = '${r['status']}';
                              final created =
                                  DateTime.tryParse('${r['created_at']}');
                              final when = created == null
                                  ? ''
                                  : DateFormat('dd.MM.yyyy HH:mm')
                                      .format(created.toLocal());
                              final fare =
                                  (r['fare'] as num?)?.toDouble() ?? 0;
                              final isActive = _active.contains(status);
                              return AdminPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${r['reference']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        AdminStatusChip(
                                          label: adminStatusLabel(status),
                                          color: adminStatusColor(status),
                                          compact: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.trip_origin_rounded,
                                          size: 16,
                                          color: AdminColors.success,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${r['pickup_address']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.flag_rounded,
                                          size: 16,
                                          color: AdminColors.danger,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${r['dropoff_address']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${r['passenger_name'] ?? '—'} · ${r['driver_name'] ?? 'atanmadı'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AdminColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          money.format(fare),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          when,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AdminColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: FilledButton.tonal(
                                              onPressed: () => _complete(id),
                                              child: const Text('Tamamla'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _cancel(id),
                                              child: const Text('İptal'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}
