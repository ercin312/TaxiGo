import 'package:flutter/material.dart';

import '../../data/admin_api.dart';
import '../../theme/admin_colors.dart';
import '../widgets/admin_section_header.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key, required this.api});

  final AdminApi api;

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final _search = TextEditingController();
  String? _role;
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
      final data = await widget.api.users(
        search: _search.text.trim(),
        role: _role,
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

  Future<void> _toggle(Map<String, dynamic> user) async {
    final id = user['id'] as int;
    final active = user['is_active'] == true;
    await widget.api.setUserActive(id, !active);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(active ? 'Hesap pasife alındı' : 'Hesap aktifleştirildi'),
      ),
    );
    await _load();
  }

  IconData _roleIcon(String role) {
    return switch (role) {
      'driver' => Icons.local_taxi_rounded,
      'admin' => Icons.shield_rounded,
      _ => Icons.person_rounded,
    };
  }

  Color _roleColor(String role) {
    return switch (role) {
      'driver' => AdminColors.accentDeep,
      'admin' => AdminColors.violet,
      _ => AdminColors.info,
    };
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
                title: 'Kullanıcılar',
                subtitle: '${_rows.length} hesap',
                action: IconButton.filledTonal(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
              const SizedBox(height: 10),
              AdminSearchField(
                controller: _search,
                hint: 'İsim, e-posta veya telefon…',
                onSubmitted: (_) => _load(),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final entry in [
                      (null, 'Tümü'),
                      ('passenger', 'Yolcu'),
                      ('driver', 'Sürücü'),
                      ('admin', 'Admin'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(entry.$2),
                          selected: _role == entry.$1,
                          onSelected: (_) {
                            setState(() => _role = entry.$1);
                            _load();
                          },
                          selectedColor:
                              AdminColors.accent.withValues(alpha: 0.35),
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
                          icon: Icons.groups_outlined,
                          title: 'Kullanıcı yok',
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                            itemCount: _rows.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final u = _rows[i];
                              final active = u['is_active'] == true;
                              final role = '${u['role']}';
                              final color = _roleColor(role);
                              return AdminPanel(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _roleIcon(role),
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${u['name']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            [
                                              if (u['phone'] != null)
                                                '${u['phone']}',
                                              if (u['email'] != null)
                                                '${u['email']}',
                                            ].join(' · '),
                                            style: const TextStyle(
                                              color: AdminColors.muted,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          AdminStatusChip(
                                            label: role,
                                            color: color,
                                            compact: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Switch.adaptive(
                                          value: active,
                                          activeThumbColor: AdminColors.success,
                                          onChanged: role == 'admin'
                                              ? null
                                              : (_) => _toggle(u),
                                        ),
                                        Text(
                                          active ? 'Aktif' : 'Pasif',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: active
                                                ? AdminColors.success
                                                : AdminColors.muted,
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
        ),
      ],
    );
  }
}
