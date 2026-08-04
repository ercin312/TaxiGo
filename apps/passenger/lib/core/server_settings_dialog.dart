import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../di/locator.dart';

/// Lets users point the app at their backend when testing on a real device.
Future<void> showServerSettingsDialog(BuildContext context) async {
  final prefs = passengerGetIt<SharedPreferences>();
  final apiClient = passengerGetIt<ApiClient>();
  final controller = TextEditingController(
    text: apiClient.dio.options.baseUrl,
  );
  String? testMessage;
  bool? testOk;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> testConnection() async {
            final apiUrl = ApiConfig.normalizeUrl(controller.text.trim());
            final root = ApiConfig.serverRootFromApiUrl(apiUrl);
            setState(() {
              testMessage = 'Bağlantı test ediliyor...';
              testOk = null;
            });
            try {
              final client = passengerGetIt<ApiClient>();
              final response = await client.dio.get<String>('$root/up');
              setState(() {
                testOk = response.statusCode == 200;
                testMessage = testOk!
                    ? 'Bağlantı başarılı: $root'
                    : 'Sunucu yanıt verdi ama beklenmeyen durum kodu.';
              });
            } catch (e) {
              setState(() {
                testOk = false;
                testMessage =
                    'Bağlantı başarısız. Backend\'i şu komutla başlatın:\n'
                    'php artisan serve --host=0.0.0.0 --port=8000\n\n'
                    'Hata: $e';
              });
            }
          }

          return AlertDialog(
            title: const Text('Sunucu adresi'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Telefonda test için bilgisayarınızın IP adresini girin.\n'
                    'Örnek: http://192.168.1.10:8000\n'
                    '(sonuna /api/v1 yazmanız gerekmez)',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Sunucu adresi',
                      hintText: 'http://192.168.1.10:8000',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: testConnection,
                    icon: const Icon(Icons.wifi_find),
                    label: const Text('Bağlantıyı test et'),
                  ),
                  if (testMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      testMessage!,
                      style: TextStyle(
                        color: testOk == true
                            ? Colors.green.shade700
                            : testOk == false
                                ? Colors.red.shade700
                                : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('İptal'),
              ),
              FilledButton(
                onPressed: () async {
                  final url = ApiConfig.normalizeUrl(controller.text.trim());
                  if (url.isEmpty) return;
                  await ApiConfig.saveBaseUrl(prefs, url);
                  apiClient.setBaseUrl(url);
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kaydedildi: $url')),
                    );
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      );
    },
  );

  controller.dispose();
}
