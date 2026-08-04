import 'package:flutter/material.dart';

import '../api/admin_api.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.api});

  final AdminApi api;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
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

  Future<void> _toggleActive(Map<String, dynamic> user) async {
    final id = user['id'] as int;
    final active = user['is_active'] == true;
    try {
      await widget.api.setUserActive(id, !active);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Kullanıcılar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    hintText: 'Ara…',
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _load(),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: _role,
                hint: const Text('Rol'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tümü')),
                  DropdownMenuItem(value: 'passenger', child: Text('Yolcu')),
                  DropdownMenuItem(value: 'driver', child: Text('Sürücü')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) {
                  setState(() => _role = v);
                  _load();
                },
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(child: Center(child: Text(_error!)))
          else
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Ad')),
                      DataColumn(label: Text('E-posta')),
                      DataColumn(label: Text('Telefon')),
                      DataColumn(label: Text('Rol')),
                      DataColumn(label: Text('Aktif')),
                      DataColumn(label: Text('İşlem')),
                    ],
                    rows: [
                      for (final u in _rows)
                        DataRow(
                          cells: [
                            DataCell(Text('${u['id']}')),
                            DataCell(Text('${u['name'] ?? '—'}')),
                            DataCell(Text('${u['email'] ?? '—'}')),
                            DataCell(Text('${u['phone'] ?? '—'}')),
                            DataCell(Text('${u['role'] ?? '—'}')),
                            DataCell(Text(u['is_active'] == true ? 'Evet' : 'Hayır')),
                            DataCell(
                              TextButton(
                                onPressed: () => _toggleActive(u),
                                child: Text(
                                  u['is_active'] == true ? 'Pasifleştir' : 'Aktifleştir',
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
