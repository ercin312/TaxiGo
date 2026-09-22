import 'package:flutter/material.dart';

import '../../data/admin_api.dart';
import '../../theme/admin_colors.dart';
import '../widgets/admin_section_header.dart';

class AdminDriversTab extends StatefulWidget {
  const AdminDriversTab({super.key, required this.api});

  final AdminApi api;

  @override
  State<AdminDriversTab> createState() => _AdminDriversTabState();
}

class _AdminDriversTabState extends State<AdminDriversTab> {
  final _search = TextEditingController();
  String? _status;
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  String? _error;

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
      final data = await widget.api.drivers(
        search: _search.text.trim(),
        status: _status,
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

  Future<void> _approve(int id) async {
    await widget.api.approveDriver(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sürücü onaylandı')),
    );
    await _load();
  }

  Future<void> _reject(int id) async {
    final reason = await _askReason('Red nedeni');
    if (reason == null || reason.isEmpty) return;
    await widget.api.rejectDriver(id, reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sürücü reddedildi')),
    );
    await _load();
  }

  Future<void> _ban(int id) async {
    final reason = await _askReason('Yasaklama nedeni');
    if (reason == null || reason.isEmpty) return;
    await widget.api.banDriver(id, reason);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sürücü yasaklandı')),
    );
    await _load();
  }

  Future<String?> _askReason(String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Açıklama yazın…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail(int id) async {
    final detail = await widget.api.driverDetail(id);
    if (!mounted) return;
    final driver =
        Map<String, dynamic>.from((detail['driver'] as Map?) ?? const {});
    final docs = ((detail['documents'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AdminColors.panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + MediaQuery.paddingOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AdminColors.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        AdminColors.accent.withValues(alpha: 0.25),
                    child: Text(
                      _initial('${driver['name']}'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${driver['name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${driver['phone']} · ${driver['city']}',
                          style: const TextStyle(color: AdminColors.muted),
                        ),
                      ],
                    ),
                  ),
                  AdminStatusChip(
                    label: adminStatusLabel('${driver['status']}'),
                    color: adminStatusColor('${driver['status']}'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoPill(
                    Icons.directions_car_rounded,
                    '${driver['vehicle_make']} ${driver['vehicle_model']}',
                  ),
                  _InfoPill(Icons.tag_rounded, '${driver['vehicle_plate']}'),
                  _InfoPill(Icons.star_rounded, '${driver['rating']}'),
                  _InfoPill(
                    Icons.route_rounded,
                    '${driver['completed_trips']} trip',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Belgeler',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 8),
              for (final doc in docs)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.description_rounded,
                    color: adminStatusColor('${doc['status']}'),
                  ),
                  title: Text('${doc['type']}'),
                  subtitle: Text(adminStatusLabel('${doc['status']}')),
                  trailing: doc['status'] == 'pending'
                      ? TextButton(
                          onPressed: () async {
                            await widget.api.verifyDocument(
                              id,
                              doc['id'] as int,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            await _load();
                          },
                          child: const Text('Doğrula'),
                        )
                      : null,
                ),
              const SizedBox(height: 8),
              if ('${driver['status']}' == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _approve(id);
                        },
                        child: const Text('Onayla'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _reject(id);
                        },
                        child: const Text('Reddet'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
          child: Column(
            children: [
              AdminSectionHeader(
                title: 'Sürücü yönetimi',
                subtitle: '${_rows.length} kayıt',
                action: IconButton.filledTonal(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
              const SizedBox(height: 10),
              AdminSearchField(
                controller: _search,
                hint: 'İsim, telefon veya plaka…',
                onSubmitted: (_) => _load(),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final e in [
                      (null, 'Tümü'),
                      ('approved', 'Onaylı'),
                      ('pending', 'Bekleyen'),
                      ('rejected', 'Red'),
                      ('banned', 'Yasaklı'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(e.$2),
                          selected: _status == e.$1,
                          onSelected: (_) {
                            setState(() => _status = e.$1);
                            _load();
                          },
                          selectedColor:
                              AdminColors.accent.withValues(alpha: 0.35),
                          checkmarkColor: AdminColors.ink,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _status == e.$1
                                ? AdminColors.ink
                                : AdminColors.muted,
                          ),
                        ),
                      ),
                  ],
                ),
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
                      ? const AdminEmptyState(
                          icon: Icons.local_taxi_outlined,
                          title: 'Sürücü bulunamadı',
                          message: 'Filtreleri temizleyip tekrar deneyin',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                            itemCount: _rows.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final d = _rows[i];
                              final id = d['id'] as int;
                              final status = '${d['status']}';
                              return AdminPanel(
                                onTap: () => _openDetail(id),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AdminColors.accent
                                              .withValues(alpha: 0.25),
                                          child: Text(
                                            _initial('${d['name']}'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${d['name']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              Text(
                                                '${d['phone']} · ${d['vehicle_plate']}',
                                                style: const TextStyle(
                                                  color: AdminColors.muted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        AdminStatusChip(
                                          label: adminStatusLabel(status),
                                          color: adminStatusColor(status),
                                          compact: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _Meta(Icons.star_rounded,
                                            '${d['rating']}'),
                                        const SizedBox(width: 12),
                                        _Meta(Icons.route_rounded,
                                            '${d['completed_trips']}'),
                                        const SizedBox(width: 12),
                                        _Meta(
                                            Icons.place_rounded, '${d['city']}'),
                                        if (d['is_online'] == true) ...[
                                          const SizedBox(width: 12),
                                          const _Meta(
                                            Icons.circle,
                                            'online',
                                            color: AdminColors.success,
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (status == 'pending') ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: FilledButton.tonal(
                                              onPressed: () => _approve(id),
                                              child: const Text('Onayla'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _reject(id),
                                              child: const Text('Reddet'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (status == 'approved') ...[
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          onPressed: () => _ban(id),
                                          icon: const Icon(
                                            Icons.block_rounded,
                                            size: 18,
                                          ),
                                          label: const Text('Yasakla'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AdminColors.danger,
                                          ),
                                        ),
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

  String _initial(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return t.substring(0, 1).toUpperCase();
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AdminColors.muted),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text, {this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AdminColors.muted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: c)),
      ],
    );
  }
}
