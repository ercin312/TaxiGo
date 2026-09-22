import 'package:flutter/material.dart';

import '../../data/admin_api.dart';
import '../../theme/admin_colors.dart';
import '../widgets/admin_section_header.dart';

/// Live API SOS notify channels: FCM, email, webhook.
class AdminSosNotifyPanel extends StatefulWidget {
  const AdminSosNotifyPanel({super.key, required this.api});

  final AdminApi api;

  @override
  State<AdminSosNotifyPanel> createState() => _AdminSosNotifyPanelState();
}

class _AdminSosNotifyPanelState extends State<AdminSosNotifyPanel> {
  final _emails = TextEditingController();
  final _webhook = TextEditingController();
  final _fcmKey = TextEditingController();
  final _fcmTokens = TextEditingController();
  final _mailFrom = TextEditingController();
  final _opsKey = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _notifyAdmins = true;
  bool _fcmKeySet = false;
  String? _error;
  List<Map<String, dynamic>> _alerts = const [];

  @override
  void initState() {
    super.initState();
    _opsKey.text = widget.api.opsApiKey;
    _load();
  }

  @override
  void dispose() {
    _emails.dispose();
    _webhook.dispose();
    _fcmKey.dispose();
    _fcmTokens.dispose();
    _mailFrom.dispose();
    _opsKey.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.api.setOpsApiKey(_opsKey.text);
      final settings = await widget.api.fetchSosNotifySettings();
      final alerts = await widget.api.fetchSosAlerts();
      if (!mounted) return;
      final emails = (settings['sos_admin_emails'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList() ??
          const <String>[];
      final tokens = (settings['sos_fcm_tokens'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .toList() ??
          const <String>[];
      _emails.text = emails.join(', ');
      _webhook.text = (settings['sos_webhook_url'] ?? '').toString();
      _mailFrom.text = (settings['sos_mail_from'] ?? 'noreply@alanyaproje.com')
          .toString();
      _fcmTokens.text = tokens.join('\n');
      _fcmKey.clear();
      setState(() {
        _notifyAdmins = settings['sos_notify_admins'] != false;
        _fcmKeySet = settings['sos_fcm_server_key_set'] == true;
        _alerts = alerts;
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

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.api.setOpsApiKey(_opsKey.text);
      final payload = <String, dynamic>{
        'sos_notify_admins': _notifyAdmins,
        'sos_admin_emails': _emails.text
            .split(RegExp(r'[,;\n]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'sos_webhook_url': _webhook.text.trim(),
        'sos_mail_from': _mailFrom.text.trim(),
        'sos_fcm_tokens': _fcmTokens.text
            .split(RegExp(r'[\n,]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      };
      final key = _fcmKey.text.trim();
      if (key.isNotEmpty && !key.contains('*')) {
        payload['sos_fcm_server_key'] = key;
      }
      await widget.api.saveSosNotifySettings(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SOS bildirim ayarları kaydedildi')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminSectionHeader(
          title: 'SOS bildirimleri',
          subtitle: 'FCM · e-posta · webhook (canlı API)',
        ),
        const SizedBox(height: 10),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Admin bildirimleri açık'),
            value: _notifyAdmins,
            activeThumbColor: AdminColors.accentDeep,
            onChanged: (v) => setState(() => _notifyAdmins = v),
          ),
          _field(
            controller: _emails,
            label: 'Admin e-postaları',
            hint: 'erhan@taxigo.app, ops@...',
          ),
          _field(
            controller: _mailFrom,
            label: 'Gönderen (From)',
            hint: 'noreply@alanyaproje.com',
          ),
          _field(
            controller: _webhook,
            label: 'Webhook URL',
            hint: 'https://hooks.slack.com/...',
          ),
          _field(
            controller: _fcmKey,
            label: _fcmKeySet
                ? 'FCM server key (kayıtlı — değiştirmek için yazın)'
                : 'FCM server key',
            hint: 'AAAA... Legacy Cloud Messaging key',
            obscure: true,
          ),
          _field(
            controller: _fcmTokens,
            label: 'Ek FCM cihaz tokenları',
            hint: 'Her satıra bir token',
            maxLines: 3,
          ),
          _field(
            controller: _opsKey,
            label: 'Ops API key',
            hint: AdminApi.defaultOpsKey,
            obscure: true,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : _load,
                  child: const Text('Yenile'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AdminColors.accentDeep,
                    foregroundColor: Colors.white,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kaydet'),
                ),
              ),
            ],
          ),
          if (_alerts.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              'Son SOS kayıtları (${_alerts.length})',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ..._alerts.take(8).map((a) {
              final ref = a['reference']?.toString() ?? '-';
              final lat = a['latitude'];
              final lng = a['longitude'];
              final at = a['created_at']?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '$ref · $lat,$lng · $at',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withValues(alpha: 0.65),
                  ),
                ),
              );
            }),
          ],
        ],
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure && maxLines == 1,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
        ),
      ),
    );
  }
}
