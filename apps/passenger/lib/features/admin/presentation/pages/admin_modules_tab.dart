import 'package:flutter/material.dart';

import '../../data/admin_api.dart';
import '../../theme/admin_colors.dart';
import '../widgets/admin_section_header.dart';
import '../widgets/admin_sos_notify_panel.dart';

class AdminModulesTab extends StatefulWidget {
  const AdminModulesTab({super.key, required this.api});

  final AdminApi api;

  @override
  State<AdminModulesTab> createState() => _AdminModulesTabState();
}

class _AdminModulesTabState extends State<AdminModulesTab> {
  Map<String, bool> _modules = {};
  bool _loading = true;

  static const _groups = <String, List<String>>{
    'Kimlik & giriş': ['otp_login', 'demo_login'],
    'Harita & ücret': ['directions_fare', 'places_autocomplete', 'bidding'],
    'Ödeme': [
      'ride_settlement',
      'withdrawals',
      'wallet_topup',
      'card_payments',
      'ride_receipts',
    ],
    'Güvenlik & iletişim': [
      'sos_alerts',
      'share_trip',
      'ride_comms',
      'fcm_dispatch',
      'rtdb_sync',
    ],
  };

  static const _labels = <String, String>{
    'otp_login': 'OTP ile giriş',
    'demo_login': 'Demo filo & taksi simülasyonu',
    'directions_fare': 'Rota / ücret hesabı',
    'places_autocomplete': 'Adres önerileri',
    'ride_settlement': 'Yolculuk tahsilatı',
    'withdrawals': 'Para çekme',
    'wallet_topup': 'Cüzdan yükleme',
    'rtdb_sync': 'Canlı konum (RTDB)',
    'fcm_dispatch': 'Push bildirimleri',
    'sos_alerts': 'SOS uyarıları',
    'share_trip': 'Yolculuk paylaşımı',
    'ride_comms': 'Yolculuk sohbeti',
    'ride_receipts': 'Makbuzlar',
    'bidding': 'Teklif / açık artırma',
    'card_payments': 'Kart ödemeleri',
  };

  static const _icons = <String, IconData>{
    'otp_login': Icons.sms_rounded,
    'demo_login': Icons.local_taxi_rounded,
    'directions_fare': Icons.alt_route_rounded,
    'places_autocomplete': Icons.place_rounded,
    'ride_settlement': Icons.receipt_long_rounded,
    'withdrawals': Icons.account_balance_wallet_rounded,
    'wallet_topup': Icons.add_card_rounded,
    'rtdb_sync': Icons.sensors_rounded,
    'fcm_dispatch': Icons.notifications_active_rounded,
    'sos_alerts': Icons.emergency_rounded,
    'share_trip': Icons.ios_share_rounded,
    'ride_comms': Icons.chat_bubble_rounded,
    'ride_receipts': Icons.description_rounded,
    'bidding': Icons.gavel_rounded,
    'card_payments': Icons.credit_card_rounded,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final mods = await widget.api.modules();
    if (!mounted) return;
    setState(() {
      _modules = mods;
      _loading = false;
    });
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => _modules[key] = value);
    await widget.api.setModule(key, value);
    if (!mounted) return;
    final demoNote = key == 'demo_login'
        ? (value
            ? ' — haritada Montenegro demo filoları aktif'
            : ' — demo filo kapandı')
        : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_labels[key] ?? key} ${value ? 'açıldı' : 'kapatıldı'}$demoNote',
        ),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Demo veriyi sıfırla?'),
        content: const Text(
          'Kullanıcı, sürücü, yolculuk ve modül ayarları başlangıç haline döner.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.api.resetDemoData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin verisi sıfırlandı')),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final enabledCount = _modules.values.where((e) => e).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
          child: AdminSectionHeader(
            title: 'Modüller',
            subtitle: '$enabledCount / ${_modules.length} aktif',
            action: TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Sıfırla'),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                  children: [
                    AdminPanel(
                      padding: const EdgeInsets.all(16),
                      child: AdminSosNotifyPanel(api: widget.api),
                    ),
                    const SizedBox(height: 14),
                    AdminPanel(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: AdminColors.accentGradient,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AdminColors.ink,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Özellik bayrakları',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Uygulama davranışını anında yönetin',
                                  style: TextStyle(
                                    color: AdminColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final group in _groups.entries) ...[
                      Text(
                        group.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AdminColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final key in group.value)
                        if (_modules.containsKey(key)) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AdminPanel(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              child: SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                secondary: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: (_modules[key] == true
                                            ? AdminColors.success
                                            : AdminColors.muted)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _icons[key] ?? Icons.extension_rounded,
                                    size: 20,
                                    color: _modules[key] == true
                                        ? AdminColors.success
                                        : AdminColors.muted,
                                  ),
                                ),
                                title: Text(
                                  _labels[key] ?? key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  key,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AdminColors.muted,
                                  ),
                                ),
                                value: _modules[key] == true,
                                activeThumbColor: AdminColors.success,
                                onChanged: (v) => _toggle(key, v),
                              ),
                            ),
                          ),
                        ],
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
