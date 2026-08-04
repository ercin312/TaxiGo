import 'dart:io';

import 'package:flutter/material.dart';

import '../api/admin_api.dart';

class DriversPage extends StatefulWidget {
  const DriversPage({super.key, required this.api});

  final AdminApi api;

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
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

  Future<void> _openDetail(int id) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _DriverDetailDialog(
        api: widget.api,
        driverId: id,
        onChanged: _load,
      ),
    );
  }

  Future<void> _approve(int id, {bool force = false}) async {
    try {
      await widget.api.approveDriver(id, force: force);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _reject(int id) async {
    final reason = await _askReason('Red sebebi');
    if (reason == null || reason.isEmpty) return;
    try {
      await widget.api.rejectDriver(id, reason);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<String?> _askReason(String title) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Sebep yazın'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
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
                'Sürücüler',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (widget.api.isSuperAdmin) ...[
                const SizedBox(width: 12),
                Chip(
                  label: const Text('Süper Admin'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.amber.shade100,
                ),
              ],
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
                value: _status,
                hint: const Text('Durum'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tümü')),
                  DropdownMenuItem(value: 'pending', child: Text('Bekleyen')),
                  DropdownMenuItem(value: 'approved', child: Text('Onaylı')),
                  DropdownMenuItem(value: 'rejected', child: Text('Red')),
                  DropdownMenuItem(value: 'banned', child: Text('Ban')),
                ],
                onChanged: (v) {
                  setState(() => _status = v);
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
                      DataColumn(label: Text('Telefon')),
                      DataColumn(label: Text('Plaka')),
                      DataColumn(label: Text('Belgeler')),
                      DataColumn(label: Text('Durum')),
                      DataColumn(label: Text('Online')),
                      DataColumn(label: Text('İşlem')),
                    ],
                    rows: [
                      for (final d in _rows)
                        DataRow(
                          cells: [
                            DataCell(Text('${d['id']}')),
                            DataCell(Text(
                              (d['user'] as Map?)?['name']?.toString() ?? '—',
                            )),
                            DataCell(Text(
                              (d['user'] as Map?)?['phone']?.toString() ?? '—',
                            )),
                            DataCell(Text(
                              (d['vehicle'] as Map?)?['plate']?.toString() ??
                                  (d['vehicle'] as Map?)?['plate_number']
                                      ?.toString() ??
                                  '—',
                            )),
                            DataCell(Text(
                              '${d['verified_documents_count'] ?? 0}/${d['documents_count'] ?? 0}',
                            )),
                            DataCell(Text('${d['approval_status'] ?? '—'}')),
                            DataCell(Text(d['is_online'] == true ? 'Evet' : 'Hayır')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => _openDetail(d['id'] as int),
                                    child: const Text('Belgeler'),
                                  ),
                                  TextButton(
                                    onPressed: () => _approve(d['id'] as int),
                                    child: const Text('Onayla'),
                                  ),
                                  if (widget.api.isSuperAdmin)
                                    TextButton(
                                      onPressed: () =>
                                          _approve(d['id'] as int, force: true),
                                      child: const Text('Zorla'),
                                    ),
                                  TextButton(
                                    onPressed: () => _reject(d['id'] as int),
                                    child: const Text('Reddet'),
                                  ),
                                ],
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

class _DriverDetailDialog extends StatefulWidget {
  const _DriverDetailDialog({
    required this.api,
    required this.driverId,
    required this.onChanged,
  });

  final AdminApi api;
  final int driverId;
  final Future<void> Function() onChanged;

  @override
  State<_DriverDetailDialog> createState() => _DriverDetailDialogState();
}

class _DriverDetailDialogState extends State<_DriverDetailDialog> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _payload;

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
      final data = await widget.api.driverDetail(widget.driverId);
      if (!mounted) return;
      setState(() {
        _payload = data;
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

  Future<void> _verify(int docId) async {
    try {
      await widget.api.verifyDocument(widget.driverId, docId);
      await _load();
      await widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _reject(int docId) async {
    final ctrl = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Belge red sebebi'),
        content: TextField(controller: ctrl, maxLines: 3, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Reddet'),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    try {
      await widget.api.rejectDocument(widget.driverId, docId, reason);
      await _load();
      await widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      await Process.start('cmd', ['/c', 'start', '', url], runInShell: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(url)));
    }
  }

  String _docLabel(String? type) {
    return switch (type) {
      'identity' => 'Kimlik Belgesi',
      'license' => 'Ehliyet',
      'registration' => 'Ruhsat / Araç Tescil',
      'vehicle_photo' => 'Araç Fotoğrafı',
      _ => type ?? 'Belge',
    };
  }

  @override
  Widget build(BuildContext context) {
    final docs = (_payload?['documents'] as List?) ?? const [];
    final review = _payload?['document_review'] as Map? ?? {};
    final driver = _payload?['driver'] as Map? ?? {};
    final user = driver['user'] as Map? ?? {};

    return AlertDialog(
      title: Text('${user['name'] ?? 'Sürücü'} — Belgeler'),
      content: SizedBox(
        width: 560,
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null
                ? Text(_error!)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yüklenen: ${review['uploaded_count'] ?? docs.length} / '
                        '${review['required_count'] ?? 4}  ·  '
                        '${review['all_verified'] == true ? 'Hepsi doğrulandı' : 'İnceleme bekliyor'}',
                      ),
                      const SizedBox(height: 12),
                      if (docs.isEmpty)
                        const Text('Henüz belge yok.')
                      else
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: docs.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final doc = Map<String, dynamic>.from(docs[i] as Map);
                              final status = doc['status']?.toString() ?? 'pending';
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(_docLabel(doc['type']?.toString())),
                                subtitle: Text(
                                  '${doc['original_name'] ?? ''} · $status'
                                  '${doc['rejection_reason'] != null ? '\n${doc['rejection_reason']}' : ''}',
                                ),
                                isThreeLine: doc['rejection_reason'] != null,
                                trailing: Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      tooltip: 'Aç',
                                      onPressed: () => _openUrl(doc['file_url']?.toString()),
                                      icon: const Icon(Icons.open_in_new),
                                    ),
                                    if (status != 'verified')
                                      IconButton(
                                        tooltip: 'Doğrula',
                                        onPressed: () => _verify(doc['id'] as int),
                                        icon: const Icon(Icons.verified, color: Colors.green),
                                      ),
                                    if (status != 'rejected')
                                      IconButton(
                                        tooltip: 'Reddet',
                                        onPressed: () => _reject(doc['id'] as int),
                                        icon: const Icon(Icons.cancel, color: Colors.orange),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}
