import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../api/admin_api.dart';

class RidesPage extends StatefulWidget {
  const RidesPage({super.key, required this.api});

  final AdminApi api;

  @override
  State<RidesPage> createState() => _RidesPageState();
}

class _RidesPageState extends State<RidesPage> {
  final _search = TextEditingController();
  String _tab = 'active';
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
                'Yolculuklar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'active', label: Text('Aktif')),
                  ButtonSegment(value: 'history', label: Text('Geçmiş')),
                ],
                selected: {_tab},
                onSelectionChanged: (s) {
                  setState(() => _tab = s.first);
                  _load();
                },
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    hintText: 'Referans…',
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _load(),
                ),
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
                      DataColumn(label: Text('Referans')),
                      DataColumn(label: Text('Yolcu')),
                      DataColumn(label: Text('Sürücü')),
                      DataColumn(label: Text('Durum')),
                      DataColumn(label: Text('Ücret')),
                      DataColumn(label: Text('Tarih')),
                    ],
                    rows: [
                      for (final r in _rows)
                        DataRow(
                          cells: [
                            DataCell(Text('${r['reference'] ?? r['id']}')),
                            DataCell(Text(
                              (r['passenger'] as Map?)?['name']?.toString() ?? '—',
                            )),
                            DataCell(Text(
                              ((r['driver'] as Map?)?['user'] as Map?)?['name']
                                      ?.toString() ??
                                  '—',
                            )),
                            DataCell(Text('${r['status'] ?? '—'}')),
                            DataCell(Text('${r['final_fare'] ?? r['offered_fare'] ?? '—'}')),
                            DataCell(Text(_fmt(r['created_at']?.toString()))),
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

  String _fmt(String? iso) {
    if (iso == null) return '—';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '—';
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }
}
